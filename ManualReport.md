# High

### [H-1]: Incorrect Fees calcultaion in `TswapPool::getInputAmountBasedOnOutput()` causes the protocol to take too many tokens from the users as fee 

**Description:** The `getInputAmountBasedOnOutput` functions miscalculates the fee and takes in more fee from the user, the current fee is 10_000 instead of 1_000 

**Impact:** The Protocol takes more fee from the user than expected

**Recommended Mitigation** 
```diff
    function getInputAmountBasedOnOutput(
        uint256 outputAmount,
        uint256 inputReserves,
        uint256 outputReserves
    )
    public
    pure
    revertIfZero(outputAmount)
    revertIfZero(outputReserves)
    returns (uint256 inputAmount)
    {
        return
-            ((inputReserves * outputAmount) * 10_000) /
+           ((inputReserves * outputAmount) * 1_000) /
            ((outputReserves - outputAmount) * 997);
    }
```


### [H-2]: There is a missing slippage protection in `TSwapPool::swapExactOutput()` causes user to receive way less tokens then expected 

**Description:** The `swapExactOutput()` function lacks slippage protection, this function is sismilar to the `TSwapPool::swapExactInput()` which has slippage protection by using the `minOutputAmount` param this function should also have a `maxInputAmount`

**Impact:** If the market condition changes before the transaction is processeed then the user can get a much worse swap

**Proof of Concept:**
1. The price of 1 WETH right now is 1,000 USDC
2. User inputs a `swapExactOutput` looking for 1 WETH
    1. inputToken = USDC
    2. outputToken = WETH
    3. outputAmount = 1
    4. deadline = whatever
3. The function does not offer a maxInput amount
4. As the transaction is pending in the mempool, the market changes! And the price moves HUGE -> 1 WETH is now 10,000 USDC. 10x more than the user expected
5. The transaction completes, but the user sent the protocol 10,000 USDC instead of the expected 1,000 USDC

**Recommended Mitigation**
We should include a `maxInputAmount` in the parameter so that the user can spend only a specific amount and a good protection incase of changing market conditions 

```diff
    function swapExactOutput(
        IERC20 inputToken,
+       uint256 maxInputAmount
        IERC20 outputToken,
        uint256 outputAmount,
        uint64 deadline
    )
        public
        revertIfZero(outputAmount)
        revertIfDeadlinePassed(deadline)
        returns (uint256 inputAmount)
    {
        uint256 inputReserves = inputToken.balanceOf(address(this));
        uint256 outputReserves = outputToken.balanceOf(address(this));

        inputAmount = getInputAmountBasedOnOutput(
            outputAmount,
            inputReserves,
            outputReserves
        );
        
+       if (inputAmount > maxInputAmount) {
+           revert();
+       } 

        _swap(inputToken, inputAmount, outputToken, outputAmount);
    }
```


### [H-3]: `TSawpPool::sellPoolTokens` mismatches input and output tokens causing users to receive incorrect amount of tokens 

**Description:** The `sellPoolTokens` function is intended to easily allow users to sell pool tokens and get WETH in exchange, Users are willing to specify the number of pool tokens `poolTokenAmount` they are willing to sell, However the function currently miscalculates the swapped amount 
This is due to the fact that the `swapExactOutput` function is called instead of the `swapExactInput`. Because the users specifies the number of input tokens 

**Impact:** Users will swap the wrong of amount of tokens, which is a severe functionality loss to the protocol

Consider changing the implementation to use `swapExactInput` instead of `swapExactOutput`. Note that this would also require changing the `sellPoolTokens` function to accept a new parameter (ie `minWethToReceive` to be passed to `swapExactInput`)

```diff
    function sellPoolTokens(
        uint256 poolTokenAmount,
+       uint256 minWethToReceive,    
        ) external returns (uint256 wethAmount) {
-        return swapExactOutput(i_poolToken, i_wethToken, poolTokenAmount, uint64(block.timestamp));
+        return swapExactInput(i_poolToken, poolTokenAmount, i_wethToken, minWethToReceive, uint64(block.timestamp));
    }
```

Additionally, it might be wise to add a deadline to the function, as there is currently no deadline. (MEV later)

### [H-4] In `TSwapPool::_swap` the extra tokens given to users after every `swapCount` breaks the protocol invariant of `x * y = k`

**Description:** The protocol follows a strict invariant of `x * y = k`. Where:
- `x`: The balance of the pool token
- `y`: The balance of WETH
- `k`: The constant product of the two balances

This means, that whenever the balances change in the protocol, the ratio between the two amounts should remain constant, hence the `k`. However, this is broken due to the extra incentive in the `_swap` function. Meaning that over time the protocol funds will be drained.

The follow block of code is responsible for the issue.

```javascript
        swap_count++;
        if (swap_count >= SWAP_COUNT_MAX) {
            swap_count = 0;
            outputToken.safeTransfer(msg.sender, 1_000_000_000_000_000_000);
        }
```

**Impact:** A user could maliciously drain the protocol of funds by doing a lot of swaps and collecting the extra incentive given out by the protocol.

Most simply put, the protocol's core invariant is broken.

**Proof of Concept:**
1. A user swaps 10 times, and collects the extra incentive of `1_000_000_000_000_000_000` tokens
2. That user continues to swap untill all the protocol funds are drained

<details>
<summary>Proof Of Code</summary>

Place the following into `TSwapPool.t.sol`.

```solidity

    function testInvariantBroken() public {
        vm.startPrank(liquidityProvider);
        weth.approve(address(pool), 100e18);
        poolToken.approve(address(pool), 100e18);
        pool.deposit(100e18, 100e18, 100e18, uint64(block.timestamp));
        vm.stopPrank();

        uint256 outputWeth = 1e17;

        vm.startPrank(user);
        poolToken.approve(address(pool), type(uint256).max);
        poolToken.mint(user, 100e18);
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));

        int256 startingY = int256(weth.balanceOf(address(pool)));
        int256 expectedDeltaY = int256(-1) * int256(outputWeth);

        pool.swapExactOutput(poolToken, weth, outputWeth, uint64(block.timestamp));
        vm.stopPrank();

        uint256 endingY = weth.balanceOf(address(pool));
        int256 actualDeltaY = int256(endingY) - int256(startingY);
        assertEq(actualDeltaY, expectedDeltaY);
    }
```

</details>

**Recommended Mitigation:** Remove the extra incentive mechanism. If you want to keep this in, we should account for the change in the x * y = k protocol invariant. Or, we should set aside tokens in the same way we do with fees.

```diff
-        swap_count++;
-        // Fee-on-transfer
-        if (swap_count >= SWAP_COUNT_MAX) {
-            swap_count = 0;
-            outputToken.safeTransfer(msg.sender, 1_000_000_000_000_000_000);
-        }
```
# Medium

### [M-1]: `TSwapPool::deposit()` is lacking a deadline check which causes the function to complete even after the deadline has passed

**Description:** The `deposit()` function accepts an argument deadline which according to the natspec ```@param deadline The deadline for the transaction to be completed by```. However this ```@param``` is never used as a consequence depositor is able to deposit even after the deadline has expired 

**Impact:** This can cause the deposit to take place at unfavourabke market conditions

**Proof of Concept:** Missing `deadline` check

**Recommended Mitigation:** 
```diff
function deposit(
        uint256 wethToDeposit,
        uint256 minimumLiquidityTokensToMint, 
        uint256 maximumPoolTokensToDeposit,
        uint64 deadline
    )
        external
+       revertIfDeadlinePassed(deadline)
        revertIfZero(wethToDeposit)
        returns (uint256 liquidityTokensToMint)
    {
```

# Low 

### [L-1]: The order the events are emitted is incorrect order in `TswapPool::LiquidityAdded` 

**Description:** when the `LiquidtyAdded` event is emitted in the `TSwapPool::_addLiquidityMintAndTransfer` function it logs values in an incorrect order. The `poolTokensToDeposit` value should be in the 3rd parameter position and the `wethToDeposit` should be in the 2nd parameter position

**Impact:** Event emission is incorrect which leads to offchain functions malfunctioning

**Recommended Mitigation:** 
```diff
- emit LiquidityAdded(msg.sender, poolTokensToDeposit, wethToDeposit);
+ emit LiquidityAdded(msg.sender, wethToDeposit, poolTokensToDeposit);
```

### [L-2]: Default value returned by `TSwapPool::swapExactInput()` which results in inccorct return value given 

**Description:** The `swapExactInput()` is expected to return the actual amount of tokens bought by the caller, but the return value output is declared by never assigned a value

**Impact:** The return value will always be 0

**Recommended Mitigation:** 
```diff
    function swapExactInput(
        IERC20 inputToken,
        uint256 inputAmount,
        IERC20 outputToken,
        uint256 minOutputAmount,
        uint64 deadline
    )
        public
        revertIfZero(inputAmount)
        revertIfDeadlinePassed(deadline)
        // @audit-low unused return value --> always returns 0
        returns (uint256 output)
    {
        uint256 inputReserves = inputToken.balanceOf(address(this));
        uint256 outputReserves = outputToken.balanceOf(address(this));

-        uint256 outputAmount = getOutputAmountBasedOnInput(
+        uint256 output = getOutputAmountBasedOnInput(
            inputAmount,
            inputReserves,
            outputReserves
        );

-        if (outputAmount < minOutputAmount) {
+        if (output < minOutputAmount) {
-            revert TSwapPool__OutputTooLow(outputAmount, minOutputAmount);
+            revert TSwapPool__OutputTooLow(output, minOutputAmount);    
        }

-        _swap(inputToken, inputAmount, outputToken, outputAmount);
+        _swap(inputToken, inputAmount, outputToken, output);
    }
```

# Informational  

### [I-1]: `PoolFactory__PoolDoesNotExist` error is not used and should be removed

```diff
- error PoolFactory__PoolDoesNotExist(address tokenAddress);
+ 
```

### [I-2]: `PoolFactory::Constructor()` lacks a zero address check

```diff
    constructor(address wethToken) {
+       if (wethToken == address(0)) revert;
        i_wethToken = wethToken;
    }
```

### [I-3]: Incorrect set of IERC20 Toekn Symbol in `PoolFactory::createPool()`

```diff
-  string memory liquidityTokenSymbol = string.concat("ts", IERC20(tokenAddress).name());
+  string memory liquidityTokenSymbol = string.concat("ts", IERC20(tokenAddress).symbol());
```

