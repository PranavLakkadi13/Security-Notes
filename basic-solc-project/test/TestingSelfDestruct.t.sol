// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {EtherGame,Attack} from "../src/SelfDestruct.sol";

contract TestingSelfDestruct is Test {

    EtherGame public game; 
    Attack public attack;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        game = new EtherGame();
        attack = new Attack(game);
    }

    function getABIPacked() public pure returns (bytes memory){
        return abi.encodeWithSignature("deposit()");
    }

    function depositETHinGameContract() public {
        vm.prank(bob);
        hoax(address(bob),1e19);
        // game.deposit();
        (bool success, )  = address(game).call{value: 1e18}(abi.encodeWithSignature("deposit()"));
        assertEq(success,true);
        assertEq(address(game).balance,1e18);
    }

}
