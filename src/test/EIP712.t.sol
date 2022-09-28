// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Test} from "forge-std/Test.sol";

import "../EIP712.sol";

contract MockContract is EIP712 {
    constructor(string memory domain) EIP712(domain) {}
}

contract EIP712Test is Test {

    string constant LESS_THAN_32_BYTES = "> 32-bytes                    > ";
    string constant GREATER_THAN_32_BYTES = "> 32-bytes                    > THIS SHOULDN'T BE IN DOMAIN NAME";

    MockContract good;
    MockContract bad;

    function setUp() public {
        good = new MockContract(LESS_THAN_32_BYTES);
        bad = new MockContract(GREATER_THAN_32_BYTES);
    }

    function testExample() public {}
}