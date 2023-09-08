// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {RegistryUtil, Numbers} from "./ScriptUtil.sol";
import {Registry} from "./Registry.sol";
import {Denarius} from "./Denarius.sol";
import {Vat} from "dss/vat.sol";
import {Dai} from "dss/dai.sol";
import {GemJoin, DaiJoin} from "dss/join.sol";

// ./scripts/forge-script.sh ./src/Operation.s.sol:InfoBalances --fork-url=$RPC_URL --broadcast -vvvv
contract InfoBalances is Script {
    function run() external {
        vm.startBroadcast();

        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (!success) {
            console2.log("Error creating new Registry instance!");
            revert("registry not found");
        }
        Registry registry = Registry(registryAddress);
        Vat vat = Vat(registry.lookUp("Vat"));
        Dai dai = Dai(registry.lookUp("Dai"));
        Denarius denarius = Denarius(registry.lookUp("Denarius"));

        uint256 cBalance = dai.balanceOf(msg.sender);
        uint256 cEtherFormat = cBalance / (1 * 10**18);
        console2.log("Dai balance: %d - %d", cEtherFormat, cBalance);

        uint256 dBalance = denarius.balanceOf(msg.sender);
        uint256 dEtherFormat = dBalance / (1 * 10**18);
        console2.log("denarius balance: %d - %d", dEtherFormat, dBalance);

        (uint256 inkA, uint256 artA) = vat.urns("Denarius-A", msg.sender);
        console2.log("Denarius-A - vat urn - ink: %d - art: %d", inkA, artA);

        (uint256 inkB, uint256 artB) = vat.urns("Denarius-B", msg.sender);
        console2.log("Denarius-B - vat urn - ink: %d - art: %d", inkB, artB);

        // solhint-disable-next-line
        (uint256 ArtA, , , , ) = vat.ilks("Denarius-A");
        console2.log("Total Denarius-A ART: %d", ArtA);

        // solhint-disable-next-line
        (uint256 ArtB, , , , ) = vat.ilks("Denarius-B");
        console2.log("Total Denarius-B ART: %d", ArtB);

        uint256 gemV = vat.gem("Denarius-A", msg.sender);
        console2.log("gemV Denarius-A: %d", gemV);

        gemV = vat.gem("Denarius-B", msg.sender);
        console2.log("gemV Denarius-B: %d", gemV);

        vm.stopBroadcast();
    }
}
