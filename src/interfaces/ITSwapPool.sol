// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

// @audit why only the price w.r.t to weth and why TSwap ?
interface ITSwapPool {
    function getPriceOfOnePoolTokenInWeth() external view returns (uint256);
}
