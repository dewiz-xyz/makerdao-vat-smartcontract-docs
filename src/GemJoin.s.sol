// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {GemJoin} from "dss/join.sol";
import {RegistryUtil} from "./ScriptUtil.sol";
import {Registry} from "./Registry.sol";

//  ./scripts/forge-script.sh ./src/GemJoin.s.sol:GemJoinDeploy --fork-url=$RPC_URL --broadcast -vvvv
contract GemJoinDeploy is Script {
    function run() external {
        vm.startBroadcast();

        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (!success) {
            console2.log("Error creating new Registry instance!");
            revert();
        }
        Registry registry = Registry(registryAddress);
        address vat = registry.lookUp("SampleVat");
        address denarius = registry.lookUp("Denarius");

        GemJoin tpl = new GemJoin(vat, "Denarius-A", denarius);

        registry.setContractAddress("GemJoin", address(tpl));

        vm.stopBroadcast();
    }
}
