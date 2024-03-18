// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Registry} from "../src/Registry.sol";

contract RegistryTest is Test {
    Registry registry;
    address alice;

    function setUp() public {
        alice = makeAddr("alice");

        registry = new Registry();
    }

    function test_deposit() public {
        uint256 amountToPay = registry.PRICE();

        vm.deal(alice, amountToPay);
        vm.startPrank(alice);

        uint256 aliceBalanceBefore = address(alice).balance;

        registry.register{value: amountToPay}();

        uint256 aliceBalanceAfter = address(alice).balance;

        assert(registry.isRegistered(alice) == true);
        assert(address(registry).balance == registry.PRICE());
        assert(aliceBalanceAfter == aliceBalanceBefore - registry.PRICE());
    }

    /** Code your fuzz test here */
    function testFuzz_deposit(uint256 amountToPay) public {
        vm.assume(amountToPay >= 1 ether);

        vm.deal(alice, amountToPay);
        vm.startPrank(alice);

        uint256 aliceBalanceBefore = address(alice).balance;

        registry.register{value: amountToPay}();

        uint256 aliceBalanceAfter = address(alice).balance;

        assert(registry.isRegistered(alice) == true);
        assert(address(registry).balance == registry.PRICE());
        assert(aliceBalanceAfter == aliceBalanceBefore - registry.PRICE());
    }
    
}
