### [H-1] REentrancy in `PuppyRaffle::refund()`

**Description** 




### [M-] Looping through the loop to check for duplicates in the `enterRaffle()` can cause DOS,Incrementing gas cost for future entrants

**Description**
The `PuppyRaffle::enterRaffle()` function loops through the entire players array to check for duplicates however the longer the array the most the gas it costs for a user to join enter the raffle

**Impact**
