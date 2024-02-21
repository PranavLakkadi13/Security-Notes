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

    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \ 
    //         yes  no
    //         /     \
    //    receive()?  fallback() 
    //     /   \ 
    //   yes   no
    //  /        \
    //receive()  fallback()
}