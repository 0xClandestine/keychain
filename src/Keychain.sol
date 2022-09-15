// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.0;

import "solmate/tokens/ERC721.sol";
import "solmate/auth/Owned.sol";

error MissingKey();
error InvalidKey();
error CallFailed();
error DoorLocked();
error DoorUnlocked();

contract Keychain is ERC721("Keychain", "KEY") {

    // ----------------------------------------------------------
    // Events
    // ----------------------------------------------------------

    event KeyRecovered(
        address indexed owner, 
        address indexed newOwner, 
        uint256 indexed key
    );

    event KeyCreated(
        address indexed owner, 
        address indexed door, 
        uint256 indexed key
    );

    event LockCreated(
        address indexed owner, 
        address indexed door, 
        uint256 indexed key
    );

    event LockDestroyed(
        address indexed owner, 
        address indexed door, 
        uint256 indexed key
    );

    event KeyUsed(
        address indexed owner, 
        address indexed door, 
        uint256 indexed key
    );

    // ----------------------------------------------------------
    // Mutables
    // ----------------------------------------------------------
    
    uint256 public totalSupply;

    mapping(address => uint256) public nonces;

    mapping(address => bool) public isLocked;

    mapping(uint256 => mapping(address => bool)) public doesKeyFit;

    // ----------------------------------------------------------
    // Immutables
    // ----------------------------------------------------------
    
    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    constructor() {

        INITIAL_CHAIN_ID = block.chainid;

        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    // ----------------------------------------------------------
    // User actions
    // ----------------------------------------------------------

    function createKey(address to, address door) external returns (uint256 key) {

        unchecked {
            key = ++totalSupply;
        }

        if (isLocked[door]) revert DoorLocked();

        _mint(to, key);

        doesKeyFit[key][door] = true;

        emit KeyCreated(to, door, key);
    }

    function createLock(uint256 key, address door) external {

        if (msg.sender != _ownerOf[key]) revert MissingKey();

        if (isLocked[door]) revert DoorLocked();

        doesKeyFit[key][door] = true;

        emit LockCreated(msg.sender, door, key);
    }

    function destroyLock(uint256 key, address door) external {

        if (msg.sender != _ownerOf[key]) revert MissingKey();

        if (!isLocked[door]) revert DoorUnlocked();

        delete isLocked[door];

        delete doesKeyFit[key][door];

        emit LockDestroyed(msg.sender, door, key);
    }

    function execute(uint256 key, address door, bytes calldata data) external payable {

        if (msg.sender != _ownerOf[key]) revert MissingKey();

        if (!doesKeyFit[key][door]) revert InvalidKey();

        (bool success, ) = door.call{value: msg.value}(data);

        if (!success) revert CallFailed();

        emit KeyUsed(msg.sender, door, key);
    }

    function recover(
        address owner,
        address newOwner,
        uint256 key,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        if (_ownerOf[key] != owner) revert MissingKey();

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Recover(address owner,address newOwner,uint256 key,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                newOwner,
                                key,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );
            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            require(newOwner != address(0), "INVALID_RECIPIENT");

        }

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            _balanceOf[owner]--;

            _balanceOf[newOwner]++;
        }

        _ownerOf[key] = newOwner;

        delete getApproved[key];

        emit Transfer(owner, newOwner, key);

        emit KeyRecovered(owner, newOwner, key);
    }

    // ----------------------------------------------------------
    // EIP-4494 Logic
    // ----------------------------------------------------------

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    // ----------------------------------------------------------
    // ERC721 Logic
    // ----------------------------------------------------------

    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        return "";
    }
}