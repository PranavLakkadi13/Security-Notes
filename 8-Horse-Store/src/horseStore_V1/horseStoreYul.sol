// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract horseStoreYul {
    uint256 private s_numberOfHorses;

    function updateNumberOfHorses(uint256 _numberOfHorses) public {
        assembly {
            sstore(s_numberOfHorses.slot, _numberOfHorses)
        }
    }

    function getNumberOfHorses() public view returns (uint256) {
        assembly {
            let num := sload(s_numberOfHorses.slot)
            mstore(0, num)
            return(0, 0x20)
        }
    }
}
