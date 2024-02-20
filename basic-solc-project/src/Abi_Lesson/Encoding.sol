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
        bytes memory num = abi.encode(1);
        return num;
    }


    // The Big difference between encode and encodePacked is that encode is like 
    // the perfect bytes version of the input that the EVM can understand whereas the 
    // encode packed version is the closer and similar version to the EVM bytes but 
    // removes unnecessary padding 

    function encodeString() public pure returns (bytes memory) {
        bytes memory str = abi.encode("some string");
        return str;
    }

    function encodeStringPacked() public pure returns (bytes memory) {
        return abi.encodePacked("some string");
    }

    // The below function is going to just convert the string input to the type bytes
    // The output of the bytes will be similar to the output of encodeStringPacked()
    // The differnce if in the method used to encode, the type bytes is UTF-8, ABI
    // encoding is based on the abi specs

    function bytesString() public pure returns (bytes memory) {
        return bytes("some string");
    }

    function decodeString() public pure returns (string memory) {
        string memory someString = abi.decode(encodeString(),(string));
        return someString;
    }

    function multiEncoding() public pure returns (bytes memory) {
        return abi.encode("some string","some Other string");
    }

    function multiPackedEncoding() public pure returns (bytes memory) {
        return abi.encodePacked("some string","some Other string");
    }

    function multiDecode() public pure returns (string memory, string memory) {
        (string memory str1,string memory str2) = abi.decode(multiEncoding(),(string,string));
        return (str1,str2);
    }

    // The function multi decode packed wont work 
    function multiDecodePacked() public pure returns (string memory, string memory) {
        (string memory str1,string memory str2) = abi.decode(multiPackedEncoding(),(string,string));
        return (str1,str2);
    }

    // to decode multiple packed string its better to just typecast to string 
    function multidecodeStringCast() public pure returns (string memory) {
        string memory string1 = string(multiPackedEncoding());
        return string1;
    }
}