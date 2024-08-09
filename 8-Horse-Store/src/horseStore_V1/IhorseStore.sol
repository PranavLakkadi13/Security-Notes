// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IhorseStore {
    function updateNumberOfHorses(uint256 _numberOfHorses) external;

    function getNumberOfHorses() external view returns (uint256);
}
