// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {DaiJoin} from "dss/join.sol";
import {RegistryUtil} from "./ScriptUtil.sol";
import {Registry} from "./Registry.sol";
import {CenturionDai} from "./Cent.sol";
import {SampleVat} from "./SampleVat.sol";

//  ./scripts/forge-script.sh ./src/DaiJoin.s.sol:DaiJoinDeploy --fork-url=$RPC_URL --broadcast -vvvv
contract DaiJoinDeploy is Script {
    function run() external {
        vm.startBroadcast();

        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (!success) {
            console2.log("Error creating new Registry instance!");
            revert();
        }
        Registry registry = Registry(registryAddress);
        address vat = registry.lookUp("SampleVat");
        address dai = registry.lookUp("CenturionDai");

        DaiJoin tpl = new DaiJoin(vat, dai);

        registry.setContractAddress("DaiJoin", address(tpl));

        vm.stopBroadcast();
    }
}

//  ./scripts/forge-script.sh ./src/DaiJoin.s.sol:DaiJoinReceiveAllowance --fork-url=$RPC_URL --broadcast -vvvv
contract DaiJoinReceiveAllowance is Script {
    function run() external {
        vm.startBroadcast();

        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (!success) {
            console2.log("Error creating new Registry instance!");
            revert();
        }
        Registry registry = Registry(registryAddress);
        address daiJoinAddress = registry.lookUp("DaiJoin");
        address daiAddress = registry.lookUp("CenturionDai");
        address vatAddress = registry.lookUp("SampleVat");

        CenturionDai dai = CenturionDai(daiAddress);
        SampleVat vat = SampleVat(vatAddress);

        dai.approve(daiJoinAddress, type(uint256).max);
        dai.rely(daiJoinAddress);
        vat.hope(daiJoinAddress);

        vm.stopBroadcast();
    }
}
