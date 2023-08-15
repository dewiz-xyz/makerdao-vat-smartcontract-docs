// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {Registry} from "./Registry.sol";
import {RegistryUtil} from "./ScriptUtil.sol";

//Denarius test
contract RegistryTest is Test {
    Registry internal template;
    address public contractAddressTest;
    string public contractNameTest;

    function setUp() public {
        contractAddressTest = address(0x860a714fc66Ee5b899cE816Bb5b1C88A11BC4c93);
        contractNameTest = "Denarius";
        template = new Registry();
        bytes memory tempContractName = bytes(contractNameTest);
        template.addContract(sha256(tempContractName), contractAddressTest);
    }

    function testFailBasicSanity() public {
        assertTrue(false);
    }

    function testBasicSanity() public {
        assertTrue(true);
    }

    function testFind() public {
        address contractAddress = template.lookUp(contractNameTest);
        console2.log("contractAddress: %s", contractAddress);
        assertEq(contractAddress, contractAddressTest);
    }
}
