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

    // ghost variables basically only used for the test contract (handler)
    int256 expectedDeltaY;
    int256 expectedDeltaX;
    int256 startingY;
    int256 startingX;
    int256 actualDeltaX;
    int256 actualDeltaY;

    address liquidityProvider = makeAddr("LP");

    constructor(TSwapPool _pool) {
        pool = _pool;
        weth = MockWETH(pool.getWeth());
        token = ERC20Mock(pool.getPoolToken());
    }

    function deposit(uint256 _wethAmount) public {
        _wethAmount = bound(_wethAmount, 0, type(uint96).max);

        startingX = int256(token.balanceOf(address(this)));
        startingY = int256(weth.balanceOf(address(this)));

        expectedDeltaY = int256(_wethAmount);
        expectedDeltaX = int256(pool.getPoolTokensToDepositBasedOnWeth(_wethAmount));

        // deposit function call
        vm.startPrank(liquidityProvider);
        weth.mint(liquidityProvider, _wethAmount);
        token.mint(liquidityProvider, uint256(expectedDeltaX));

        weth.approve(address(pool), type(uint256).max);
        token.approve(address(pool), type(uint256).max);

        pool.deposit(
            _wethAmount,
            0,
            uint256(expectedDeltaX),
            uint64(block.timestamp)
        );
        vm.stopPrank();

        // actual
        uint256 endingY = weth.balanceOf(address(this));
        uint256 endingX = token.balanceOf(address(this));

        actualDeltaX = int256(endingX) - int(startingX);
        actualDeltaY = int256(endingY) - int(startingY);
    }

    function swapPoolTokenForWethBasedonOutputWETH(uint256 outputWeth) public {
        outputWeth = bound(outputWeth, 0, type(uint96).max);

        if (outputWeth >= weth.balanceOf(address(pool))){
            return;
        }


    }
}
