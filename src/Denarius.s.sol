// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Denarius} from "./Denarius.sol";

contract DenariusDeploy is Script {
    function run() external returns (Denarius) {
        vm.startBroadcast();

        Denarius tpl = new Denarius();

        vm.stopBroadcast();

        return tpl;
    }
}
