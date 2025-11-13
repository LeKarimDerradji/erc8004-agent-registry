// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC8004ReputationRegistry {
    address identityRegistryAddress;
    constructor(address _identityRegistryAddress) {
        identityRegistryAddress = _identityRegistryAddress;
    }

    function getIdentityRegistryAddress()
        public
        view
        returns (address identity)
    {
        return identityRegistryAddress;
    }
}
