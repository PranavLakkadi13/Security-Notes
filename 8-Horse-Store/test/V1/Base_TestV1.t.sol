// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {horseStore} from "../../src/horseStore_V1/horseStore.sol";
import {Test,console2} from "forge-std/Test.sol";


abstract contract Base_TestV1 is Test {
    horseStore private s_horseStore;

    function setUp() public virtual {
        s_horseStore = new horseStore();
    }

    function testReadNumberOfHorses() public {
        uint256 initial = s_horseStore.getNumberOfHorses();
        assertEq(initial, 0);
    }
}