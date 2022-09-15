// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.0;

import "forge-std/Test.sol";

import "../Keychain.sol";

contract KeychainTest is Test {

    Keychain keychain;

    function setUp() public {
        keychain = new Keychain();
    }

    function testExample() public {
        assertTrue(true);
    }
}
