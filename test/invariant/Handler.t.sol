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

    uint256 expectedDeltaY;
    uint256 expectedDeltaX;
    uint256 startingY;
    uint256 startingX;

    address liquidityProvider = makeAddr("LP");

    constructor(TSwapPool _pool) {
        pool = _pool;
        weth = MockWETH(pool.getWeth());
        token = ERC20Mock(pool.getPoolToken());
    }

    function deposit(uint256 _wethAmount) public {
        _wethAmount = bound(_wethAmount, 0, type(uint96).max);

        startingX = token.balanceOf(address(this));
        startingY = weth.balanceOf(address(this));

        expectedDeltaY = _wethAmount;
        expectedDeltaX = pool.getPoolTokensToDepositBasedOnWeth(_wethAmount);

        vm.startPrank(liquidityProvider);
        weth.mint(liquidityProvider, _wethAmount);
        token.mint(liquidityProvider, expectedDeltaX);

        weth.approve(address(pool), type(uint256).max);
        token.approve(address(pool), type(uint256).max);

        pool.deposit(
            _wethAmount,
            0,
            expectedDeltaX,
            uint64(block.timestamp)
        );

        vm.stopPrank();
    }
}
