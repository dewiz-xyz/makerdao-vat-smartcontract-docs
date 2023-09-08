// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {RegistryUtil, Numbers} from "./ScriptUtil.sol";
import {Registry} from "./Registry.sol";
import {Denarius} from "./Denarius.sol";
import {Vat} from "dss/vat.sol";
import {Dai} from "dss/dai.sol";
import {GemJoin, DaiJoin} from "dss/join.sol";

// ./scripts/forge-script.sh ./src/Payback.s.sol:PayBackDenariusA --fork-url=$RPC_URL --broadcast -vvvv
contract PayBackDenariusA is Script {
    uint256 internal constant _VALUE_TO_PAYBACK = 2 * 10**18;

    function run() external {
        vm.startBroadcast();

        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (!success) {
            console2.log("Error creating new Registry instance!");
            revert();
        }
        Registry registry = Registry(registryAddress);
        Vat vat = Vat(registry.lookUp("Vat"));
        Dai dai = Dai(registry.lookUp("Dai"));
        Denarius denarius = Denarius(registry.lookUp("Denarius"));
        DaiJoin daiJoin = DaiJoin(registry.lookUp("DaiJoin"));
        GemJoin gemJoin = GemJoin(registry.lookUp("GemJoin"));

        daiJoin.join(msg.sender, _VALUE_TO_PAYBACK);
        (, uint256 rate, , , ) = vat.ilks("Denarius-A");
        uint256 dart = Numbers.mul(Numbers.ray(), _VALUE_TO_PAYBACK) / rate;
        uint256 dink = dart * 2;
        require(dart <= 2**255 && dart <= 2**255, "RwaUrn/overflow");

        int256 iDink = int256(dink) * -1;
        int256 iDart = int256(dart) * -1;

        vat.frob("Denarius-A", msg.sender, msg.sender, msg.sender, iDink, iDart);

        gemJoin.exit(msg.sender, _VALUE_TO_PAYBACK);

        console2.log("dink: %s", iDink);
        console2.log("dart: %s", iDart);

        uint256 cBalance = dai.balanceOf(msg.sender);
        uint256 cEtherFormat = cBalance / (1 * 10**18);
        console2.log("Dai balance: %d - %d", cEtherFormat, cBalance);

        uint256 dBalance = denarius.balanceOf(msg.sender);
        uint256 dEtherFormat = dBalance / (1 * 10**18);
        console2.log("denarius balance: %d - %d", dEtherFormat, dBalance);

        vm.stopBroadcast();
    }
}

// ./scripts/forge-script.sh ./src/Payback.s.sol:PayBackDenariusB --fork-url=$RPC_URL --broadcast -vvvv
contract PayBackDenariusB is Script {
    uint256 internal constant _VALUE_TO_PAYBACK = 2 * 10**18;

    function run() external {
        vm.startBroadcast();

        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (!success) {
            console2.log("Error creating new Registry instance!");
            revert();
        }
        Registry registry = Registry(registryAddress);
        Vat vat = Vat(registry.lookUp("Vat"));
        Dai dai = Dai(registry.lookUp("Dai"));
        Denarius denarius = Denarius(registry.lookUp("Denarius"));
        DaiJoin daiJoin = DaiJoin(registry.lookUp("DaiJoin"));
        GemJoin gemJoin = GemJoin(registry.lookUp("GemJoin-B"));

        daiJoin.join(msg.sender, _VALUE_TO_PAYBACK);
        (, uint256 rate, , , ) = vat.ilks("Denarius-B");
        uint256 dart = Numbers.mul(Numbers.ray(), _VALUE_TO_PAYBACK) / rate;
        uint256 dink = dart * 2;
        require(dart <= 2**255 && dart <= 2**255, "RwaUrn/overflow");

        int256 iDink = int256(dink) * -1;
        int256 iDart = int256(dart) * -1;

        vat.frob("Denarius-B", msg.sender, msg.sender, msg.sender, iDink, iDart);

        gemJoin.exit(msg.sender, _VALUE_TO_PAYBACK);

        console2.log("dink: %s", iDink);
        console2.log("dart: %s", iDart);

        uint256 cBalance = dai.balanceOf(msg.sender);
        uint256 cEtherFormat = cBalance / (1 * 10**18);
        console2.log("Dai balance: %d - %d", cEtherFormat, cBalance);

        uint256 dBalance = denarius.balanceOf(msg.sender);
        uint256 dEtherFormat = dBalance / (1 * 10**18);
        console2.log("denarius balance: %d - %d", dEtherFormat, dBalance);

        vm.stopBroadcast();
    }
}
