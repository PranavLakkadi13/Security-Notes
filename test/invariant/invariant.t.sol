// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {MockWETH} from "../mocks/MockWETH.sol";
import {PoolFactory} from "../../src/PoolFactory.sol";
import {TSwapPool} from "../../src/TSwapPool.sol";
import {Handler} from "../../test/invariant/Handler.t.sol";

contract InvariantTest is StdInvariant, Test {
    // assets
    ERC20Mock public pooltoken;
    MockWETH public weth;

    // contracts
    PoolFactory public factory;
    TSwapPool public pool; // PoolToken/WETH pool

    int256 constant STARTING_X = 100e18; // balance of ERC20
    int256 constant STARTING_Y = 50e18; // balance of weth

    Handler private handler;

    function setUp() public {
        pooltoken = new ERC20Mock();
        weth = new MockWETH();

        factory = new PoolFactory(address(weth));
        pool = TSwapPool(factory.createPool(address(pooltoken)));

        pooltoken.mint(address(this), uint256(STARTING_X));
        weth.mint(address(this), uint256(STARTING_Y));

        pooltoken.approve(address(pool), type(uint256).max);
        weth.approve(address(pool), type(uint256).max);

        pool.deposit(
            uint256(STARTING_Y),
            uint256(STARTING_Y),
            uint256(STARTING_X),
            uint64(block.timestamp)
        );

        handler = new Handler(pool);

        bytes4[] memory selectors = new bytes4[](3);
        selectors[0] = handler.swapPoolTokenForWethBasedonOutputWETH.selector;
        selectors[1] = handler.deposit.selector;
        selectors[2] = handler.startingY.selector;

        targetContract(address(handler));
        targetSelector(FuzzSelector({addr: address(handler) , selectors: selectors}));
    }


    function statefulFuzz_constantProductFormulaStaysTheSame() public {
        assert(handler.actualDeltaX() == handler.expectedDeltaX());
    }
}
