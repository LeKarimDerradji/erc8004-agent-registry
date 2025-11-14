// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol";

interface IERC8004IdentityRegistry {
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract ERC8004ReputationRegistry {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    address public immutable identityRegistryAddress;

    // Feedback structure
    struct Feedback {
        uint8 score;
        bytes32 tag1;
        bytes32 tag2;
        string fileuri;
        bytes32 filehash;
        uint256 timestamp;
        bool isRevoked;
    }

    // Response structure
    struct Response {
        address responder;
        string responseUri;
        bytes32 responseHash;
        uint256 timestamp;
    }

    // Mapping: agentId => clientAddress => feedback index => Feedback
    mapping(uint256 => mapping(address => mapping(uint64 => Feedback))) private _feedbacks;

    // Mapping: agentId => clientAddress => last feedback index
    mapping(uint256 => mapping(address => uint64)) private _lastFeedbackIndex;

    // Mapping: agentId => clientAddress => feedbackIndex => responses
    mapping(uint256 => mapping(address => mapping(uint64 => Response[]))) private _responses;

    // Mapping: agentId => list of clients who gave feedback
    mapping(uint256 => address[]) private _agentClients;

    // Mapping: agentId => clientAddress => hasGivenFeedback (to avoid duplicates in _agentClients)
    mapping(uint256 => mapping(address => bool)) private _hasGivenFeedback;

    // Events
    event NewFeedback(
        uint256 indexed agentId,
        address indexed clientAddress,
        uint8 score,
        bytes32 indexed tag1,
        bytes32 tag2,
        string fileuri,
        bytes32 filehash
    );

    event FeedbackRevoked(uint256 indexed agentId, address indexed clientAddress, uint64 indexed feedbackIndex);

    event ResponseAppended(
        uint256 indexed agentId,
        address indexed clientAddress,
        uint64 indexed feedbackIndex,
        address responder,
        string responseUri
    );

    constructor(address _identityRegistryAddress) {
        identityRegistryAddress = _identityRegistryAddress;
    }

    function getIdentityRegistryAddress() public view returns (address) {
        return identityRegistryAddress;
    }

    // Function to give feedback
    function giveFeedback(
        uint256 agentId,
        uint8 score,
        bytes32 tag1,
        bytes32 tag2,
        string calldata fileuri,
        bytes32 filehash,
        bytes memory feedbackAuth
    ) external {
        // Validate score range
        require(score <= 100, "Score must be between 0 and 100");

        // Verify the agent exists
        IERC8004IdentityRegistry identityRegistry = IERC8004IdentityRegistry(identityRegistryAddress);
        address agentOwner = identityRegistry.ownerOf(agentId);
        require(agentOwner != address(0), "Agent does not exist");

        // Decode feedbackAuth signature
        // feedbackAuth format: (uint256 agentId, address clientAddress, uint64 indexLimit, uint256 expiry, uint256 chainId, address identityRegistry, address signerAddress, bytes signature)
        (
            uint256 authAgentId,
            address authClientAddress,
            uint64 indexLimit,
            uint256 expiry,
            uint256 authChainId,
            address authIdentityRegistry,
            address signerAddress,
            bytes memory signature
        ) = abi.decode(feedbackAuth, (uint256, address, uint64, uint256, uint256, address, address, bytes));

        // Verify authorization parameters
        require(authAgentId == agentId, "Agent ID mismatch");
        require(authClientAddress == msg.sender, "Client address mismatch");
        require(block.timestamp <= expiry, "Authorization expired");
        require(authChainId == block.chainid, "Chain ID mismatch");
        require(authIdentityRegistry == identityRegistryAddress, "Identity registry mismatch");

        // Get current feedback index for this client
        uint64 currentIndex = _lastFeedbackIndex[agentId][msg.sender];
        require(currentIndex < indexLimit, "Index limit exceeded");

        // Verify signature
        bytes32 messageHash = keccak256(
            abi.encodePacked(authAgentId, authClientAddress, indexLimit, expiry, authChainId, authIdentityRegistry)
        );
        bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();

        // Check if signer is a contract (ERC-1271) or EOA (ECDSA)
        if (signerAddress.code.length > 0) {
            // ERC-1271 verification
            require(
                IERC1271(signerAddress).isValidSignature(ethSignedMessageHash, signature) == 0x1626ba7e,
                "Invalid ERC-1271 signature"
            );
        } else {
            // ECDSA verification
            address recoveredSigner = ethSignedMessageHash.recover(signature);
            require(recoveredSigner == signerAddress, "Invalid signature");
        }

        // Verify signer is the agent owner
        require(signerAddress == agentOwner, "Signer is not agent owner");

        // Store feedback
        _feedbacks[agentId][msg.sender][currentIndex] = Feedback({
            score: score,
            tag1: tag1,
            tag2: tag2,
            fileuri: fileuri,
            filehash: filehash,
            timestamp: block.timestamp,
            isRevoked: false
        });

        // Increment feedback index
        _lastFeedbackIndex[agentId][msg.sender] = currentIndex + 1;

        // Track client if first feedback
        if (!_hasGivenFeedback[agentId][msg.sender]) {
            _agentClients[agentId].push(msg.sender);
            _hasGivenFeedback[agentId][msg.sender] = true;
        }

        // Emit event
        emit NewFeedback(agentId, msg.sender, score, tag1, tag2, fileuri, filehash);
    }

    // Revoke feedback
    function revokeFeedback(uint256 agentId, uint64 feedbackIndex) external {
        require(_feedbacks[agentId][msg.sender][feedbackIndex].timestamp != 0, "Feedback does not exist");
        require(!_feedbacks[agentId][msg.sender][feedbackIndex].isRevoked, "Feedback already revoked");

        _feedbacks[agentId][msg.sender][feedbackIndex].isRevoked = true;

        emit FeedbackRevoked(agentId, msg.sender, feedbackIndex);
    }

    // Append response to feedback
    function appendResponse(
        uint256 agentId,
        address clientAddress,
        uint64 feedbackIndex,
        string calldata responseUri,
        bytes32 responseHash
    ) external {
        require(_feedbacks[agentId][clientAddress][feedbackIndex].timestamp != 0, "Feedback does not exist");

        _responses[agentId][clientAddress][feedbackIndex].push(
            Response({
                responder: msg.sender,
                responseUri: responseUri,
                responseHash: responseHash,
                timestamp: block.timestamp
            })
        );

        emit ResponseAppended(agentId, clientAddress, feedbackIndex, msg.sender, responseUri);
    }

    // Get summary statistics
    function getSummary(uint256 agentId, address[] calldata clientAddresses, bytes32 tag1, bytes32 tag2)
        external
        view
        returns (uint64 count, uint8 averageScore)
    {
        uint256 totalScore = 0;
        uint64 validCount = 0;

        for (uint256 i = 0; i < clientAddresses.length; i++) {
            address client = clientAddresses[i];
            uint64 lastIndex = _lastFeedbackIndex[agentId][client];

            for (uint64 j = 0; j < lastIndex; j++) {
                Feedback memory feedback = _feedbacks[agentId][client][j];

                // Skip revoked feedback
                if (feedback.isRevoked) continue;

                // Filter by tags (empty tag means match all)
                if (tag1 != bytes32(0) && feedback.tag1 != tag1) continue;
                if (tag2 != bytes32(0) && feedback.tag2 != tag2) continue;

                totalScore += feedback.score;
                validCount++;
            }
        }

        if (validCount == 0) {
            return (0, 0);
        }

        return (validCount, uint8(totalScore / validCount));
    }

    // Read single feedback
    function readFeedback(uint256 agentId, address clientAddress, uint64 index)
        external
        view
        returns (uint8 score, bytes32 tag1, bytes32 tag2, bool isRevoked)
    {
        Feedback memory feedback = _feedbacks[agentId][clientAddress][index];
        return (feedback.score, feedback.tag1, feedback.tag2, feedback.isRevoked);
    }

    // Read all feedback for an agent
    function readAllFeedback(
        uint256 agentId,
        address[] calldata clientAddresses,
        bytes32 tag1,
        bytes32 tag2,
        bool includeRevoked
    )
        external
        view
        returns (
            address[] memory clients,
            uint8[] memory scores,
            bytes32[] memory tags1,
            bytes32[] memory tags2,
            bool[] memory isRevoked
        )
    {
        // First pass: count matching feedbacks
        uint256 totalCount = 0;
        for (uint256 i = 0; i < clientAddresses.length; i++) {
            uint64 lastIndex = _lastFeedbackIndex[agentId][clientAddresses[i]];
            for (uint64 j = 0; j < lastIndex; j++) {
                Feedback memory feedback = _feedbacks[agentId][clientAddresses[i]][j];
                if (!includeRevoked && feedback.isRevoked) continue;
                if (tag1 != bytes32(0) && feedback.tag1 != tag1) continue;
                if (tag2 != bytes32(0) && feedback.tag2 != tag2) continue;
                totalCount++;
            }
        }

        // Allocate arrays
        clients = new address[](totalCount);
        scores = new uint8[](totalCount);
        tags1 = new bytes32[](totalCount);
        tags2 = new bytes32[](totalCount);
        isRevoked = new bool[](totalCount);

        // Second pass: fill arrays
        uint256 index = 0;
        for (uint256 i = 0; i < clientAddresses.length; i++) {
            uint64 lastIndex = _lastFeedbackIndex[agentId][clientAddresses[i]];
            for (uint64 j = 0; j < lastIndex; j++) {
                Feedback memory feedback = _feedbacks[agentId][clientAddresses[i]][j];
                if (!includeRevoked && feedback.isRevoked) continue;
                if (tag1 != bytes32(0) && feedback.tag1 != tag1) continue;
                if (tag2 != bytes32(0) && feedback.tag2 != tag2) continue;

                clients[index] = clientAddresses[i];
                scores[index] = feedback.score;
                tags1[index] = feedback.tag1;
                tags2[index] = feedback.tag2;
                isRevoked[index] = feedback.isRevoked;
                index++;
            }
        }
    }

    // Get response count
    function getResponseCount(
        uint256 agentId,
        address clientAddress,
        uint64 feedbackIndex,
        address[] calldata responders
    ) external view returns (uint64) {
        Response[] memory responses = _responses[agentId][clientAddress][feedbackIndex];

        if (responders.length == 0) {
            return uint64(responses.length);
        }

        uint64 count = 0;
        for (uint256 i = 0; i < responses.length; i++) {
            for (uint256 j = 0; j < responders.length; j++) {
                if (responses[i].responder == responders[j]) {
                    count++;
                    break;
                }
            }
        }
        return count;
    }

    // Get clients who gave feedback to an agent
    function getClients(uint256 agentId) external view returns (address[] memory) {
        return _agentClients[agentId];
    }

    // Get last feedback index for a client
    function getLastIndex(uint256 agentId, address clientAddress) external view returns (uint64) {
        return _lastFeedbackIndex[agentId][clientAddress];
    }
}
