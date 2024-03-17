# High

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

