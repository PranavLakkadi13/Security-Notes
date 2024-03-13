// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {TSwapPool} from "../../src/TSwapPool.sol";
import {MockWETH} from "../mocks/MockWETH.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {Test, console2} from "forge-std/Test.sol";

contract Handler is Test {
    TSwapPool private pool;
    MockWETH private weth;
    ERC20Mock private token;

    uint256 expectedstartingY;
    uint256 expectedstartingX;

    constructor(TSwapPool _pool) {
        pool = _pool;
        weth = MockWETH(pool.getWeth());
        token = ERC20Mock(pool.getPoolToken());
    }

    function deposit(uint256 _wethAmount) public {
        _wethAmount = bound(_wethAmount, 0, type(uint96).max);
        expectedstartingY = _wethAmount;
        expectedstartingX = pool.getPoolTokensToDepositBasedOnWeth(_wethAmount);
    }
}
