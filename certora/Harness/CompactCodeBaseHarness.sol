// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { MathMasters } from "../../src/MathMasters.sol";

contract CompactCodeBaseHarness {
    function mulWadUp(uint256 x, uint256 y) external returns (uint256) {
        return MathMasters.mulWadUp(x, y);
    }

    function sqrt(uint256 x) external returns (uint256) {
        return MathMasters.sqrt(x);
    }

    function uniSqrt(uint256 x) external returns (uint256 z) {
        if (x > 3) {
            z = x;
            uint256 y = x / 2 + 1;
            while (y < z) {
                z = y;
                y = (x / y + y) / 2;
            }
        } else if (x != 0) {
            z = 1;
        }
    }

    // Based on Solmate
    // https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol
    function solmateSqrt(uint256 x) external pure returns (uint256 z) {
        assembly {
            let y := x

            z := 181
            if iszero(lt(y, 0x10000000000000000000000000000000000)) {
                y := shr(128, y)
                z := shl(64, z)
            }
            if iszero(lt(y, 0x1000000000000000000)) {
                y := shr(64, y)
                z := shl(32, z)
            }
            if iszero(lt(y, 0x10000000000)) {
                y := shr(32, y)
                z := shl(16, z)
            }
            if iszero(lt(y, 0x1000000)) {
                y := shr(16, y)
                z := shl(8, z)
            }

            z := shr(18, mul(z, add(y, 65536)))

            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            z := sub(z, lt(div(x, z), z))
        }
    }
}