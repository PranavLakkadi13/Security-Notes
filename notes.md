Notes for testing(Fuzzing):
1) understand the invariant (The property of the code that should never change and always hold)
2) write a fuzz test for the invariant 



StateFull vs StateLess Fuzzing:

--> In Stateless fuzzing the state of the previous run is discarded for every new run and in StateFull fuzzing the final state of the previous fuzz run is used as the starting state for the current fuzz test 



Important Points in Audits:
1) See and understand what the invariants are.....
2) Write functions tests to execute them




Points About ABI (encode,packed etc):
1) abi.encode just encodes the peice of information to bytes/hex
   now using it we can get the function signature using that we can interact with functions

2) The Big difference between encode and encodePacked is that encode is like 
   the perfect bytes version of the input that the EVM can understand whereas the 
   encode packed version is the closer and similar version to the EVM bytes but 
   removes unnecessary padding 

3) abi.encode is a function that encodes its parameters using the ABI (Application Binary Interface) specifications. It is designed to make calls to contracts and pads parameters to 32 bytes. This function is typically used when you need to encode data to call a contract function or to pass data between contracts.

bytes is a dynamic array of bytes that can hold a sequence of bytes of any length. It is a data type that can be used to store and manipulate sequences of bytes. When you convert a string to bytes, you are essentially getting the UTF-8 encoded version of the string as a sequence of bytes 23.