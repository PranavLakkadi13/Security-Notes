// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {BaseTest, ThunderLoan} from "./BaseTest.t.sol";
import {AssetToken} from "../../src/protocol/AssetToken.sol";
import {MockFlashLoanReceiver} from "../mocks/MockFlashLoanReceiver.sol";
import {MockPoolFactory} from "../mocks/MockPoolFactory.sol";
import {BuffMockTSwap} from "../mocks/BuffMockTSwap.sol";
import {BuffMockPoolFactory} from "../mocks/BuffMockPoolFactory.sol";
import {ERC20Mock} from "../mocks/ERC20mock.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract ThunderLoanTest is BaseTest {
    uint256 constant AMOUNT = 10e18;
    uint256 constant DEPOSIT_AMOUNT = AMOUNT * 100;
    address liquidityProvider = address(123);
    address user = address(456);
    MockFlashLoanReceiver mockFlashLoanReceiver;
    ERC20Mock tokenB;

    function setUp() public override {
        super.setUp();
        vm.prank(user);
        mockFlashLoanReceiver = new MockFlashLoanReceiver(address(thunderLoan));
    }

    function testInitializationOwner() public {
        assertEq(thunderLoan.owner(), address(this));
    }

    function testSetAllowedTokens() public {
        vm.prank(thunderLoan.owner());
        thunderLoan.setAllowedToken(tokenA, true);
        assertEq(thunderLoan.isAllowedToken(tokenA), true);
    }

    function testOnlyOwnerCanSetTokens() public {
        vm.prank(liquidityProvider);
        vm.expectRevert();
        thunderLoan.setAllowedToken(tokenA, true);
    }

    function testSettingTokenCreatesAsset() public {
        vm.prank(thunderLoan.owner());
        AssetToken assetToken = thunderLoan.setAllowedToken(tokenA, true);
        assertEq(
            address(thunderLoan.getAssetFromToken(tokenA)),
            address(assetToken)
        );
    }

    function testCantDepositUnapprovedTokens() public {
        tokenA.mint(liquidityProvider, AMOUNT);
        tokenA.approve(address(thunderLoan), AMOUNT);
        vm.expectRevert(
            abi.encodeWithSelector(
                ThunderLoan.ThunderLoan__NotAllowedToken.selector,
                address(tokenA)
            )
        );
        thunderLoan.deposit(tokenA, AMOUNT);
    }

    modifier setAllowedToken() {
        vm.prank(thunderLoan.owner());
        thunderLoan.setAllowedToken(tokenA, true);
        _;
    }

    function testDepositMintsAssetAndUpdatesBalance() public setAllowedToken {
        tokenA.mint(liquidityProvider, AMOUNT);

        vm.startPrank(liquidityProvider);
        tokenA.approve(address(thunderLoan), AMOUNT);
        thunderLoan.deposit(tokenA, AMOUNT);
        vm.stopPrank();

        AssetToken asset = thunderLoan.getAssetFromToken(tokenA);
        assertEq(tokenA.balanceOf(address(asset)), AMOUNT);
        assertEq(asset.balanceOf(liquidityProvider), AMOUNT);
    }

    modifier hasDeposits() {
        vm.startPrank(liquidityProvider);
        tokenA.mint(liquidityProvider, DEPOSIT_AMOUNT);
        tokenA.approve(address(thunderLoan), DEPOSIT_AMOUNT);
        thunderLoan.deposit(tokenA, DEPOSIT_AMOUNT);
        vm.stopPrank();
        _;
    }

    function testFlashLoan() public setAllowedToken hasDeposits {
        uint256 amountToBorrow = AMOUNT * 10;
        uint256 calculatedFee = thunderLoan.getCalculatedFee(
            tokenA,
            amountToBorrow
        );
        vm.startPrank(user);
        tokenA.mint(address(mockFlashLoanReceiver), AMOUNT);
        thunderLoan.flashloan(
            address(mockFlashLoanReceiver),
            tokenA,
            amountToBorrow,
            ""
        );
        vm.stopPrank();

        assertEq(
            mockFlashLoanReceiver.getBalanceDuring(),
            amountToBorrow + AMOUNT
        );
        assertEq(
            mockFlashLoanReceiver.getBalanceAfter(),
            AMOUNT - calculatedFee
        );
    }

    function testGetCalculatedFee() public setAllowedToken hasDeposits {
        uint256 amountToBorrow = AMOUNT * 10;
        uint256 calculatedFee = thunderLoan.getCalculatedFee(
            tokenA,
            amountToBorrow
        );
        assert(calculatedFee == (amountToBorrow * 997) / 1000);
        // assert(calculatedFee == amountToBorrow / 100);
    }

    function testRedeem() public setAllowedToken hasDeposits {
        uint256 amountToBorrow = AMOUNT * 100;
        uint256 calculatedFee = thunderLoan.getCalculatedFee(
            tokenA,
            amountToBorrow
        );
        vm.startPrank(user);
        tokenA.mint(address(mockFlashLoanReceiver), AMOUNT);
        thunderLoan.flashloan(
            address(mockFlashLoanReceiver),
            tokenA,
            amountToBorrow,
            ""
        );
        vm.stopPrank();

        vm.prank(liquidityProvider);

        uint256 amountToRedeem = type(uint256).max;
        thunderLoan.redeem(tokenA, amountToRedeem);
    }

    function testOracleManipulation() public {
        // SetUp
        thunderLoan = new ThunderLoan();
        tokenB = new ERC20Mock();
        proxy = new ERC1967Proxy(address(thunderLoan), "");
        BuffMockPoolFactory poolFactory = new BuffMockPoolFactory(
            address(weth)
        );
        // Creating a pool for tokenB/weth
        address tswapPool = poolFactory.createPool(address(tokenB));
        thunderLoan = ThunderLoan(address(proxy));
        thunderLoan.initialize(address(poolFactory));

        // 2. Fund the pool with tokenB in TSwap
        vm.startPrank(liquidityProvider);
        tokenB.mint(liquidityProvider, 100e18);
        tokenB.approve(tswapPool, 100e18);
        weth.mint(liquidityProvider, 100e18);
        weth.approve(tswapPool, 100e18);

        BuffMockTSwap(tswapPool).deposit(
            100e18,
            100e18,
            100e18,
            block.timestamp
        );
        vm.stopPrank();

        // 3. fund thunderloan
        vm.prank(thunderLoan.owner());
        thunderLoan.setAllowedToken(tokenB, true);
        vm.startPrank(liquidityProvider);
        tokenB.mint(liquidityProvider, 1000e18);
        tokenB.approve(address(thunderLoan), 1000e18);
        thunderLoan.deposit(tokenB, 1000e18);
        vm.stopPrank();

        /**
         * SO far we know that the ratio of the tokens in the pool is 1:1 (100:100) (weth:tokenB)
         * The amount of tokenB in the thunderloan is 1000
         * now we will take a flash loan and nuke the price of tokenB and pay less fee
         * using th emanipulated price
         * after that take another loan to show that we can mainuplate the price of the tokenB further
         * and show how tlow the price can get
         */

        uint256 normalFeeCost = thunderLoan.getCalculatedFee(tokenB, 100e18);
        console.log("Normal Fee Cost: ", normalFeeCost);

        uint256 amountToBorrow = 50e18;

        // 4. We will take 2 flashloanz :
        //             1) To nuke the price of the weh/tokenB
        //            2) to show that we need top pay less fee to the pool
    }
}


contract MaliciousFlashLoanReceiver {
    ThunderLoan thunderLoan;
    ERC20Mock tokenB;
    
    constructor(ThunderLoan _thunderLoan, ERC20Mock _tokenB) {
        thunderLoan = _thunderLoan;
        tokenB = _tokenB;
    }
}