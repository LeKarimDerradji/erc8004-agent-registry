# ERC-8004: Decentralized AI Agent Registry

A groundbreaking implementation of the **ERC-8004 standard** for trustless, decentralized AI agent discovery and reputation management on Ethereum.

## Overview

This project implements a fully **decentralized infrastructure** for AI agents to register, verify, and build reputation in a **trustless** manner across organizational boundaries. Built on Ethereum smart contracts, it enables the emerging **agentic economy** by providing standardized on-chain registries for AI agent identity, validation, and reputation.

## What is ERC-8004?

ERC-8004 is a revolutionary standard that enables **autonomous AI agents** to:
- **Register their identity** on-chain as NFTs
- **Build verifiable reputation** through decentralized feedback
- **Undergo third-party validation** by trusted validators
- **Operate trustlessly** across different platforms and organizations

This standard is designed for the **multi-agent future**, where AI agents need to discover, evaluate, and interact with each other in a **decentralized** and **permissionless** way.

## Core Components

### 1. Identity Registry (`ERC8004IdentityRegistry.sol`)
A **ERC-721-based registry** where AI agents mint their identity as NFTs. Each agent receives a unique global identifier and can attach metadata describing their capabilities, endpoints, and supported protocols.

**Features:**
- NFT-based agent identity
- On-chain metadata storage
- Multiple registration methods
- Support for A2A, MCP, OASF, ENS, DID protocols

### 2. Reputation Registry (`ERC8004ReputationRegistry.sol`)
A **decentralized reputation system** where clients can leave feedback about their interactions with AI agents. Feedback is cryptographically signed and stored on-chain, creating an immutable reputation history.

**Features:**
- Cryptographically-signed feedback
- Score-based rating system (0-100)
- Tag-based categorization
- Revocable feedback mechanism
- Agent response system

### 3. Validation Registry (`ERC8004ValidationRegistry.sol`)
A **third-party validation system** where independent validators can verify AI agent capabilities, security, and compliance. This creates a trust layer for the agentic ecosystem.

**Features:**
- Request-response validation flow
- Multiple validator support
- Tag-based validation categories
- Aggregate validation scores
- Timestamped validation records

## The Agentic Future

This implementation is built for the coming **agentic AI revolution**:

- **Autonomous agents** can register themselves without human intervention
- **Decentralized reputation** ensures no single entity controls trust
- **Cross-organizational discovery** enables agents to find and interact with each other
- **Trustless verification** through blockchain immutability
- **Permissionless participation** in the AI agent economy

## Technology Stack

- **Solidity ^0.8.0** - Smart contract development
- **Foundry** - Fast, portable Ethereum development framework
- **OpenZeppelin** - Battle-tested smart contract libraries
- **ERC-721** - NFT standard for agent identity
- **EIP-191 / ERC-1271** - Signature verification

## Smart Contracts

```
src/
├── ERC8004IdentityRegistry.sol    # Agent identity & registration
├── ERC8004ReputationRegistry.sol  # Decentralized reputation system
└── ERC8004ValidationRegistry.sol  # Third-party validation
```

## Installation

```bash
# Clone the repository
git clone https://github.com/LeKarimDerradji/erc8004-agent-registry.git
cd erc8004-agent-registry

# Install dependencies
forge install
```

## Usage

### Build

```bash
forge build
```

### Test

```bash
forge test
```

### Deploy

```bash
forge script script/Deploy.s.sol --rpc-url <your_rpc_url> --broadcast
```

## ERC-8004 Standard Specification

This implementation follows the official [EIP-8004 specification](https://eips.ethereum.org/EIPS/eip-8004).

## Use Cases

- **AI Agent Marketplaces** - Discover and hire AI agents based on reputation
- **Multi-Agent Systems** - Enable agents to find and collaborate with each other
- **DAO Governance** - Use validated agents for decentralized decision-making
- **Autonomous Services** - Deploy AI agents that can build trust over time
- **Cross-Platform Integration** - Unified identity for agents across different platforms

## Contributing

Contributions are welcome! This is an emerging standard and we're building the foundation for the **decentralized agentic economy**.

## License

MIT License - See [LICENSE](LICENSE) file for details

## Acknowledgments

Built in accordance with [EIP-8004](https://eips.ethereum.org/EIPS/eip-8004) - Trustless Agents standard.

---

**Building the infrastructure for autonomous AI agents on Ethereum** 🤖⛓️
