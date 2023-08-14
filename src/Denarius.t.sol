// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {Denarius} from "./Denarius.sol";

//Denarius test
contract DenariusTest is Test {
    Denarius internal template;
    address public sender;

    function setUp() public {
        sender = address(0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496);
        template = new Denarius();
    }

    function testFailBasicSanity() public {
        assertTrue(false);
    }

    function testBasicSanity() public {
        assertTrue(true);
    }

    function testBalance() public {
        uint256 supposedBalance = 1 * uint256(10**template.decimals());
        uint256 balance = template.balanceOf(sender);
        console2.log("Balances: %d - %d", supposedBalance, balance);
        assertEq(supposedBalance, balance);
    }
}
