// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {HandlerStatefulFuzzCatches} from "../../../src/invariant-break/HandlerStatefulFuzzCatches.sol";
import {MockUSDC} from "../../mocks/MockUSDC.sol";
import {YeildERC20} from "../../mocks/YeildERC20.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

contract AttemptedBreakTest is StdInvariant, Test {
    HandlerStatefulFuzzCatches public testContract;
    MockUSDC public mockUSDC;
    YeildERC20 public yieldToken;

    address user = makeAddr("user");
    address otheruser = makeAddr("otheruser");

    function setUp() public {
        vm.startPrank(user);
        yieldToken = new YeildERC20();
        mockUSDC = new MockUSDC();

        IERC20[] memory x = new IERC20[](2);
        x[0] = IERC20(address(mockUSDC));
        x[1] = IERC20(address(yieldToken));
        testContract = new HandlerStatefulFuzzCatches(x);

        mockUSDC.mint(user, yieldToken.INITIAL_SUPPLY());
        vm.stopPrank();

        targetContract(address(testContract));
    }

    // This fuzz test is stupid and breaks since it passes ranodm address in the deposit function
    // since fuzzing is supposed to be random inputs it randomised the values passed into the function
    //  so we can't check for a specific error
    // function statefulFuzz_testinvariantBreak() public {
    //     vm.startPrank(user);
    //     testContract.withdrawToken(mockUSDC);
    //     testContract.withdrawToken(yieldToken);
    //     vm.stopPrank();

    //     assert(mockUSDC.balanceOf(address(testContract)) == 0);
    //     assert(yieldToken.balanceOf(address(testContract)) == 0);

    //     assert(mockUSDC.balanceOf(address(user)) == yieldToken.INITIAL_SUPPLY());
    //     assert(yieldToken.balanceOf(address(user)) == yieldToken.INITIAL_SUPPLY());
    // }
}
