// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Registry {
    mapping(bytes32 => address) public contracts;
    address[] public contractsIndex;
    uint256 public numItemsRecorded;

    event NewRecord(bytes32 id, address contractAddress, uint256 index);

    /*
    @dev register on chain a project's contract into the registry to allow other contracts to get the contract addresses to interact with
    @param _contractId contract's name encoding using sha256 hash 
    @param _contractAddress contract's address
    */
    function addContract(bytes32 _contractId, address _contractAddress) public {
        contracts[_contractId] = _contractAddress;
        contractsIndex.push(_contractAddress);
        numItemsRecorded++;
        emit NewRecord(_contractId, _contractAddress, numItemsRecorded);
    }

    function lookUp(string memory _contractName) public view returns (address) {
        bytes32 contractHashName = sha256(bytes(_contractName));
        return contracts[contractHashName];
    }

    function lookUpByIndex(uint256 _contractIndex) public view returns (address) {
        return contractsIndex[_contractIndex];
    }

    function setContractAddress(string memory _contractName, address _contractAddress) public returns (bool) {
        bytes32 contractHashName = sha256(bytes(_contractName));
        addContract(contractHashName, _contractAddress);
        return true;
    }
}
