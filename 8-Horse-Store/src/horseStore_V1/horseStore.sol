// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract horseStore {
    uint256 private s_numberOfHorses;

    function updateNumberOfHorses(uint256 _numberOfHorses) public {
        s_numberOfHorses = _numberOfHorses;
    }

    function getNumberOfHorses() public view returns (uint256) {
        return s_numberOfHorses;
    }
}
