// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {HandlerStatefulFuzzCatches} from "../../../src/invariant-break/HandlerStatefulFuzzCatches.sol";
import {MockUSDC} from "../../mocks/MockUSDC.sol";
import {YeildERC20} from "../../mocks/YeildERC20.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {Handler} from "./Handler.t.sol";

contract InvariantBreakTest is StdInvariant, Test {
    HandlerStatefulFuzzCatches public testContract;
    MockUSDC public mockUSDC;
    YeildERC20 public yieldToken;
    Handler handler;

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

        handler = new Handler(testContract, mockUSDC, yieldToken, user);

        bytes4[] memory selectors = new bytes4[](4);
        selectors[0] = handler.depositMockERC20.selector;
        selectors[1] = handler.depositYeildERC20.selector;
        selectors[2] = handler.withdrawMockERC20.selector;
        selectors[3] = handler.withdrawYeildERC20.selector;
        
        targetSelector(FuzzSelector({addr : address(handler), selectors : selectors}));

        targetContract(address(handler));
    }


    function statefulFuzz_testinvariantBreakHandler() public {
        vm.startPrank(user);
        testContract.withdrawToken(mockUSDC);
        testContract.withdrawToken(yieldToken);
        vm.stopPrank();

        assert(mockUSDC.balanceOf(address(testContract)) == 0);
        assert(yieldToken.balanceOf(address(testContract)) == 0);

        assert(mockUSDC.balanceOf(address(user)) == yieldToken.INITIAL_SUPPLY());
        assert(yieldToken.balanceOf(address(user)) == yieldToken.INITIAL_SUPPLY());
    }
}
