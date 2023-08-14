// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import "./Cent.sol";

contract CenturionDaiDeploy is Script {
    function run() external returns (CenturionDai) {
        vm.startBroadcast();

        CenturionDai tpl = new CenturionDai();

        vm.stopBroadcast();

        return tpl;
    }
}