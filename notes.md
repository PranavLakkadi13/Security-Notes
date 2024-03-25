# Notes for testing(Fuzzing):

1. understand the invariant (The property of the code that should never change and always hold)
2. write a fuzz test for the invariant


# StateFull vs StateLess Fuzzing:

--> In Stateless fuzzing the state of the previous run is discarded for every new run and in StateFull fuzzing the final state of the previous fuzz run is used as the starting state for the current fuzz test

--> In Stateful Fuzzing there are 2 differnet types  of tests:
   i) Open Test - where we start with an empty state, and use the targetContract key word in foundry test imported from the 'forge-std/StdInvariant.sol' and specify the target contract address init. now when we test it will run a random sequece of function calls and then call the function on the test contract to check the assertion 

   ii) Handler Test - This is similar to the open test, but here we have a middleman contract called the handler which which will have functions which internally call the target contract functions and can combine multiple function calls into a single function and then the call can be made. The main advantage and the different between open and handler is that using the handler function as an intermediary caller we can reduce unnecessary function calls and just call the needed function basically helping to make a more precise function call. One Big Gotch is that u must not limit a lot functions as that could effect ur result.

   



# Important Points in Audits:

1. See and understand what the invariants are.....
2. Write functions tests to execute them

3. DOS attack:
   --> First, If There is a loop in the code, is it length bounded to a certain size, If not is then can a user add elements to the array to increase the loop compute cost if so will is it easy to add elements to array making it feasible to add so many items which can lead to DOS
   mostly a High or Crit
   --> Second, look for external calls either .call{}() or a external contract call and see if that call fails how does it effect my system?
   Causes :- i) sending ether to a contract that does not accept it
            ii) Caliing a function in a contract that doesnt exist
           iii) The external call execution runs out of gas (.send(), .transfer())
            iv) Third party contract is simply malicious


4. Its good to follow CEI to avoid re-enetrancy even though other methods exist like the   openzeppelin  (non-Reentrant modifier) but its a good method to follow the CEI 

5. Be carefull when evaluation an strictly == `address(this).balance` check since anyone can use the selfdestruct and force eth into a contract and create a DOS attack making the condition always false and there could be a loss in functionality



# Points About ABI (encode,packed etc):

1. abi.encode just encodes the peice of information to bytes/hex
   now using it we can get the function signature using that we can interact with functions

2. The Big difference between encode and encodePacked is that encode is like
   the perfect bytes version of the input that the EVM can understand whereas the
   encode packed version is the closer and similar version to the EVM bytes but
   removes unnecessary padding

3. ABI Encoding:
   abi.encode is a function that encodes its parameters using the ABI (Application Binary Interface) specifications. It is designed to make calls to contracts and pads parameters to 32 bytes. This function is typically used when you need to encode data to call a contract function or to pass data between contracts.

   Bytes Encoding:
   bytes is a dynamic array of bytes that can hold a sequence of bytes of any length. It is a data type that can be used to store and manipulate sequences of bytes. When you convert a string to bytes, you are essentially getting the UTF-8 encoded version of the string as a sequence of bytes.

4. abi.decode() cannot decode a input that is packed encoded rather to decode the
   bytes just typecast it into a string. since the when the string is
   packed encoded the compiler doesnt exactly know where to seperate the strings
   therefore it doesnt know how to decode packed encoding string



# Notes:-

1.  for any call that is done to the chain there is a data field that has to filled
    it has information like function call and its arguments or the bytecode

    case 1)
    When a contract is created, at a particular address the bytecode of the contract is
    stored at so that is in the data field during contract deployment.

    case 2)
    When a contract is live on the chain, and when a function call is made it is
    basically sending a function selector with any arguments to the contrcat address
    and the bytecode will see the function selector and perform the needed action
    with the arguments that were provided. This function signature is the data field
    in the call

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

    using the above example we can see low-level call to send value.

    with the above example we directly modified the value in the tranction like the above ethers example.

    ex1) The above example we can see the that call function has {} curly brackets and
    the passed arguments can be used to directly populate the transaction field
    like gasLimit,value etc

    ex2) The above example we can see that the call function has () curve brackets and
    in the brackets we can pass the function signature and call functions as data part of the transaction

    The low-level calls:-

    1. call: Will be used to call functions that change the state of the blockchain

    2. static-call: Will be used to call functions that do not change the state of blockchain, its like the low-level version of the "view" or "pure functions"

1. Proxies are a great way to upgrade the code of the contract but they have inherit risks and  other vulnerabilites and if the only one entity can make an upgrade that is centrality.

    The big difference is that the proxy contract is the main contract that stores the data and the implementation contract is the contract that has logic of the calls.

    The proxy internally uses delegatecall to read the internal details of the implentation and changes the state in the proxy contract

    In Proxy u also have to remember that it wont have a constructor so u have to use the initialized method and as per openzeppelin you are converting a function to give it the 
    features of the constructor and (NOTE: ALWAYS REMEMBER TO INITAILISE IT, IF U FAIL YOU CAN BE FRONTRUN!!!!) 

2.  SelfDestruct is a keyword in solidity, it is used to self destruct the contract and 
    remove the code from the chain and send a eth locked in to a address forcefully

    in the above example we can see that the contract in /src/SelfDestruct we have 2 contracts as example and see that in the attack contract we have the selfdestruct function that destroys the contract and forecefully sends the ether into the game and increases the balance which leads to the depositors having their money locked
    this attack function is now forcefully sending ether to the contract