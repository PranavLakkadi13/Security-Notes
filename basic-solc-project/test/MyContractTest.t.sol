// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {myContract} from "../src/MyContract.sol";
 
contract myContractTest is StdInvariant , Test{
    myContract public exampleContract;

    function setUp() public {
        exampleContract = new myContract();
        targetContract(address(exampleContract));
    }

    function invariant_shouldAlwaysbeZERO() public view {
        assert(exampleContract.shouldAlwaysBeZero() == 0);
    }
}
