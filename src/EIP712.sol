// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract EIP712 {

    // ----------------------------------------------------------
    // Constants
    // ----------------------------------------------------------

    bytes32 internal constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    // ----------------------------------------------------------
    // Immutables
    // ----------------------------------------------------------

    bytes32 internal immutable HASHED_DOMAIN_NAME;

    bytes32 internal immutable HASHED_DOMAIN_VERSION;
    
    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    uint256 internal immutable INITIAL_CHAIN_ID;

    constructor(string memory domainName, string memory version) {
        
        HASHED_DOMAIN_NAME = keccak256(bytes(domainName));

        HASHED_DOMAIN_VERSION = keccak256(bytes(version));
        
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();

        INITIAL_CHAIN_ID = block.chainid;
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
                    DOMAIN_TYPEHASH,
                    HASHED_DOMAIN_NAME,
                    HASHED_DOMAIN_VERSION,
                    block.chainid,
                    address(this)
                )
            );
    }

    function computeDigest(bytes32 hashStruct) internal view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01", 
                    DOMAIN_SEPARATOR(), 
                    hashStruct
                )
            );
    }
}