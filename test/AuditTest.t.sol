// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std/Test.sol";
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
        raffle = new PuppyRaffle(entranceFee,feeAddress,raffleduration);
    }

    function test_enterRaffleTest1() public {
        address[] memory players = new address[](4);
        players[0] = address(test1);
        players[1] = address(test2);
        players[2] = address(test3);
        players[3] = address(test1);
        raffle.enterRaffle{value : 4e18}(players);
    }

}