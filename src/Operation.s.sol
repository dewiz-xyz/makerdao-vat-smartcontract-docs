// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {SampleVat} from "./SampleVat.sol";
import {RegistryUtil, Numbers} from "./ScriptUtil.sol";
import {Registry} from "./Registry.sol";
import {CenturionDai} from "./Cent.sol";
import {Denarius} from "./Denarius.sol";
import {GemJoin, DaiJoin} from "dss/join.sol";

//  ./scripts/forge-script.sh ./src/Operation.s.sol:Setup --fork-url=$RPC_URL --broadcast -vvvv
contract Setup is Script {
    Registry public registry;
    SampleVat public vat;
    CenturionDai public dai;
    Denarius public denarius;
    GemJoin public gemJoin;
    DaiJoin public daiJoin;

    uint256 constant _RAY = 10**27;
    uint256 constant _RAYDECIMALS = 27;

    function run() external {
        vm.startBroadcast();
        _deployRegistry();
        _deployVat();
        _deployDai();
        _deployCollateral();
        _deployGemJoin();
        _deployDaiJoin();
        _vatInitialization();
        vm.stopBroadcast();
    }

    function _deployRegistry() internal {
        registry = new Registry();
        address registryAddress = address(registry);
        vm.writeFile("./metadata/registry-address.txt", vm.toString(registryAddress));
    }

    function _deployVat() internal {
        vat = new SampleVat();
        registry.setContractAddress("SampleVat", address(vat));
    }

    function _deployDai() internal {
        dai = new CenturionDai();
        registry.setContractAddress("CenturionDai", address(dai));
    }

    function _deployCollateral() internal {
        denarius = new Denarius();
        registry.setContractAddress("Denarius", address(denarius));
    }

    function _deployGemJoin() internal {
        gemJoin = new GemJoin(address(vat), "Denarius-A", address(denarius));
        registry.setContractAddress("GemJoin", address(gemJoin));
        denarius.approve(address(gemJoin), type(uint256).max);
    }

    function _deployDaiJoin() internal {
        daiJoin = new DaiJoin(address(vat), address(dai));
        registry.setContractAddress("DaiJoin", address(daiJoin));
        dai.approve(address(daiJoin), type(uint256).max);
        dai.rely(address(daiJoin));
        vat.hope(address(daiJoin));
    }

    function _vatInitialization() internal {
        uint256 price = 616;
        uint256 numDigitsBelowOneAndPositive = 2;
        vat.rely(address(gemJoin));
        vat.rely(address(dai));
        vat.init("Denarius-A");
        vat.file("Line", 1_000_000 * 10**45);
        vat.file("Denarius-A", "line", 1_000_000 * 10**45);
        // vat.file("Denarius-A", "spot", 1 * 10**27);
        vat.file("Denarius-A", "spot", price * 10**(_RAYDECIMALS - numDigitsBelowOneAndPositive)); //Actual price of MATIC 2023-08-16 - 0.616 USD
    }
}

//  ./scripts/forge-script.sh ./src/Operation.s.sol:Borrow --fork-url=$RPC_URL --broadcast -vvvv
contract Borrow is Script {
    Registry public registry;
    SampleVat public vat;
    CenturionDai public dai;
    Denarius public denarius;
    GemJoin public gemJoin;
    DaiJoin public daiJoin;
    uint256 constant _RAY = 10**27;

    function _add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }

    function _sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }

    function _mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function _divup(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = _add(x, _sub(y, 1)) / y;
    }

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
        vat = SampleVat(registry.lookUp("SampleVat"));
        daiJoin = DaiJoin(registry.lookUp("DaiJoin"));
        dai = CenturionDai(registry.lookUp("CenturionDai"));

        console2.log("Before - I am %s and my balance in Dai: %s", msg.sender, dai.balanceOf(msg.sender));

        gemJoin.join(msg.sender, valueToLock);

        (, uint256 rate, , , ) = vat.ilks("Denarius-A");
        uint256 dart = _divup(_mul(_RAY, valueToDrawInDai), rate);
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