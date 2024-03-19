// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract AssetToken is ERC20 {
    error AssetToken__onlyThunderLoan();
    error AssetToken__ExhangeRateCanOnlyIncrease(uint256 oldExchangeRate, uint256 newExchangeRate);
    error AssetToken__ZeroAddress();

    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    IERC20 private immutable i_underlying;
    address private immutable i_thunderLoan;

    // The underlying per asset exchange rate
    // ie: s_exchangeRate = 2
    // means 1 asset token is worth 2 underlying tokens
    
    // e assetToken = shares 
    // e underlying = collateral(token deposited eg. DAI, USDC, USDT, etc.)
    uint256 private s_exchangeRate;
    uint256 public constant EXCHANGE_RATE_PRECISION = 1e18;
    uint256 private constant STARTING_EXCHANGE_RATE = 1e18;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event ExchangeRateUpdated(uint256 newExchangeRate);

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier onlyThunderLoan() {
        if (msg.sender != i_thunderLoan) {
            revert AssetToken__onlyThunderLoan();
        }
        _;
    }

    modifier revertIfZeroAddress(address someAddress) {
        if (someAddress == address(0)) {
            revert AssetToken__ZeroAddress();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    constructor(
        address thunderLoan,
        // q: why is the underlying token passed, is to to help track the collateral/asset pool?
        // q: where are the actual tokens deposited? is it in the thunderLoan contract?
        IERC20 underlying, // it is the collateral token 
        string memory assetName,
        string memory assetSymbol
    )
        ERC20(assetName, assetSymbol)
        revertIfZeroAddress(thunderLoan)
        revertIfZeroAddress(address(underlying))
    {
        i_thunderLoan = thunderLoan;
        i_underlying = underlying;

        // @audit - the exchange rate is set to 1:1 at deployment instead of 1:2
        s_exchangeRate = STARTING_EXCHANGE_RATE;
    }

    function mint(address to, uint256 amount) external onlyThunderLoan {
        _mint(to, amount);
    }

    function burn(address account, uint256 amount) external onlyThunderLoan {
        _burn(account, amount);
    }

    function transferUnderlyingTo(address to, uint256 amount) external onlyThunderLoan {
        // q: weird ERC20s ?? like usdc is used 
        // q: what happens if USDC blacklists the contract?
        // q: what happens if USDC is upgraded to a new version?
        // q: what happens if USDC is paused?
        // q: @followup 
        i_underlying.safeTransfer(to, amount);
    }

    function updateExchangeRate(uint256 fee) external onlyThunderLoan {
        // 1. Get the current exchange rate
        // 2. How big the fee is should be divided by the total supply
        // 3. So if the fee is 1e18, and the total supply is 2e18, the exchange rate be multiplied by 1.5
        // if the fee is 0.5 ETH, and the total supply is 4, the exchange rate should be multiplied by 1.125
        // it should always go up, never down //// INVARIENT
        // newExchangeRate = oldExchangeRate * (totalSupply + fee) / totalSupply
        // newExchangeRate = 1 (4 + 0.5) / 4
        // newExchangeRate = 1.125

        // @audit what if the total supply is 0?
        // @audit how does change in exchange rate midway affect the users?
        uint256 newExchangeRate = s_exchangeRate * (totalSupply() + fee) / totalSupply();

        if (newExchangeRate <= s_exchangeRate) {
            revert AssetToken__ExhangeRateCanOnlyIncrease(s_exchangeRate, newExchangeRate);
        }
        s_exchangeRate = newExchangeRate;
        emit ExchangeRateUpdated(s_exchangeRate);
    }

    function getExchangeRate() external view returns (uint256) {
        return s_exchangeRate;
    }

    function getUnderlying() external view returns (IERC20) {
        return i_underlying;
    }
}
