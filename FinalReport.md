# High

### [H-1]: Bad Exchange Rate in the `ThunderLoan::deposit` function causes a lock up of user funds which is caused by incorrect update of interest rate

**Description:** In the `ThunderLoan::deposit` function, the exchange rate is updated during the deposit of tokens to the contract by the user even when the no fee has been accumulated

**Impact:** There are several impacts of this issue:

1. The user's funds are locked up in the contract and the user is unable to withdraw their funds

2. The user when withdrawing their funds will not receive the correct amount of tokens

**POC:**
add the below code to the `ThunderLoan.t.sol` file

```solidity
function testRedeem() public setAllowedToken hasDeposits {
        uint256 amountToBorrow = AMOUNT * 100;
        uint256 calculatedFee = thunderLoan.getCalculatedFee(tokenA, amountToBorrow);
        vm.startPrank(user);
        tokenA.mint(address(mockFlashLoanReceiver), AMOUNT);
        thunderLoan.flashloan(address(mockFlashLoanReceiver), tokenA, amountToBorrow, "");
        vm.stopPrank();

        vm.prank(liquidityProvider);

        uint256 amountToRedeem = type(uint256).max;
        thunderLoan.redeem(tokenA, amountToRedeem);
    }
```

**Recommended Mitigation:** Remove the exchange rate update in the deposit function

```diff
    function deposit(
        IERC20 token,
        uint256 amount
        ) external revertIfZero(amount) revertIfNotAllowedToken(token) {
            AssetToken assetToken = s_tokenToAssetToken[token];
            uint256 exchangeRate = assetToken.getExchangeRate();
            uint256 mintAmount = (amount * assetToken.EXCHANGE_RATE_PRECISION()) /
                exchangeRate;
            emit Deposit(msg.sender, token, amount);
            assetToken.mint(msg.sender, mintAmount);

            // This will cause the funds to be locked in the contract
-           uint256 calculatedFee = getCalculatedFee(token, amount);
-           assetToken.updateExchangeRate(calculatedFee);

            // This is good the asset token contract is the owner of the underlying token
            token.safeTransferFrom(msg.sender, address(assetToken), amount);
    }
```

### [H-2]: The User after taking a flashloan can call the deposit function to deposit the borrowed token back to the contract and withdraw the underlying token causing a loss of funds

**Description:** 



# Medium

### [M-1]: Using TSwap as a price oracle is succeptible to price oracle attack where the price of the token to pay less fee

**Description:** In the `ThunderLoan::getCalculatedFee` function, the price of the token is fetched from the TSwap contract which is succeptible to price oracle attack where the price of the token is manipulated to pay less fee

**Impact:** Liquidity Providers will drastically reduce their earnings as the fee paid by the user is less than the actual fee

**POC:**
1. Due to the fact that the price is calculated using the TSwap contract, the attacker can manipulate the price of the token to pay less fee The below code is causing the issue

```solidity
function getCalculatedFee(
        IERC20 token,
        uint256 amount
    ) public view returns (uint256 fee) {
@>      uint256 valueOfBorrowedToken = (amount * getPriceInWeth(address(token))) /s_feePrecision;
        fee = (valueOfBorrowedToken * s_flashLoanFee) / s_feePrecision;
    }
```

**Recommended Mitigation:** The method that will be prefered is using a decentralised oracle like chainlink to get the priceFeed along with a Uniswap TWAP oracle that is resistent to the price feed manipulation using a flash loan

```diff
    function getCalculatedFee(
        IERC20 token,
        uint256 amount
    ) external view returns (uint256) {
        AssetToken assetToken = s_tokenToAssetToken[token];
        uint256 exchangeRate = assetToken.getExchangeRate();
        uint256 mintAmount = (amount * assetToken.EXCHANGE_RATE_PRECISION()) /
            exchangeRate;
        uint256 fee = mintAmount * s_fee / 10000;

        // This is succeptible to price oracle attack
```
