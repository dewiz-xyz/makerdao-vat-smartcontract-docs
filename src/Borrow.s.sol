// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {RegistryUtil, Numbers} from "./ScriptUtil.sol";
import {Registry} from "./Registry.sol";
import {Denarius} from "./Denarius.sol";
import {Vat} from "dss/vat.sol";
import {Dai} from "dss/dai.sol";
import {GemJoin, DaiJoin} from "dss/join.sol";

//  ./scripts/forge-script.sh ./src/Borrow.s.sol:BorrowDenariusA --fork-url=$RPC_URL --broadcast -vvvv
contract BorrowDenariusA is Script {
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
            // solhint-disable no-console
            console2.log("Error creating new Registry instance!");
            revert("Error creating new Registry instance!");
        }
        registry = Registry(registryAddress);
        gemJoin = GemJoin(registry.lookUp("GemJoin"));
        vat = Vat(registry.lookUp("Vat"));
        daiJoin = DaiJoin(registry.lookUp("DaiJoin"));
        dai = Dai(registry.lookUp("Dai"));

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

//  ./scripts/forge-script.sh ./src/Borrow.s.sol:BorrowDenariusB --fork-url=$RPC_URL --broadcast -vvvv
contract BorrowDenariusB is Script {
    Registry public registry;
    Vat public vat;
    Dai public dai;
    Denarius public denarius;
    GemJoin public gemJoin;
    DaiJoin public daiJoin;

    function run() external {
        uint256 valueToLock = 10 * 10**18;
        uint256 valueToDrawInDai = 5 * 10**18;

        vm.startBroadcast();

        (bool success, address registryAddress) = RegistryUtil.getRegistryAddress();
        if (!success) {
            // solhint-disable no-console
            console2.log("Error creating new Registry instance!");
            revert("Error creating new Registry instance!");
        }
        registry = Registry(registryAddress);
        gemJoin = GemJoin(registry.lookUp("GemJoin-B"));
        vat = Vat(registry.lookUp("Vat"));
        daiJoin = DaiJoin(registry.lookUp("DaiJoin"));
        dai = Dai(registry.lookUp("Dai"));

        console2.log("Before - I am %s and my balance in Dai: %s", msg.sender, dai.balanceOf(msg.sender));

        gemJoin.join(msg.sender, valueToLock);

        (, uint256 rate, , , ) = vat.ilks("Denarius-B");
        uint256 dart = Numbers.divup(Numbers.mul(Numbers.ray(), valueToDrawInDai), rate);
        require(dart <= 2**255 - 1, "RwaUrn/overflow");
        uint256 dink = dart * 2;

        vat.frob(
            "Denarius-B", // ilk
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
