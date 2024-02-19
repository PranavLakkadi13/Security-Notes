// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @title This contract is to teach and understand fuzzing tests 
/// @author Pranav Lakkadi 
contract myContract {
    uint256 public shouldAlwaysBeZero = 0;

    uint256 public hiddenValue = 0 ;

    function doStuff(uint256 data) public {
        // if (data == 2) {
        //     shouldAlwaysBeZero = 1;
        // }
        // if (hiddenValue == 7) {
        //     shouldAlwaysBeZero = 1;
        // }
        hiddenValue = data;
    }
}
