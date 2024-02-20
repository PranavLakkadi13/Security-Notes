// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test,console} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {Encoding} from "../src/Abi_Lesson/Encoding.sol";

contract testEncoding is Test {

    Encoding public testContract;

    function setUp() public {
        testContract = new Encoding();
    }

    function getOutput() public view {
        bytes memory x = testContract.encodeNumber();
        // console.log("The value of x is", x);
        // console.log("The value of x is", x);
        console.log("hello world");
        console.logBytes(x);
    }

    function getEncodeOutputString() public view {
        bytes memory x = testContract.encodeString();
        console.logBytes(x);
    }

    
}