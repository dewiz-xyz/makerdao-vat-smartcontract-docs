// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Dai} from "./dai.sol";

contract CenturionDai is Dai {
    constructor() Dai(1337) {}
}
