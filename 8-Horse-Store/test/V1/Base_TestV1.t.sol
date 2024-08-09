// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {horseStore} from "../../src/horseStore_V1/horseStore.sol";
import {IhorseStore} from "../../src/horseStore_V1/IhorseStore.sol";
import {Test,console2} from "forge-std/Test.sol";


abstract contract Base_TestV1 is Test {
    IhorseStore public s_horseStore;

    function setUp() public virtual {
        s_horseStore = IhorseStore(address(new horseStore()));
    }

    function testReadNumberOfHorses() public view{
        uint256 initial = s_horseStore.getNumberOfHorses();
        assertEq(initial, 0);
    }

    function testUpdateNumberOfHorses(uint256 num) public {
        s_horseStore.updateNumberOfHorses(num);
        uint256 updated = s_horseStore.getNumberOfHorses();
        assertEq(updated, num);
    }
}