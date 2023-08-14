// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {SampleVat} from "./SampleVat.sol";

contract SampleVatTest is Test {
    SampleVat internal template;

    function setUp() public {
        template = new SampleVat();
    }

    function testFailBasicSanity() public {
        assertTrue(false);
    }

    function testBasicSanity() public {
        assertTrue(true);
    }

    function testIsLive() public {
        uint256 isLive = 1;
        uint256 templateLive = uint256(template.live());
        assertEq(templateLive, isLive);
    }
}
