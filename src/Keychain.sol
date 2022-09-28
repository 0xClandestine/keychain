// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.0;

import {Owned} from "solbase/auth/Owned.sol";
import {ERC721Permit} from "solbase/tokens/ERC721/extensions/ERC721Permit.sol";

error MissingKey();
error InvalidKey();
error CallFailed();
error DoorLocked();
error DoorUnlocked();

contract Keychain is ERC721Permit("Keychain", "KEY") {

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

    mapping(address => bool) public isLocked;

    mapping(uint256 => mapping(address => bool)) public doesKeyFit;

    // ----------------------------------------------------------
    // User actions
    // ----------------------------------------------------------

    function createKey(address to, address door) external returns (uint256 key) {

        unchecked {
            key = ++totalSupply;
        }

        if (isLocked[door]) revert DoorLocked();

        isLocked[door] = true;

        doesKeyFit[key][door] = true;

        _mint(to, key);

        emit KeyCreated(to, door, key);
    }

    function createLock(uint256 key, address door) external {

        if (msg.sender != _ownerOf[key]) revert MissingKey();

        if (isLocked[door] || doesKeyFit[key][door]) revert DoorLocked();

        isLocked[door] = true;

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

    // ----------------------------------------------------------
    // ERC721 Logic
    // ----------------------------------------------------------

    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        return "";
    }
}