
// 0x6080604052348015600e575f80fd5b5060a580601a5f395ff3fe6080604052348015600e575f80fd5b50600436106030575f3560e01c806367d41eca146034578063fe7e1be3146045575b5f80fd5b6043603f3660046059565b5f55565b005b5f5460405190815260200160405180910390f35b5f602082840312156068575f80fd5b503591905056fea26469706673582212200a8e9be3c75ac3dc1144d276467b5ee6e3a6388773f744b01feea58571845ac864736f6c63430008190033

// used as the free memory pointer
PUSH1 0x80          // [0x80]     // since memory is an array of 32 bytes, 32 bytes in hex is 0x20 in solidity first 64 bytes are reserved for hashing stuff
PUSH1 0x40          // [0x40,0x80]  // 0x40 is a place usually reserved to show which index of the memory array is free so according to this 0x80-> 128bytes (4 index) is free
MSTORE              // []    Memory: [0x40 -> 0x80]


// checks the msg.value
// here the call reverts if the value is more than 0
CALLVALUE           // [msg.value]    // checks the value of the transaction
DUP1                // [msg.value, msg.value]  // duplicates the value of the transaction
ISZERO              // [msg.value == 0 , msg.value]    // checks if the value of the transaction is zero
PUSH1 0x0e          // [0x0e, msg.value == 0 , msg.value]  // 0x0e is the program counter to jump to if the value of the transaction is 1
JUMPI               // [msg.value]
PUSH0               // [0x00, msg.value]
DUP1                // [0x00,0x00, msg.value]
REVERT              // [msg.value]

// this is the jump destination for the above jump opcode  if the boolean of iszero had returned true
JUMPDEST            // [msg.value]
POP                 // []    // pops the value of the transaction
PUSH1 0xa5          // [0xa5]
DUP1                // [0xa5, 0xa5]
PUSH1 0x1a          // [0x1a, 0xa5, 0xa5]
PUSH0               // [0x00, 0x1a, 0xa5, 0xa5]
CODECOPY            // [0xa5]
PUSH0               // [0x00, 0xa5]  Memory: [runtime Code]
// if you observe when the create opcode is called the runtime code is copied to the memory array and then returned
// here the return is doing the same thing only difference being that the value of wei being sent is 0
RETURN
// this indicates that its the ned of the contract creation
INVALID

// Runtime Code

// Free Memory Pointer
PUSH1 0x80          // [0x80]
PUSH1 0x40          // [0x40, 0x80]
MSTORE              // []    Memory: [0x40 -> 0x80]

CALLVALUE           // [msg.value]  Memory: [0x40 -> 0x80]
DUP1                // [msg.value, msg.value]  Memory: [0x40 -> 0x80]
ISZERO              // [msg.value == 0, msg.value]  Memory: [0x40 -> 0x80]
PUSH1 0x0e          // [0x0e, msg.value == 0, msg.value]  Memory: [0x40 -> 0x80]
JUMPI               // [msg.value]  Memory: [0x40 -> 0x80]

// executed only if msg.value != 0
PUSH0               // [0x00, msg.value]  Memory: [0x40 -> 0x80]
DUP1                // [0x00, 0x00, msg.value]  Memory: [0x40 -> 0x80]
REVERT              // [msg.value]  Memory: [0x40 -> 0x80]

// The jump destination for the above JUMPI opcode when msg.value == 0
// this part of the code is used to check the calldata size is > 4 bytes to make sure its valid since min 4 bytes are required to call the function
JUMPDEST            // [msg.value]  Memory: [0x40 -> 0x80]
POP                 // []  Memory: [0x40 -> 0x80]
PUSH1 0x04          // [0x04]  Memory: [0x40 -> 0x80]
CALLDATASIZE        // [calldata_size,0x04]  Memory: [0x40 -> 0x80]
LT                  // [calldata_size < 0x04]  Memory: [0x40 -> 0x80]
PUSH1 0x30          // [0x30, calldata_size < 0x04]  Memory: [0x40 -> 0x80]
JUMPI               // []  Memory: [0x40 -> 0x80]

// this is the function dispatching part of the code
PUSH0               // [0x00]  Memory: [0x40 -> 0x80]
CALLDATALOAD        // [32 bytes calldata]  Memory: [0x40 -> 0x80]
PUSH1 0xe0          // [0xe0, 32 bytes calldata]  Memory: [0x40 -> 0x80]
SHR                 // [func selector]  Memory: [0x40 -> 0x80]
DUP1                // [func selector, func selector]  Memory: [0x40 -> 0x80]

// this part is the update horse function  dispatching
PUSH4 0x67d41eca    // [0x67d41eca, func selector, func selector]  Memory: [0x40 -> 0x80]
EQ                  // [func selector == 0x67d41eca, func selector]  Memory: [0x40 -> 0x80]
PUSH1 0x34          // [0x34, func selector == 0x67d41eca, func selector]  Memory: [0x40 -> 0x80]
JUMPI               // [func selector]  Memory: [0x40 -> 0x80]
// here the execution will dup to the eq func_selector and update the code

// this part is to read the horse number dispatching part
DUP1                // [func selector, func selector]  Memory: [0x40 -> 0x80]
PUSH4 0xfe7e1be3    // [0xfe7e1be3, func selector, func selector]  Memory: [0x40 -> 0x80]
EQ                  // [func selector == 0xfe7e1be3, func selector]  Memory: [0x40 -> 0x80]
PUSH1 0x45          // [0x45, func selector == 0xfe7e1be3, func selector]  Memory: [0x40 -> 0x80]
JUMPI               // [func selector]  Memory: [0x40 -> 0x80]
// here the execution will dup to the eq func_selector to read the code
// also if u see below we can see that if the func_selector doesnt match to the above that means an inexisting function is called
// so the the code will keep executing till it reverts as u see in the next 4 opcodes

// this is the part that is executed when the calldata size is less than 4 bytes
// this part revert the transaction since its a invalid call
JUMPDEST        // []  Memory: [0x40 -> 0x80]
PUSH0           // [0x00]  Memory: [0x40 -> 0x80]
DUP1            // [0x00, 0x00]  Memory: [0x40 -> 0x80]
REVERT          // []  Memory: [0x40 -> 0x80]

// This is the jump destination for the update horse function (part 1)
// most of this part sets up the program counters
JUMPDEST        // [func_selector]  Memory: [0x40 -> 0x80]
PUSH1 0x43      // [0x43, func_selector]  Memory: [0x40 -> 0x80]
PUSH1 0x3f      // [0x3f, 0x43, func_selector]  Memory: [0x40 -> 0x80]
CALLDATASIZE    // [calldata_size, 0x3f, 0x43, func_selector]  Memory: [0x40 -> 0x80]
PUSH1 0x04      // [0x04, calldata_size, 0x3f, 0x43, func_selector]  Memory: [0x40 -> 0x80]
PUSH1 0x59      // [0x59, 0x04, calldata_size, 0x3f, 0x43, func_selector]  Memory: [0x40 -> 0x80]
// This opcode basically jumps to the most recently pushed value on stack which is a program counter
JUMP            // [0x04, calldata_size, 0x3f, 0x43, func_selector]  Memory: [0x40 -> 0x80]

// This is the jump destination for the update horse function (part 4)
JUMPDEST        // [calldata_minus_func_selector, 0x43, func_selector]  Memory: [0x40 -> 0x80]
PUSH0           // [0x00, calldata_minus_func_selector, 0x43, func_selector]  Memory: [0x40 -> 0x80]
SSTORE          // [0x43, func_selector]  Memory: [0x40 -> 0x80] Storage: [0x00 -> calldata_minus_func_selector]
JUMP            // [func_selector]  Memory: [0x40 -> 0x80]

// This is the jump destination for the update horse function (part 5)
JUMPDEST        // [func_selector]  Memory: [0x40 -> 0x80]
STOP
JUMPDEST
PUSH0
SLOAD
PUSH1 0x40
MLOAD
SWAP1
DUP2
MSTORE
PUSH1 0x20
ADD
PUSH1 0x40
MLOAD
DUP1
SWAP2
SUB
SWAP1
RETURN

// This is the jump destination for the update horse function (part 2)
JUMPDEST            // [0x04, calldata_size, 0x3f, 0x43, func_selector]  Memory: [0x40 -> 0x80]
PUSH0               // [0x00, 0x04, calldata_size, 0x3f, 0x43, func_selector]  Memory: [0x40 -> 0x80]
PUSH1 0x20          // [0x20, 0x00, 0x04, calldata_size, 0x3f, 0x43, func_selector]  Memory: [0x40 -> 0x80]
DUP3                // [0x04, 0x20, 0x00, 0x04, calldata_size, 0x3f, 0x43, func_selector]  Memory: [0x40 -> 0x80]
DUP5                // [calldata_size, 0x04, 0x20, 0x00, 0x04, calldata_size, 0x3f, 0x43, func_selector]  Memory: [0x40 -> 0x80]
SUB                 // [calldata_size - 0x04, 0x20, 0x00, 0x04, calldata_size, 0x3f, 0x43, func_selector]  Memory: [0x40 -> 0x80]
SLT                 // [calldata_size - 0x04 < 0x20, 0x00, 0x04, calldata_size, 0x3f, 0x43, func_selector]  Memory: [0x40 -> 0x80]
// the above SLT opcode is used to check if the calldata size is less than 32 bytes
ISZERO              // [calldata_size - 0x04 < 0x20 == true, 0x00, 0x04, calldata_size, 0x3f, 0x43, func_selector]  Memory: [0x40 -> 0x80]
// if the calldata size is less than 32 bytes then it jumps to the jump destination 0x68 (program counter)
// that looks like if the data size is bigger than 32bytes it will revert due to overflow of memory
PUSH1 0x68          // [0x68, calldata_size - 0x04 < 0x20 == true, 0x00, 0x04, calldata_size, 0x3f, 0x43, func_selector]  Memory: [0x40 -> 0x80]
// if the bool returned is 1 then jump else , continue the execution till revert 3 opcodes later
JUMPI               //  [0x00, 0x04, calldata_size, 0x3f, 0x43, func_selector]  Memory: [0x40 -> 0x80]


PUSH0               // [0x00, 0x00, 0x04, calldata_size, 0x3f, 0x43, func_selector]  Memory: [0x40 -> 0x80]
DUP1                // [0x00, 0x00, 0x00, 0x04, calldata_size, 0x3f, 0x43, func_selector]  Memory: [0x40 -> 0x80]
REVERT              // [0x00, 0x04, calldata_size, 0x3f, 0x43, func_selector]  Memory: [0x40 -> 0x80]


// This is the jump destination for the update horse function (part 3)
// the main aim was to grab the call data to update the horse store variable
JUMPDEST            //  [0x00, 0x04, calldata_size, 0x3f, 0x43, func_selector]  Memory: [0x40 -> 0x80]
POP                 //  [0x04, calldata_size, 0x3f, 0x43, func_selector]  Memory: [0x40 -> 0x80]
CALLDATALOAD        //  [calldata_minus_func_selector, calldata_size, 0x3f, 0x43, func_selector]  Memory: [0x40 -> 0x80]
SWAP2               //  [0x3f, calldata_size, calldata_minus_func_selector, 0x43, func_selector]  Memory: [0x40 -> 0x80]
SWAP1               //  [calldata_size, 0x3f, calldata_minus_func_selector, 0x43, func_selector]  Memory: [0x40 -> 0x80]
POP                 //  [0x3f, calldata_minus_func_selector, 0x43, func_selector]  Memory: [0x40 -> 0x80]
JUMP                //  [calldata_minus_func_selector, 0x43, func_selector]  Memory: [0x40 -> 0x80]
INVALID
LOG2
PUSH5 0x6970667358
INVALID
SLT
KECCAK256
EXP
DUP15
SWAP12
INVALID
INVALID
GAS
INVALID
INVALID
GT
PREVRANDAO
INVALID
PUSH23 0x467b5ee6e3a6388773f744b01feea58571845ac864736f
PUSH13 0x63430008190033