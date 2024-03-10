// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {HandlerStatefulFuzzCatches} from "../../../src/invariant-break/HandlerStatefulFuzzCatches.sol";

contract handler is Test {

    HandlerStatefulFuzzCatches handlerStatefulFuzzCatches;

    constructor (HandlerStatefulFuzzCatches _handlerStatefulFuzzCatches) {
        handlerStatefulFuzzCatches = _handlerStatefulFuzzCatches;
    }
}