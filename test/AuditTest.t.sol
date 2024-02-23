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
    address alice = makeAddr("alice");

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

        address[] memory players1 = new address[](2);
        players1[0] = address(feeAddress);
        players1[1] = address(alice);
        raffle.enterRaffle{value : 2e18}(players1);

        uint256 test = raffle.getActivePlayerIndex(address(feeAddress));
        assertEq(test, 4);
        assertEq(raffle.getActivePlayerIndex(address(alice)),5);
        assertEq(raffle.getActivePlayerIndex(address(test1)),0);
        assertEq(raffle.getActivePlayerIndex(address(1233)),0);
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

        vm.prank(alice);
        vm.expectRevert();
        raffle.refund(0);

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

    function testFuzzentrance(address[] memory x) public {
        raffle.enterRaffle(x);
    }
    
    function testabiencoding() public {
        vm.prevrandao(bytes32(uint256(42)));
        uint256 rarity = uint256(keccak256(abi.encodePacked(msg.sender, block.difficulty))) % 100;
        console.log(rarity);

        // vm.warp(29722);
        uint256 winnerIndex =
            uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp, block.difficulty))) %5;
       console.log(winnerIndex);
        
    }

    function testselectWinner() public {
        address[] memory players = new address[](4);
        players[0] = address(test1);
        players[1] = address(test2);
        players[2] = address(test3);
        players[3] = address(owner);
        raffle.enterRaffle{value : 4e18}(players);
        

        // vm.warp(block.timestamp + 501);
        // // vm.prevrandao(bytes32(uint256(12123241234)));
        // raffle.selectWinner();
        // string memory x = raffle.tokenURI(0);
        // console.log(x);

        vm.warp(block.timestamp + 501);
        vm.prevrandao(bytes32(uint256(121234)));
        raffle.selectWinner();
        string memory x = raffle.tokenURI(0);
        console.log(x);

    }

    function testcheckfeetowithdraw() public {
         address[] memory players = new address[](4);
        players[0] = address(test1);
        players[1] = address(test2);
        players[2] = address(test3);
        players[3] = address(owner);
        raffle.enterRaffle{value : 4e18}(players);
        

        vm.warp(block.timestamp + 501);
        // vm.prevrandao(bytes32(uint256(12123241234)));
        raffle.selectWinner();
        string memory x = raffle.tokenURI(0);
        console.log(x);

        uint256 z = address(feeAddress).balance;
        raffle.withdrawFees();
        uint256 l = address(feeAddress).balance;
    }
    
}