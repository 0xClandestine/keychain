// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.0;

import "solmate/tokens/ERC721.sol";

abstract contract ERC721Permit is ERC721 {

    // ----------------------------------------------------------
    // Mutables
    // ----------------------------------------------------------

    mapping(uint256 => uint256) public nonces;

    // ----------------------------------------------------------
    // Immutables
    // ----------------------------------------------------------

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    constructor(
        string memory _name, 
        string memory _symbol
    ) ERC721(_name, _symbol) {

        INITIAL_CHAIN_ID = block.chainid;
        
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    // ----------------------------------------------------------
    // Actions
    // ----------------------------------------------------------

    function permit(
        address spender,
        uint256 id,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {

        require(spender != address(0), "INVALID_SPENDER");

        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

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
                                keccak256("Permit(address spender,uint256 id,uint256 nonce,uint256 deadline)"),
                                spender,
                                id,
                                nonces[id]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == _ownerOf[id], "INVALID_SIGNER");

            getApproved[id] = spender;

            emit Approval(recoveredAddress, spender, id);
        }
    }

    // ----------------------------------------------------------
    // Viewables
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
}