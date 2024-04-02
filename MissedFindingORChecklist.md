# These are the simple lookout findings that I missed during my initial Days of Audit
# First Contest - 
    Jala Swap -- Here I missed the simple Permit function check 
        Here the permit function was used in the router contract and the permit function was present in the Pair contract or even the JalaWrappedERC20 contract that is the wrapped ERC20 token of Jala did not have the correct permit function implemented 

        Effect - Due to the above vulnerability a user who is using the permit function in the router will not be able to use the function/ the function will not do anything just revert 