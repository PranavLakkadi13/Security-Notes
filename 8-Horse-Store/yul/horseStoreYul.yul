//  Binary representation:
//  603680600a5f395ff3fe5f3560e01c806367d41eca1460245763fe7e1be314601b575f80fd5b5f545f5260205ff35b602436106032576004355f55005b5f80fd


object "horseStoreYul" {
    code {
        // contract deployment code
        // the data copy keyword is like codecopy opcode
        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))
    }

    // basically the runtime code
    object "runtime" {
    code {
            // first we need to create the function dispatcher
            // we use the switch case for that (NOTE: selector() is a function that we will create and not a keyword)
            switch selector()

            // this is the case for the update horse number
            case 0x67d41eca {
                storeNumber(decodeAsUint(0))
            }

            // the function selector of read horse number
            case 0xfe7e1be3 {
                returnUint(readNumber())
            }

            default {
            revert(0,0)
            }

            function storeNumber(newNumber) {
                sstore(0, newNumber)
            }

            function readNumber() -> storedNumber{
                storedNumber := sload(0)
            }

            /* ---------- calldata decoding functions ----------- */
            // used to get the function selector
            function selector() -> s {
                s := div(calldataload(0), 0x100000000000000000000000000000000000000000000000000000000)
            }

            //
            function decodeAsUint(offset) -> v {
                let positionInCalldata := add(4, mul(offset, 0x20))

                if lt(calldatasize(), add(positionInCalldata, 0x20)) {
                    revert(0, 0)
                }

                v := calldataload(positionInCalldata)
            }

            // this is used to return the value
            function returnUint(v) {
                mstore(0, v)
                return(0, 0x20)
            }
       }
    }
}