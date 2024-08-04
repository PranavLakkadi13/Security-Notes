// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {horseStore} from "../../src/horseStore_V1/horseStore.sol";
import {Test,console2} from "forge-std/Test.sol";
import {Base_TestV1} from "./Base_TestV1.t.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

contract HorseStoreHuff is Base_TestV1 {
    function setUp() public override {
        s_horseStore = horseStore(HuffDeployer.config().deploy("horseStore_V1/horseStore"));
    }
}
