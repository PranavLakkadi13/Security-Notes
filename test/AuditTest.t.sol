// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {PuppyRaffle} from "../src/PuppyRaffle.sol";

contract AuditRaffle is Test {

    address owner = makeAddr("owner");
    address test1 = makeAddr("test1");
    address test2 = makeAddr("test2");
    address test3 = makeAddr("test3");
    address feeAddress = makeAddr("fee holder");

    uint256 entranceFee = 1e18;

    uint256 raffleduration = 500;

    PuppyRaffle raffle; 

    function setUp() public {
        vm.prank(owner);
        raffle = new PuppyRaffle(entranceFee,feeAddress,raffleduration);
    }

    function test_enterRaffleTest1() public {
        address[] memory players = new address[](4);
        players[0] = address(test1);
        players[1] = address(test2);
        players[2] = address(test3);
        players[3] = address(owner);
        raffle.enterRaffle{value : 4e18}(players);
    }

    function testRefundRaffle() public {
        address[] memory players = new address[](4);
        players[0] = address(test1);
        players[1] = address(test2);
        players[2] = address(test3);
        players[3] = address(owner);
        raffle.enterRaffle{value : 4e18}(players);

        uint256 bal = address(test2).balance;
        console.log(bal);

        vm.prank(test2);
        raffle.refund(1);

        assert(bal != address(test2).balance);

        address x  = raffle.players(1);
        assertEq(x, address(0));

    }

    function testActivePlayer() public {
        address[] memory players = new address[](4);
        players[0] = address(test1);
        players[1] = address(test2);
        players[2] = address(test3);
        players[3] = address(owner);
        raffle.enterRaffle{value : 4e18}(players);

        console.log(raffle.players(0));
        console.log(raffle.players(1));
        console.log(raffle.players(2));
        console.log(raffle.players(3));

        uint256 x = raffle.getActivePlayerIndex(address(test3));
        assertEq(x, 2);
        uint256 y = raffle.getActivePlayerIndex(address(test1));
        assertEq(y, 0);
    }

    function testChangeFeeAddress(address x) public {
        address y = x;
        vm.prank(owner);
        raffle.changeFeeAddress(y);
    }

}