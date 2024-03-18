// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;


// @audit-info IThunderLoan interface should be implemented by ThunderLoan contract
interface IThunderLoan {
    // @audit low/info the function arguments dont match the one in the ThunderLoan contract
    function repay(address token, uint256 amount) external;
}
