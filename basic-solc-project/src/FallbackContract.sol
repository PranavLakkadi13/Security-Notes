// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;



/// @notice The contract is to show the use of the fallback functions 
contract Counter {
    uint256 public x;
    
    function increment() public {
        x++;
    }

    function decrement() public {
        x--;
    }

    fallback() external {}

    receive() external payable{}
}