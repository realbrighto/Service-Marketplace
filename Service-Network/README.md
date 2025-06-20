# Decentralized Professional Services Marketplace

A comprehensive blockchain-based marketplace system built on Stacks that facilitates secure professional service engagements between freelancers and clients. The platform features automated contract lifecycle management, escrow-style payment handling, integrated dispute resolution mechanisms, and transparent reputation scoring in a trustless environment.

## Features

### Core Functionality
- **Contract Management**: Complete lifecycle management from creation to completion
- **Escrow System**: Secure payment handling with milestone-based releases
- **Dispute Resolution**: Built-in arbitration system with administrative oversight
- **Reputation System**: Transparent scoring and performance tracking for freelancers
- **Multi-party Validation**: Client approval workflows and freelancer acceptance processes

### Security & Governance
- **Access Control**: Role-based permissions for administrators, freelancers, and clients
- **Data Validation**: Comprehensive input validation and format checking
- **Platform Controls**: Administrative functions for maintenance and governance
- **Audit Trail**: Complete transaction and state change history

## Contract Architecture

### Data Structures

#### Service Engagement Database
Stores complete contract information including:
- Freelancer and client wallet addresses
- Project timelines and deadlines
- Compensation amounts
- Contract status and specifications

#### Reputation Analytics
Tracks freelancer performance metrics:
- Weighted average client satisfaction scores
- Lifetime engagement statistics
- Successful project completion counts
- Specialization categories

#### Dispute Resolution System
Manages conflict resolution with:
- Detailed dispute documentation
- Administrative review workflows
- Resolution timelines and decisions

## Error Codes

| Code | Description |
|------|-------------|
| `u100` | Access denied - unauthorized user |
| `u101` | Duplicate service contract exists |
| `u102` | Service contract record not found |
| `u103` | Invalid contract state transition |
| `u104` | Payment amount below minimum threshold |
| `u105` | Malformed blockchain address format |
| `u106` | Input validation failed parameters |

## Contract Status Flow

```
awaiting-freelancer-acceptance
    ↓
active-development-phase
    ↓
successfully-completed-approved
```

Alternative flows include dispute resolution and administrative cancellation paths.

## Public Functions

### Administrative Functions

#### `transfer-marketplace-administrative-privileges`
Transfers administrative control to a new operator.
```clarity
(transfer-marketplace-administrative-privileges new-admin-address)
```

#### `modify-platform-operational-status`
Toggles platform operational status for maintenance.
```clarity
(modify-platform-operational-status true/false)
```

### Contract Lifecycle Functions

#### `establish-new-professional-service-engagement`
Creates a new service contract between freelancer and client.
```clarity
(establish-new-professional-service-engagement
  contract-id
  freelancer-address
  client-address
  start-timestamp
  deadline-timestamp
  compensation-amount
  project-specification)
```

#### `confirm-freelancer-engagement-acceptance`
Allows freelancer to accept the contract terms.
```clarity
(confirm-freelancer-engagement-acceptance contract-id)
```

#### `approve-completed-service-deliverables`
Enables client to approve completed work and finalize contract.
```clarity
(approve-completed-service-deliverables contract-id)
```

### Dispute Resolution Functions

#### `submit-formal-service-engagement-dispute`
Initiates a formal dispute process for contract issues.
```clarity
(submit-formal-service-engagement-dispute
  contract-id
  dispute-explanation)
```

#### `execute-administrative-dispute-resolution`
Administrative function to resolve disputes (admin only).
```clarity
(execute-administrative-dispute-resolution
  contract-id
  resolution-decision
  final-status)
```

### Reputation Functions

#### `submit-freelancer-performance-quality-evaluation`
Submits performance ratings for freelancers.
```clarity
(submit-freelancer-performance-quality-evaluation
  freelancer-address
  rating-score
  specialization-category)
```

## Read-Only Functions

### Query Functions
- `query-service-engagement-contract-details`: Get contract information
- `query-freelancer-reputation-and-performance-metrics`: Get freelancer stats
- `query-client-organization-profile-information`: Get client profile
- `query-dispute-resolution-case-details`: Get dispute information
- `get-current-marketplace-administrator-address`: Get admin address
- `get-total-platform-contract-processing-statistics`: Get platform stats
- `get-current-platform-operational-status`: Check platform status

## Usage Examples

### Creating a New Contract
1. Client calls `establish-new-professional-service-engagement` with project details
2. Freelancer calls `confirm-freelancer-engagement-acceptance` to accept
3. Work is performed according to specifications
4. Client calls `approve-completed-service-deliverables` to finalize

### Dispute Resolution Process
1. Either party calls `submit-formal-service-engagement-dispute`
2. Contract status changes to "under-dispute-arbitration-review"
3. Administrator reviews and calls `execute-administrative-dispute-resolution`
4. Final resolution is recorded and contract status updated

### Reputation Management
After successful project completion, clients can submit performance evaluations using `submit-freelancer-performance-quality-evaluation` to maintain transparent reputation scores.

## Security Considerations

- **Access Control**: All sensitive functions require proper authorization
- **Input Validation**: Comprehensive validation prevents malformed data
- **State Management**: Strict state transition rules prevent invalid operations
- **Address Validation**: Blockchain address format verification
- **Text Length Limits**: Prevents spam and ensures data integrity