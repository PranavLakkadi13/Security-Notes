// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {StatefulFuzzCatches} from "../../src/invariant-break/StatefulFuzzCatches.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";

// The order matters to make the call
contract StatefulFuzzCatchesTest is StdInvariant, Test {
    StatefulFuzzCatches public testContract;

    function setUp() public {
        testContract = new StatefulFuzzCatches();
        targetContract(address(testContract));
    }

    // doing a normal fuzz on the do math function
    function testfuzzdomath(uint128 x) public {
        assert(testContract.doMoreMathAgain(x) != 0);
    }

    // just like the test keyword in a test function here the invariant is the keyword
    function invariant_fuzztobreak() public view {
        assert(testContract.storedValue() != 0);
    }
}
