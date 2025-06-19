# TrustBridge - Transparent Charitable Giving Platform

[![Stacks Layer 2](https://img.shields.io/badge/Stacks-Layer%202-orange)](https://stacks.co)
[![Version](https://img.shields.io/badge/Version-1.0.0-green)](https://github.com/trustbridge/contract)

> Revolutionizing charitable giving through blockchain transparency, accountability, and community-governed impact verification.

## Overview

TrustBridge is a next-generation decentralized charity platform built on Stacks Layer 2 that creates unprecedented transparency between donors and beneficiaries. By leveraging blockchain immutability and smart contract automation, TrustBridge ensures every donation is tracked, every fund utilization is verified, and every impact is measurable.

### Key Benefits

- **🔍 Complete Transparency**: All donations and fund usage tracked on-chain
- **✅ Verified Impact**: Milestone-based fund disbursement with approval workflows  
- **🛡️ Secure Governance**: Multi-tiered role-based access control system
- **📊 Real-time Tracking**: Live beneficiary progress and donation monitoring
- **⚡ Layer 2 Efficiency**: Built for Stacks Layer 2 scalability and low costs

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    TrustBridge Platform                         │
├─────────────────────────────────────────────────────────────────┤
│  Frontend Layer                                                 │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐   │
│  │   Donor Portal  │ │  Admin Dashboard│ │ Beneficiary Hub │   │
│  └─────────────────┘ └─────────────────┘ └─────────────────┘   │
├─────────────────────────────────────────────────────────────────┤
│  Smart Contract Layer (Clarity)                                │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                TrustBridge Contract                         │ │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐         │ │
│  │  │Role Manager │ │Donation Core│ │Fund Tracker │         │ │
│  │  └─────────────┘ └─────────────┘ └─────────────┘         │ │
│  └─────────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│  Stacks Layer 2 Blockchain                                     │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │        Immutable Transaction & State Storage                │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### Contract Architecture

The TrustBridge smart contract is organized into six core modules:

#### 1. **Role Management System**

- **Purpose**: Multi-tiered access control with Admin/Moderator/Beneficiary roles
- **Components**:
  - Role assignment and validation
  - Permission checking middleware
  - Owner-based governance controls

#### 2. **Beneficiary Registry**

- **Purpose**: Verified beneficiary onboarding and management
- **Components**:
  - Registration with KYC-like validation
  - Target amount and status tracking
  - Real-time funding progress

#### 3. **Donation Engine**

- **Purpose**: Secure, transparent donation processing
- **Components**:
  - STX token transfer handling
  - Immutable donation ledger
  - Automatic beneficiary balance updates

#### 4. **Fund Utilization Tracker**

- **Purpose**: Milestone-based fund disbursement control
- **Components**:
  - Utilization plan creation
  - Approval workflow system
  - Impact verification tracking

#### 5. **Data Storage Layer**

- **Purpose**: Efficient on-chain data management
- **Components**:
  - Optimized mapping structures
  - Auto-incrementing ID systems
  - State variable management

#### 6. **Query Interface**

- **Purpose**: Public read access to platform data
- **Components**:
  - Beneficiary information retrieval
  - Donation history queries
  - Utilization status checking

## Data Flow

### 1. Donation Flow

```
Donor → [Amount Validation] → [STX Transfer] → [Balance Update] → [Record Creation]
  ↓
[Donation ID Generated] → [Timestamp Recorded] → [Event Logged]
```

### 2. Fund Utilization Flow

```
Admin → [Create Utilization Plan] → [Milestone Assignment] → [Pending Status]
  ↓
[Admin Approval] → [Balance Verification] → [Status: Approved] → [Fund Release]
```

### 3. Role Management Flow

```
Contract Owner → [Role Assignment] → [Permission Validation] → [Access Control]
  ↓
[User Authentication] → [Function Authorization] → [Action Execution]
```

## Smart Contract Functions

### Core Public Functions

| Function | Role Required | Description |
|----------|---------------|-------------|
| `donate` | None | Make donation to verified beneficiary |
| `register-beneficiary` | Moderator+ | Onboard new beneficiary |
| `add-utilization` | Admin | Create fund utilization plan |
| `approve-utilization` | Admin | Approve milestone fund release |
| `set-role` | Owner | Assign user roles |
| `remove-role` | Owner | Remove user roles |

### Read-Only Functions

| Function | Description |
|----------|-------------|
| `get-beneficiary` | Retrieve beneficiary information |
| `get-donation-by-id` | Get specific donation details |
| `get-utilization-by-id` | Get utilization plan details |
| `get-donation-count` | Total platform donations |
| `get-utilization-count` | Total utilization entries |

## Getting Started

### Prerequisites

- Stacks wallet (Hiro Wallet recommended)
- STX tokens for donations and gas fees
- Access to Stacks Layer 2 network

### Deployment

1. **Clone the repository**

```bash
git clone https://github.com/steven-exec/trust-bridge.git
cd trust-bridge
```

2. **Deploy to Stacks Layer 2**

```bash
clarinet deploy --network=layer2
```

3. **Initialize platform roles**

```clarity
;; Set initial moderators and admins
(contract-call? .trustbridge set-role 'SP1234...MODERATOR ROLE-MODERATOR)
```

### Usage Examples

#### Making a Donation

```clarity
;; Donate 1000 microSTX to beneficiary ID 1
(contract-call? .trustbridge donate u1 u1000000)
```

#### Registering a Beneficiary (Moderator+)

```clarity
;; Register new beneficiary
(contract-call? .trustbridge register-beneficiary 
  u"Local Food Bank" 
  u"Providing meals to 500 families monthly" 
  u50000000) ;; 50 STX target
```

#### Creating Utilization Plan (Admin)

```clarity
;; Create milestone for fund usage
(contract-call? .trustbridge add-utilization 
  u1 
  u"Purchase food supplies for December distribution" 
  u10000000) ;; 10 STX
```

## Security Features

- **Role-based Access Control**: Prevents unauthorized actions
- **Input Validation**: Comprehensive parameter checking
- **Balance Verification**: Ensures sufficient funds before approval
- **Owner Protection**: Prevents self-role modification
- **Immutable Records**: All transactions permanently recorded

## Error Handling

| Error Code | Description |
|------------|-------------|
| `u100` | Not authorized for this action |
| `u101` | Already registered |
| `u102` | Record not found |
| `u103` | Insufficient funds |
| `u104` | Beneficiary not found |
| `u105` | Utilization record not found |
| `u106` | Invalid input parameters |

## Contributing

We welcome contributions to TrustBridge! Please read our [Contributing Guidelines](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md).

### Development Setup

```bash
# Install Clarinet
curl -L https://github.com/hirosystems/clarinet/releases/latest/download/clarinet-linux-x64.tar.gz | tar -xz
sudo mv clarinet /usr/local/bin

# Run tests
clarinet test

# Check contract syntax
clarinet check
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Roadmap

- [ ] **Q2 2025**: Multi-signature approval workflows
- [ ] **Q3 2025**: Integration with external KYC providers
- [ ] **Q4 2025**: Cross-chain donation support
- [ ] **Q1 2026**: Mobile application launch
- [ ] **Q2 2026**: Impact reporting dashboard
