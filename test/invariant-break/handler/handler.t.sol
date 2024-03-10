// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {HandlerStatefulFuzzCatches} from "../../../src/invariant-break/HandlerStatefulFuzzCatches.sol";
import {YeildERC20} from "../../mocks/YeildERC20.sol";
import {MockUSDC} from "../../mocks/MockUSDC.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

contract Handler is Test {
    HandlerStatefulFuzzCatches handlerStatefulFuzzCatches;
    MockUSDC mockUSDC;
    YeildERC20 yeildERC20;
    address user;

    constructor(
        HandlerStatefulFuzzCatches _handlerStatefulFuzzCatches,
        MockUSDC _mockUSDC,
        YeildERC20 _yeildERC20,
        address _user
    ) {
        handlerStatefulFuzzCatches = _handlerStatefulFuzzCatches;
        mockUSDC = _mockUSDC;
        yeildERC20 = _yeildERC20;
        user = _user;
    }

    // This the handler functions to set the limits of the randomness 
    function depositYeildERC20(uint256 _amount) public {
        uint256 amount = bound(_amount, 0, yeildERC20.balanceOf(user));
        vm.startPrank(user);
        yeildERC20.approve(address(handlerStatefulFuzzCatches), amount);
        handlerStatefulFuzzCatches.depositToken(IERC20(address(yeildERC20)), amount);
        vm.stopPrank();
    }

    function depositMockERC20(uint256 _amount) public {
        uint256 amount = bound(_amount, 0, mockUSDC.balanceOf(user));
        vm.startPrank(user);
        mockUSDC.approve(address(handlerStatefulFuzzCatches), amount);
        handlerStatefulFuzzCatches.depositToken(IERC20(address(mockUSDC)), amount);
        vm.stopPrank();
    }

    function withdrawYeildERC20() public {
        vm.startPrank(user);
        handlerStatefulFuzzCatches.withdrawToken(IERC20(address(yeildERC20)));
        vm.stopPrank();
    }

    function withdrawMockERC20() public {
        vm.startPrank(user);
        handlerStatefulFuzzCatches.withdrawToken(IERC20(address(mockUSDC)));
        vm.stopPrank();
    }
}
