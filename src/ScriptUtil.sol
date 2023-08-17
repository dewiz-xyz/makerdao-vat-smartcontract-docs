// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Vm} from "forge-std/Vm.sol";
import {Registry} from "./Registry.sol";

library Numbers {
    function numDigits(int256 number) public pure returns (uint8) {
        uint8 digits = 0;
        //if (number < 0) digits = 1; // enable this line if '-' counts as a digit
        while (number != 0) {
            number /= 10;
            digits++;
        }
        return digits;
    }

    function convertToInteger(
        uint256 value,
        uint256 decimals,
        uint256 numDigitsBelowOneAndPositive
    ) public pure returns (uint256) {
        return value * 10**(decimals - numDigitsBelowOneAndPositive);
    }
}

library RegistryUtil {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function getRegistryAddress() public view returns (bool, address) {
        string memory tokenAddressStr = vm.readFile("./metadata/registry-address.txt");
        address tokenAddress = address(StringToAddress.convert(tokenAddressStr));
        if (tokenAddress != address(0)) {
            return (true, tokenAddress);
        }
        return (false, address(0));
    }

    function getContractAddress(string calldata _contractName) public view returns (bool, address) {
        (bool success, address registryAddress) = getRegistryAddress();
        if (!success) {
            return (false, address(0));
        }
        // address registryAddress = address(0x1b0c3963065470F6075D8a5A5F990aa373Cb73f8);
        Registry registry = Registry(registryAddress);
        address contractAddress = registry.lookUp(_contractName);
        if (contractAddress == address(0)) {
            return (false, address(0));
        }
        return (true, contractAddress);
    }

    function setContractAddress(string memory _contractName, address _contractAddress) public returns (bool) {
        (bool success, address registryAddress) = getRegistryAddress();
        if (!success) {
            return false;
        }
        vm.startBroadcast();
        // address registryAddress = address(0x1b0c3963065470F6075D8a5A5F990aa373Cb73f8);
        Registry registry = Registry(registryAddress);
        bytes32 contractHashName = sha256(bytes(_contractName));
        registry.addContract(contractHashName, _contractAddress);
        vm.stopBroadcast();
        return true;
    }
}

library StringToAddress {
    function convert(string memory _address) public pure returns (address) {
        string memory cleanAddress = remove0xPrefix(_address);
        bytes20 _addressBytes = parseHexStringToBytes20(cleanAddress);
        return address(_addressBytes);
    }

    function remove0xPrefix(string memory _hexString) internal pure returns (string memory) {
        if (
            bytes(_hexString).length >= 2 &&
            bytes(_hexString)[0] == "0" &&
            (bytes(_hexString)[1] == "x" || bytes(_hexString)[1] == "X")
        ) {
            return substring(_hexString, 2, bytes(_hexString).length);
        }
        return _hexString;
    }

    function substring(
        string memory _str,
        uint256 _start,
        uint256 _end
    ) internal pure returns (string memory) {
        bytes memory _strBytes = bytes(_str);
        bytes memory _result = new bytes(_end - _start);
        for (uint256 i = _start; i < _end; i++) {
            _result[i - _start] = _strBytes[i];
        }
        return string(_result);
    }

    function parseHexStringToBytes20(string memory _hexString) internal pure returns (bytes20) {
        bytes memory _bytesString = bytes(_hexString);
        uint160 _parsedBytes = 0;
        for (uint256 i = 0; i < _bytesString.length; i += 2) {
            _parsedBytes *= 256;
            uint8 _byteValue = parseByteToUint8(_bytesString[i]);
            _byteValue *= 16;
            _byteValue += parseByteToUint8(_bytesString[i + 1]);
            _parsedBytes += _byteValue;
        }
        return bytes20(_parsedBytes);
    }

    function parseByteToUint8(bytes1 _byte) internal pure returns (uint8) {
        if (uint8(_byte) >= 48 && uint8(_byte) <= 57) {
            return uint8(_byte) - 48;
        } else if (uint8(_byte) >= 65 && uint8(_byte) <= 70) {
            return uint8(_byte) - 55;
        } else if (uint8(_byte) >= 97 && uint8(_byte) <= 102) {
            return uint8(_byte) - 87;
        } else {
            revert(string(abi.encodePacked("Invalid byte value: ", _byte)));
        }
    }
}
