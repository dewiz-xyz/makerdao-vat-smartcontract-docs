// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {SampleVat} from "./SampleVat.sol";
import {RegistryUtil} from "./ScriptUtil.sol";
import {Registry} from "./Registry.sol";

//  ./scripts/forge-script.sh ./src/SampleVat.s.sol:SampleVatDeploy --fork-url=$RPC_URL --broadcast -vvvv
contract SampleVatDeploy is Script {
    function run() external returns (SampleVat) {
        vm.startBroadcast();

        SampleVat tpl = new SampleVat();

        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (success) {
            Registry registry = Registry(registryAddress);
            registry.setContractAddress("SampleVat", address(tpl));
        } else {
            console2.log("Error creating new Registry instance!");
        }

        vm.stopBroadcast();

        return tpl;
    }
}

//  ./scripts/forge-script.sh ./src/SampleVat.s.sol:SampleVatInitialize --fork-url=$RPC_URL --broadcast -vvvv
contract SampleVatInitialize is Script {
    function run() external {
        vm.startBroadcast();
        Registry registry;
        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (!success) {
            console2.log("Error creating new Registry instance!");
            revert();
        }
        registry = Registry(registryAddress);
        address vatAddress = registry.lookUp("SampleVat");
        address gemjoin = registry.lookUp("GemJoin");
        address dai = registry.lookUp("CenturionDai");

        SampleVat vat = SampleVat(vatAddress);
        vat.rely(gemjoin);
        vat.rely(dai);

        vm.stopBroadcast();
    }
}
