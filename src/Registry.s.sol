// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {Registry} from "./Registry.sol";
import {RegistryUtil} from "./ScriptUtil.sol";

// ./scripts/forge-script.sh ./src/Registry.s.sol:RegistryDeploy --fork-url=$RPC_URL --broadcast -vvvv
contract RegistryDeploy is Script {
    function run() external returns (Registry) {
        vm.startBroadcast();

        Registry tpl = new Registry();
        vm.stopBroadcast();
        address registryAddress = address(tpl);
        vm.writeFile("./metadata/registry-address.txt", vm.toString(registryAddress));

        return tpl;
    }
}

// ./scripts/forge-script.sh ./src/Registry.s.sol:RegistryOnChainTest --fork-url ${ETH_RPC_URL} --broadcast -vvvv
contract RegistryOnChainTest is Script {
    function run() external view {
        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        // (bool success, address registryAddress) = RegistryUtil.getContractAddress("CenturionDai");
        console2.log("registryAddress: %s - %s", success, registryAddress);
        if (!success) {
            return;
        }
        Registry registry = Registry(registryAddress);
        console2.log("Num items: %s", success, registry.numItemsRecorded());
        console2.log("Vat address: %s", registry.lookUp("Vat"));
        console2.log("GemJoin address: %s", registry.lookUp("GemJoin"));
        console2.log("GemJoin-B address: %s", registry.lookUp("GemJoin-B"));
    }
}
