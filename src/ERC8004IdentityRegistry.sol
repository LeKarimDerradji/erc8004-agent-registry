// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// import openzeppelin ERC 721

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import URI extension
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

// Define the ERC8004IdentityRegistry contract with ERC721 inheritance WITH URI STORAGE
contract ERC8004IdentityRegistry is ERC721URIStorage {
    // Token ID counter
    uint256 private _tokenIdCounter;
    // Metadata entry structure

    struct MetadataEntry {
        string key;
        bytes value;
    }

    mapping(uint256 => mapping(string => bytes)) private _metadata;

    // Constructor to set the token name and symbol
    constructor() ERC721("ERC8004IdentityRegistry", "EIR") {}

    // event for metadata updates
    event MetadataSet(uint256 indexed agentId, string indexed indexedKey, string key, bytes value);

    event Registered(uint256 indexed agentId, string tokenURI, address indexed owner);

    function setMetadata(uint256 agentId, string memory key, bytes memory value) public {
        // Ensure the caller is the owner of the token
        require(ownerOf(agentId) == msg.sender, "Caller is not the owner of the token");
        // updating metadata
        _metadata[agentId][key] = value;
        // Emit the MetadataSet event
        emit MetadataSet(agentId, key, key, value);
    }

    function getMetadata(uint256 agentId, string memory key) public view returns (bytes memory) {
        return _metadata[agentId][key];
    }

    function register(string memory tokenURI, MetadataEntry[] calldata metadata) public returns (uint256 agentId) {
        // Increment token ID counter
        _tokenIdCounter += 1;
        uint256 newTokenId = _tokenIdCounter;

        // Mint the new token to the sender
        _mint(msg.sender, newTokenId);

        // Set the token URI
        _setTokenURI(newTokenId, tokenURI);

        for (uint256 i = 0; i < metadata.length; i++) {
            _metadata[newTokenId][metadata[i].key] = metadata[i].value;
            emit MetadataSet(newTokenId, metadata[i].key, metadata[i].key, metadata[i].value);
        }
        emit Registered(newTokenId, tokenURI, msg.sender);
        return newTokenId;
    }

    function register(string memory tokenURI) public returns (uint256 agentId) {
        // Increment token ID counter
        _tokenIdCounter += 1;
        uint256 newTokenId = _tokenIdCounter;

        // Mint the new token to the sender
        _mint(msg.sender, newTokenId);

        // Set the token URI
        _setTokenURI(newTokenId, tokenURI);

        emit Registered(newTokenId, tokenURI, msg.sender);
        return newTokenId;
    }

    function register() public returns (uint256 agentId) {
        // Increment token ID counter
        _tokenIdCounter += 1;
        uint256 newTokenId = _tokenIdCounter;

        // Mint the new token to the sender
        _mint(msg.sender, newTokenId);

        emit Registered(newTokenId, "", msg.sender);
        return newTokenId;
    }

    function setTokenURI(uint256 agentId, string memory tokenURI) public {
        // Ensure the caller is the owner of the token
        require(ownerOf(agentId) == msg.sender, "Caller is not the owner of the token");
        // Set the token URI
        _setTokenURI(agentId, tokenURI);
    }
}
