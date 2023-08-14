// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Dai} from "./dai.sol";

contract CenturionDai is Dai {
    constructor() Dai(1337) {
        uint256 balance = 1000 * uint256(10**decimals);
        balanceOf[msg.sender] = add(balanceOf[msg.sender], balance);
        totalSupply = add(totalSupply, balance);
        emit Transfer(address(0), msg.sender, balance);
    }
}
