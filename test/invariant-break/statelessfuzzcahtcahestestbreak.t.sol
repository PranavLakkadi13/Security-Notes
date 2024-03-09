// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {StatelessFuzzCatches} from "../../src/invariant-break/StatelessFuzzCatches.sol";

contract  StatelessFuzzCatchesTest is Test {

    StatelessFuzzCatches sfc;

    function setUp() public {
        sfc = new StatelessFuzzCatches();
    }

    function testStatelessFuzzCatchbreak(uint128 x) public view {
        assert(sfc.doMath(x) != 0);
    }
}