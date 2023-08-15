// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {Denarius} from "./Denarius.sol";
import {RegistryUtil} from "./ScriptUtil.sol";
import {Registry} from "./Registry.sol";

//  ./scripts/forge-script.sh ./src/Denarius.s.sol:DenariusDeploy --fork-url=$RPC_URL --broadcast -vvvv
contract DenariusDeploy is Script {
    function run() external returns (Denarius) {
        vm.startBroadcast();

        Denarius tpl = new Denarius();

        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (success) {
            Registry registry = Registry(registryAddress);
            registry.setContractAddress("Denarius", address(tpl));
        } else {
            console2.log("Error creating new Registry instance!");
        }

        vm.stopBroadcast();

        return tpl;
    }
}
