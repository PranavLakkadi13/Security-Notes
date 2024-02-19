// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test,console} from "forge-std/Test.sol";
import {Encoding} from "../src/Abi_Lesson/Encoding.sol";

contract testEncoding is Test {

    Encoding public testContract;

    function setUp() public {
        testContract = new Encoding();
    }

    function getOutput() public returns (bytes memory x){
        x = testContract.encodeNumber();
        // console.log("The value of x is", x);
        // console.log("The value of x is", x);
    }
}