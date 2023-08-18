// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {RegistryUtil, Numbers} from "./ScriptUtil.sol";
import {Registry} from "./Registry.sol";
import {Denarius} from "./Denarius.sol";
import {Vat} from "dss/vat.sol";
import {Dai} from "dss/dai.sol";
import {GemJoin, DaiJoin} from "dss/join.sol";

//  ./scripts/forge-script.sh ./src/Operation.s.sol:Setup --fork-url=$RPC_URL --broadcast -vvvv
// contract Setup is Script {
//     Registry public registry;
//     Denarius public denarius;

//     uint256 public constant _RAY = 10 ** 27;
//     uint256 public constant _RAYDECIMALS = 27;

//     function run() external {
//         vm.startBroadcast();
//         _setRegistry();
//         _deployCollateral();
//         vm.stopBroadcast();
//     }

//     function _setRegistry() internal {
//         (, address registryAddress) = RegistryUtil.getRegistryAddress();
//         registry = Registry(registryAddress);
//     }

//     function _deployCollateral() internal {
//         denarius = new Denarius();
//         registry.setContractAddress("Denarius", address(denarius));
//     }
// }

//  ./scripts/forge-script.sh ./src/Operation.s.sol:Borrow --fork-url=$RPC_URL --broadcast -vvvv
contract Borrow is Script {
    Registry public registry;
    Vat public vat;
    Dai public dai;
    Denarius public denarius;
    GemJoin public gemJoin;
    DaiJoin public daiJoin;

    function run() external {
        uint256 valueToLock = 12 * 10**18;
        uint256 valueToDrawInDai = 5 * 10**18;

        vm.startBroadcast();

        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (!success) {
            console2.log("Error creating new Registry instance!");
            revert();
        }
        registry = Registry(registryAddress);
        gemJoin = GemJoin(registry.lookUp("GemJoin"));
        vat = Vat(registry.lookUp("SampleVat"));
        daiJoin = DaiJoin(registry.lookUp("DaiJoin"));
        dai = Dai(registry.lookUp("CenturionDai"));

        console2.log("Before - I am %s and my balance in Dai: %s", msg.sender, dai.balanceOf(msg.sender));

        gemJoin.join(msg.sender, valueToLock);

        (, uint256 rate, , , ) = vat.ilks("Denarius-A");
        uint256 dart = Numbers.divup(Numbers.mul(Numbers.ray(), valueToDrawInDai), rate);
        require(dart <= 2**255 - 1, "RwaUrn/overflow");
        uint256 dink = dart * 2;

        vat.frob(
            "Denarius-A", // ilk
            msg.sender,
            msg.sender,
            msg.sender, // To keep it simple, use your address for both `u`, `v` and `w`
            int256(dink), // with 10**18 precision
            int256(dart) // with 10**18 precision
        );

        daiJoin.exit(msg.sender, valueToDrawInDai);

        console2.log("dink: %d - dart: %d", dink, dart);
        console2.log("After - I am %s and my balance in Dai: %s", msg.sender, dai.balanceOf(msg.sender));

        vm.stopBroadcast();
    }
}

contract PayBack is Script {
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

        daiJoin.join(msg.sender, _VALUE_TO_PAYBACK);
        (, uint256 rate, , , ) = vat.ilks("Denarius-A");
        uint256 dart = Numbers.mul(Numbers.ray(), _VALUE_TO_PAYBACK) / rate;
        uint256 dink = dart * 2;
        require(dart <= 2**255 && dart <= 2**255, "RwaUrn/overflow");

        vat.frob("Denarius-A", msg.sender, msg.sender, msg.sender, -1, -1);

        console2.log("dink: %d - dart: %d", dink, dart);

        uint256 cBalance = dai.balanceOf(msg.sender);
        uint256 cEtherFormat = cBalance / (1 * 10**18);
        console2.log("Dai balance: %d - %d", cEtherFormat, cBalance);

        uint256 dBalance = denarius.balanceOf(msg.sender);
        uint256 dEtherFormat = dBalance / (1 * 10**18);
        console2.log("denarius balance: %d - %d", dEtherFormat, dBalance);

        vm.stopBroadcast();
    }
}

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

        (uint256 ink, uint256 art) = vat.urns("Denarius-A", msg.sender);
        console2.log("vat urn - ink: %d - art: %d", ink, art);

        // solhint-disable-next-line
        (uint256 Art, , , , ) = vat.ilks("Denarius-A");
        console2.log("Total Denarius-A ART: %d", Art);

        vm.stopBroadcast();
    }
}
