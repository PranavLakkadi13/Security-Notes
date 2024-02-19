// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract Encoding {
    
    // abi.encodePacked is global method 
    // abi.encode just encodes the peice of information to bytes/hex
    // now using it we can get the function signature using that we can interact with functions
    // 
    function combineString() public pure returns (string memory) {
        return string(abi.encodePacked("Hi Mom!! ","Miss Youuuuu"));
    }

    function encodeNumber() public pure returns(bytes memory) {
        return abi.encode(1);
    }

    function encodeString() public pure returns (bytes memory) {
        return abi.encode("some string");
    }
}