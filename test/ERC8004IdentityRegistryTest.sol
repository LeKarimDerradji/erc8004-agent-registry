// SPDX-License-Identifier: MIT
import {Test} from "forge-std/Test.sol";

pragma solidity ^0.8.0;

import "../src/ERC8004IdentityRegistry.sol";

contract ERC8004IdentityRegistryTest is Test {
    ERC8004IdentityRegistry identityRegistry;

    address alice = vm.addr(1);

    function setUp() public {
        identityRegistry = new ERC8004IdentityRegistry();
    }

    function testRegisterAndMetadata() public {
        // Register a new identity
        string memory tokenURI = "https://example.com/agent/1";
        ERC8004IdentityRegistry.MetadataEntry[] memory metadata = new ERC8004IdentityRegistry.MetadataEntry[](2);
        metadata[0] = ERC8004IdentityRegistry.MetadataEntry({key: "name", value: bytes("Agent One")});
        metadata[1] = ERC8004IdentityRegistry.MetadataEntry({key: "role", value: bytes("validator")});

        uint256 agentId = identityRegistry.register(tokenURI, metadata);

        // Verify token URI
        string memory retrievedTokenURI = identityRegistry.tokenURI(agentId);
        assertEq(retrievedTokenURI, tokenURI);

        // Verify metadata
        bytes memory name = identityRegistry.getMetadata(agentId, "name");
        bytes memory role = identityRegistry.getMetadata(agentId, "role");
        assertEq(string(name), "Agent One");
        assertEq(string(role), "validator");
    }

    function testRegisterWithoutMetadata() public {
        // Register a new identity without metadata
        string memory tokenURI = "https://example.com/agent/2";
        uint256 agentId = identityRegistry.register(tokenURI);

        // Verify token URI
        string memory retrievedTokenURI = identityRegistry.tokenURI(agentId);
        assertEq(retrievedTokenURI, tokenURI);

        // Verify that metadata is empty
        bytes memory name = identityRegistry.getMetadata(agentId, "name");
        assertEq(name.length, 0);
    }

    function testRegisterWithoutParameters() public {
        // Register a new identity without parameters
        uint256 agentId = identityRegistry.register();

        // Verify that token URI is empty
        string memory retrievedTokenURI = identityRegistry.tokenURI(agentId);
        assertEq(retrievedTokenURI, "");
    }

    function testSetMetadaNonOwner() public {
        // Register a new identity
        uint256 agentId = identityRegistry.register();

        // Attempt to set metadata from a different address
        vm.prank(alice);
        vm.expectRevert("Caller is not the owner of the token");
        identityRegistry.setMetadata(agentId, "name", bytes("Hacker Agent"));
    }
}
