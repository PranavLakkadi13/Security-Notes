# These are the simple lookout findings that I missed during my initial Days of Audit
# First Contest - 
    
    Jala Swap -- Here I missed the simple Permit function check 
        Here the permit function was used in the router contract and the permit function was present in the Pair contract or even the JalaWrappedERC20 contract that is the wrapped ERC20 token of Jala did not have the correct permit function implemented 

        Effect - Due to the above vulnerability a user who is using the permit function in the router will not be able to use the function/ the function will not do anything just revert 

    VVV vesting -- didnt have any payouts in the context but was able to identy 3/7 of the lead 
                    watson findings (@lllll)
                    one interesting issue was the vesting staking interest rate which can be changed by the owner of the contract
                    
                    Effect - Due to the changing staking rewards rate the owner can change the rate to a lower value the problem is that since the after rewards distribution the variable keeping track of the rewards is not updated so when the rewards to be distributed is calculated it will be calculated based on current rate and can effect the rewards of the users