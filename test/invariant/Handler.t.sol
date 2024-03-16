// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {TSwapPool} from "../../src/TSwapPool.sol";
import {MockWETH} from "../mocks/MockWETH.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {Test, console2} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

contract Handler is Test {
    TSwapPool private pool;
    MockWETH private weth;
    ERC20Mock private token;

    // ghost variables basically only used for the test contract (handler)
    int256 public expectedDeltaY;
    int256 public expectedDeltaX;
    int256 public startingY;
    int256 public startingX;
    int256 public actualDeltaX;
    int256 public actualDeltaY;

    address liquidityProvider = makeAddr("LP");
    address swapper = makeAddr("swapper");

    constructor(TSwapPool _pool) {
        pool = _pool;
        weth = MockWETH(pool.getWeth());
        token = ERC20Mock(pool.getPoolToken());
    }

    function deposit(uint256 _wethAmount) public {
        uint256 minWeth = pool.getMinimumWethDepositAmount();
        _wethAmount = bound(_wethAmount, minWeth, type(uint96).max);

        startingX = int256(token.balanceOf(address(pool)));
        startingY = int256(weth.balanceOf(address(pool)));

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
        uint256 endingY = weth.balanceOf(address(pool));
        uint256 endingX = token.balanceOf(address(pool));

        actualDeltaX = int256(endingX) - int(startingX);
        actualDeltaY = int256(endingY) - int(startingY);
    }

    function swapPoolTokenForWethBasedonOutputWETH(uint256 outputWeth) public {
        uint256 minWeth = pool.getMinimumWethDepositAmount();
        outputWeth = bound(outputWeth, minWeth, weth.balanceOf(address(pool)));

        if (outputWeth >= weth.balanceOf(address(pool))){
            return;
        }

        uint256 pooltokenamount = pool.getInputAmountBasedOnOutput(outputWeth,token.balanceOf(address(pool)),weth.balanceOf(address(pool)));

        if (pooltokenamount > type(uint96).max) {
            return;
        }

        startingX = int256(token.balanceOf(address(pool)));
        startingY = int256(weth.balanceOf(address(pool)));

        expectedDeltaY = -1 * int256(outputWeth);
        expectedDeltaX = int256(pooltokenamount);

        if (token.balanceOf(swapper) < pooltokenamount) {
            token.mint(swapper,pooltokenamount - token.balanceOf(swapper) + 1);
        }

        vm.startPrank(swapper);

        token.approve(address(pool), type(uint256).max);
        pool.swapExactOutput(IERC20(address(token)),IERC20(address(weth)),outputWeth,(uint64(block.timestamp)));

        vm.stopPrank();


        // actual
        uint256 endingY = weth.balanceOf(address(pool));
        uint256 endingX = token.balanceOf(address(pool));

        actualDeltaX = int256(endingX) - int256(startingX);
        actualDeltaY = int256(endingY) - int256(startingY);
    }
}
