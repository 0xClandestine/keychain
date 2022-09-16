// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.0;

import "forge-std/Test.sol";

import "../Keychain.sol";


contract OwnedContract is Owned {

    constructor() Owned(msg.sender) {}

    function foo() external onlyOwner returns (bool) {
        return true;
    }
}

contract KeychainTest is Test {

    OwnedContract door;

    Keychain keychain;

    function setUp() public {

        door = new OwnedContract();
        
        keychain = new Keychain();
    
        // NOTE: you MUST always create key BEFORE transfering 
        // contract ownership/authorization otherwise somebody 
        // can frontrun key creation.
        uint256 key = keychain
            .createKey(
                address(this), 
                address(door)
            );
        
        door.setOwner(address(keychain));
    }

    function testFail_CreateKey_DoorLocked() public {
        // key already exists for door
        keychain.createKey(address(this), address(door));
    }

    function testFail_Execute_InvalidKey() public {
        // invalid door 'address(0)'
        keychain.execute(1, address(0), abi.encode(OwnedContract.foo.selector));
    }

    function testFail_Execute_MissingKey() public {
        // invalid token owner '0xb0b'
        vm.prank(address(0xb0b));
        keychain.execute(1, address(door), abi.encode(OwnedContract.foo.selector));
    }
    
    function testFail_Execute_DoorLocked() public {
        // this key shouldn't have access to door
        uint256 key = keychain.createKey(address(this), address(0));
        keychain.execute(key, address(door), abi.encode(OwnedContract.foo.selector));
    }
}