# Decentralized AI Model Marketplace Smart Contract

A blockchain-powered platform that enables AI model creators to publish, monetize, and distribute their models through secure licensing, automated royalty payments, version control, and transparent revenue sharing.

## Overview

This smart contract provides a decentralized marketplace where:
- **AI Researchers & Developers** can publish and monetize their trained models
- **Enterprises & Developers** can discover and license AI models for their applications
- **Platform Administrators** can manage marketplace operations and commission rates
- **All Participants** benefit from transparent, automated transactions and revenue sharing

## Key Features

### Model Publishing & Management
- Publish AI models with comprehensive metadata
- Version control and technical specifications tracking
- Model activation/deactivation controls
- Update model information and pricing

### Licensing & Revenue
- Flexible licensing with customizable duration and pricing
- Automated royalty distribution to model creators
- Platform commission handling
- License renewal capabilities
- Revenue analytics and tracking

### Security & Access Control
- Role-based access control (creators, licensees, administrators)
- Secure payment processing via STX transfers
- License validation and expiration management
- Marketplace operational controls

### Analytics & Transparency
- Real-time revenue tracking
- License subscription analytics
- Technical performance metrics
- Transparent commission calculations

## Contract Architecture

### Core Data Structures

#### AI Model Registry
Stores primary model information including creator, title, description, licensing terms, and sales statistics.

#### License Subscription Registry
Tracks active licenses, expiration dates, and subscription details for each user-model pair.

#### Technical Metadata
Maintains model specifications including version, file hash, size, accuracy score, and system requirements.

#### Revenue Analytics
Records comprehensive financial data including total revenue, active subscriptions, and commission fees.

## Getting Started

### Prerequisites
- Stacks blockchain access
- STX tokens for license purchases and gas fees
- Compatible wallet (Hiro Wallet, Xverse, etc.)

### Basic Usage

#### For Model Creators

1. **Publish a Model**
   ```clarity
   (publish-ai-model-to-marketplace
     "My AI Model"                    ;; model-title
     "Advanced image classification"   ;; model-description
     u1000000                         ;; licensing-fee (1 STX)
     u1440                           ;; license-duration (10 days)
     "v1.0.0"                        ;; model-version
     "abc123..."                     ;; file-hash
     u50000000                       ;; file-size-bytes
     u9500                           ;; accuracy-score (95%)
     "ImageNet + custom dataset"      ;; training-dataset
     "GPU: 4GB VRAM, RAM: 8GB"      ;; hardware-requirements
     "TensorFlow, PyTorch"           ;; framework-compatibility
   )
   ```

2. **Update Model Information**
   ```clarity
   (update-ai-model-information
     u1                              ;; model-identifier
     "Updated Model Title"           ;; new-title
     "Updated description"           ;; new-description
     u1500000                        ;; new-licensing-fee
     u2880                          ;; new-license-duration
   )
   ```

3. **Manage Model Status**
   ```clarity
   ;; Deactivate model
   (deactivate-ai-model-from-marketplace u1)
   
   ;; Reactivate model
   (reactivate-ai-model-in-marketplace u1)
   ```

#### For Model Licensees

1. **Purchase License**
   ```clarity
   (purchase-ai-model-license-subscription
     u1                              ;; model-identifier
     "commercial"                    ;; license-type
   )
   ```

2. **Renew License**
   ```clarity
   (renew-license-subscription u1)   ;; model-identifier
   ```

3. **Check License Status**
   ```clarity
   (verify-license-subscription-validity u1 'SP1ABC...') ;; model-id, user-address
   ```

#### For Platform Administrators

1. **Configure Commission Rate**
   ```clarity
   (configure-platform-commission-rate u300) ;; 3% commission
   ```

2. **Manage Marketplace Operations**
   ```clarity
   ;; Suspend marketplace
   (suspend-marketplace-operations)
   
   ;; Resume marketplace
   (resume-marketplace-operations)
   ```

3. **Update License Duration Constraints**
   ```clarity
   (update-license-duration-constraints
     u144                           ;; minimum-duration (1 day)
     u52560                         ;; maximum-duration (1 year)
   )
   ```

## Read-Only Functions

### Query Model Information
```clarity
;; Get basic model info
(get-ai-model-information u1)

;; Get technical specifications
(get-ai-model-technical-specifications u1)

;; Get revenue analytics
(get-model-revenue-analytics u1)

;; Get license details
(get-license-subscription-details u1 'SP1ABC...')

;; Check license validity
(verify-license-subscription-validity u1 'SP1ABC...')
```

### Platform Information
```clarity
;; Get next available model ID
(get-next-available-model-identifier)

;; Get current commission rate
(get-current-platform-commission-rate)

;; Calculate commission fee
(calculate-platform-commission-fee u1000000)

;; Check operational status
(check-marketplace-operational-status)

;; Get license duration constraints
(get-license-duration-constraints)
```

## Configuration Parameters

### Platform Constants
- **Default Commission Rate**: 2.5% (250 basis points)
- **Maximum Commission Rate**: 10% (1000 basis points)
- **Minimum License Duration**: 1 day (144 blocks)
- **Maximum License Duration**: 1 year (52,560 blocks)
- **Maximum Model File Size**: ~1TB (999,999,999,999 bytes)
- **Maximum Accuracy Score**: 100% (10,000 basis points)

### Input Validation Limits
- **Model Title**: 1-64 ASCII characters
- **Model Description**: 1-256 ASCII characters
- **Version String**: 1-16 ASCII characters
- **File Hash**: 32-64 ASCII characters
- **License Type**: 1-32 ASCII characters
- **Dataset Info**: 1-128 ASCII characters
- **Hardware Requirements**: 1-64 ASCII characters
- **Framework Compatibility**: 1-128 ASCII characters

## Error Codes

| Code | Error | Description |
|------|-------|-------------|
| u100 | ERR-UNAUTHORIZED-ACCESS | User lacks required permissions |
| u101 | ERR-AI-MODEL-NOT-FOUND | Model ID doesn't exist |
| u102 | ERR-AI-MODEL-ALREADY-EXISTS | Model already registered |
| u103 | ERR-INSUFFICIENT-PAYMENT-AMOUNT | Payment below required amount |
| u104 | ERR-LICENSE-SUBSCRIPTION-EXPIRED | License has expired |
| u105 | ERR-ACCESS-PERMISSION-DENIED | User not authorized for this action |
| u106 | ERR-INVALID-INPUT-PARAMETERS | Invalid input parameters provided |
| u107 | ERR-AI-MODEL-CURRENTLY-UNAVAILABLE | Model is deactivated |
| u108 | ERR-ACTIVE-LICENSE-ALREADY-EXISTS | User already has active license |

## Security Considerations

### Access Control
- **Contract Administrator**: Full platform management privileges
- **Model Creators**: Can only modify their own models
- **License Holders**: Can only access their licensed models
- **Public Users**: Read-only access to marketplace data

### Payment Security
- All STX transfers are atomic and validated
- Platform commission automatically deducted
- No direct token handling or custody
- Transparent fee calculations

### Data Integrity
- Comprehensive input validation on all parameters
- Model metadata immutability after publication
- License expiration automatically enforced
- Revenue tracking with tamper-proof analytics

## Best Practices

### For Model Creators
1. **Accurate Metadata**: Provide comprehensive and accurate model descriptions
2. **Competitive Pricing**: Research similar models to set appropriate licensing fees
3. **Version Control**: Use semantic versioning for model updates
4. **Documentation**: Include detailed hardware requirements and compatibility info
5. **Quality Assurance**: Ensure accuracy scores reflect actual model performance

### For Licensees
1. **License Validation**: Always verify license validity before model usage
2. **Renewal Planning**: Monitor license expiration and renew proactively
3. **Compliance**: Respect license terms and usage restrictions
4. **Resource Planning**: Ensure hardware meets model requirements

### For Administrators
1. **Fair Commission**: Set reasonable commission rates to encourage participation
2. **Monitoring**: Regularly review platform analytics and user feedback
3. **Maintenance**: Schedule maintenance during low-activity periods
4. **Security**: Monitor for suspicious activities or potential exploits