// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {CenturionDai} from "./Cent.sol";
import {RegistryUtil} from "./ScriptUtil.sol";
import {Registry} from "./Registry.sol";

//  ./scripts/forge-script.sh ./src/Cent.s.sol:CenturionDaiDeploy --fork-url=$RPC_URL --broadcast -vvvv
contract CenturionDaiDeploy is Script {
    function run() external returns (CenturionDai) {
        vm.startBroadcast();
        CenturionDai tpl = new CenturionDai();

        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (success) {
            Registry registry = Registry(registryAddress);
            registry.setContractAddress("CenturionDai", address(tpl));
        } else {
            console2.log("Error creating new Registry instance!");
        }

        vm.stopBroadcast();

        return tpl;
    }
}
