// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Permit} from "openzeppelin/token/ERC20/extensions/ERC20Permit.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";

contract Denarius is ERC20, ERC20Burnable, Ownable, ERC20Permit {
    constructor() ERC20("Denarius", "SPQR") ERC20Permit("Denarius") {
        _mint(msg.sender, 1 * 10**decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
