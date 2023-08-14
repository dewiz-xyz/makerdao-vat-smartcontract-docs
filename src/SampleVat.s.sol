// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import {SampleVat} from "./SampleVat.sol";

contract SampleVatDeploy is Script {
    function run() external returns (SampleVat) {
        vm.startBroadcast();

        SampleVat tpl = new SampleVat();

        vm.stopBroadcast();

        return tpl;
    }
}