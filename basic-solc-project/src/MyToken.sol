// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {

    constructor(string memory _name, string memory _sign) ERC20(_name,_sign) {
        _mint(msg.sender,10_000 * 10 ** decimals());
    }

}