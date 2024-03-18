// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

// e: this interface to get the pool address for a given token address when 
// interacting with Tswap contract
interface IPoolFactory {
    function getPool(address tokenAddress) external view returns (address);
}
