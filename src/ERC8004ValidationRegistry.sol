// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC8004ValidationRegistry {
    // Validation mapping: agentId => isValid
    mapping(uint256 => bool) private _validations;

    // Event emitted when validation status is updated
    event ValidationUpdated(uint256 indexed agentId, bool isValid);

    // Function to set or update validation status
    function setValidation(uint256 agentId, bool valid) public {
        _validations[agentId] = valid;
        emit ValidationUpdated(agentId, valid);
    }

    // Function to get the validation status of an agent
    function isValid(uint256 agentId) public view returns (bool) {
        return _validations[agentId];
    }
}
