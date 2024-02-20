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


3) 
   ABI Encoding:
   abi.encode is a function that encodes its parameters using the ABI (Application Binary Interface) specifications. It is designed to make calls to contracts and pads parameters  to 32 bytes. This function is typically used when you need to encode data to call a contract function or to pass data between contracts.

   Bytes Encoding:
   bytes is a dynamic array of bytes that can hold a sequence of bytes of any length. It is a data type that can be used to store and manipulate sequences of bytes. When you convert a string to bytes, you are essentially getting the UTF-8 encoded version of the string as a sequence of bytes.


4) abi.decode() cannot decode a input that is packed encoded rather to decode the 
   bytes just typecast it into a string. since the when the string is 
   packed encoded the compiler doesnt exactly know where to seperate the strings 
   therefore it doesnt know how to decode packed encoding string






Notes:-

1) for any call that is done to the chain there is a data field that has to filled 
   it has information like function call and its arguments or the bytecode

   --> The below is the fields that are filled during a transaction 
   const tx = {
       nonce : Nonce,
       gasPrice : 20000000000,
       gasLimit: 1000000,
       to: null, // since it is contract creation 
       value: 0, // since no value is being sent
       data : bytecode,// data is the binary or bytecode of the contract    
       chainId: 5777, // network Id each blockchain has its unique id 
   }

   v,r,s the fields for verifying the signature are virified using ethers internally

   example :- address.call{value : 100}("");
   using

   case 1)
   When a contract is created, at a particular address the bytecode of the contract is 
   stored at so that is in the data field during contract deployment.

   case 2) 
   When a contract is live on the chain, and when a function call is made it is 
   basically sending a function selector with any arguments to the contrcat address 
   and the bytecode will see the function selector and perform the needed action
   with the arguments that were provided. This function signature is the data field 
   in the call 

