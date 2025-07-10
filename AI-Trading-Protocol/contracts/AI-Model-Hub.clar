;; Decentralized AI Model Marketplace Smart Contract
;; A blockchain-powered platform for AI model creators to publish, monetize, and distribute their models
;; Enables secure licensing, automated royalty payments, version control, and transparent revenue sharing
;; Built for researchers, developers, and enterprises seeking decentralized AI model commerce

;; ERROR CONSTANTS

(define-constant contract-administrator tx-sender)
(define-constant ERR-UNAUTHORIZED-ACCESS (err u100))
(define-constant ERR-AI-MODEL-NOT-FOUND (err u101))
(define-constant ERR-AI-MODEL-ALREADY-EXISTS (err u102))
(define-constant ERR-INSUFFICIENT-PAYMENT-AMOUNT (err u103))
(define-constant ERR-LICENSE-SUBSCRIPTION-EXPIRED (err u104))
(define-constant ERR-ACCESS-PERMISSION-DENIED (err u105))
(define-constant ERR-INVALID-INPUT-PARAMETERS (err u106))
(define-constant ERR-AI-MODEL-CURRENTLY-UNAVAILABLE (err u107))
(define-constant ERR-ACTIVE-LICENSE-ALREADY-EXISTS (err u108))

;; PLATFORM CONFIGURATION CONSTANTS

(define-constant default-platform-commission-rate u250) ;; 2.5% in basis points
(define-constant minimum-license-duration-blocks u144) ;; ~1 day in blocks
(define-constant maximum-license-duration-blocks u52560) ;; ~1 year in blocks
(define-constant maximum-platform-commission-rate u1000) ;; 10% maximum commission
(define-constant maximum-model-file-size-bytes u999999999999) ;; Maximum model file size
(define-constant maximum-accuracy-score-basis-points u10000) ;; 100% accuracy in basis points
(define-constant basis-points-divisor u10000) ;; For percentage calculations

;; CORE DATA STRUCTURES

;; Primary registry for AI model information
(define-map ai-model-registry
  { ai-model-identifier: uint }
  {
    model-creator-address: principal,
    model-title: (string-ascii 64),
    model-description: (string-ascii 256),
    licensing-fee-amount: uint,
    license-validity-duration: uint,
    model-active-status: bool,
    model-creation-timestamp: uint,
    total-license-sales-count: uint
  }
)

;; License ownership and subscription tracking
(define-map license-subscription-registry
  { ai-model-identifier: uint, license-holder-address: principal }
  {
    license-expiration-block: uint,
    license-purchase-timestamp: uint,
    license-subscription-type: (string-ascii 32),
    license-payment-amount: uint
  }
)

;; Technical specifications and AI model metadata
(define-map ai-model-technical-metadata
  { ai-model-identifier: uint }
  {
    model-version-string: (string-ascii 16),
    model-file-hash-signature: (string-ascii 64),
    model-file-size-bytes: uint,
    model-accuracy-score: uint,
    training-dataset-information: (string-ascii 128),
    hardware-system-requirements: (string-ascii 64),
    framework-compatibility-list: (string-ascii 128)
  }
)

;; Revenue analytics and financial performance tracking
(define-map revenue-analytics-tracking
  { ai-model-identifier: uint }
  {
    total-revenue-earned: uint,
    active-license-subscriptions-count: uint,
    platform-commission-fees-paid: uint,
    last-analytics-update-timestamp: uint
  }
)

;; PLATFORM STATE VARIABLES

(define-data-var next-available-model-id uint u1)
(define-data-var current-platform-commission-rate uint default-platform-commission-rate)
(define-data-var minimum-allowed-license-duration uint minimum-license-duration-blocks)
(define-data-var maximum-allowed-license-duration uint maximum-license-duration-blocks)
(define-data-var marketplace-operational-status bool false)

;; PUBLIC READ-ONLY QUERY FUNCTIONS

(define-read-only (get-ai-model-information (ai-model-identifier uint))
  (map-get? ai-model-registry { ai-model-identifier: ai-model-identifier })
)

(define-read-only (get-license-subscription-details (ai-model-identifier uint) (user-address principal))
  (map-get? license-subscription-registry { ai-model-identifier: ai-model-identifier, license-holder-address: user-address })
)

(define-read-only (get-ai-model-technical-specifications (ai-model-identifier uint))
  (map-get? ai-model-technical-metadata { ai-model-identifier: ai-model-identifier })
)

(define-read-only (get-model-revenue-analytics (ai-model-identifier uint))
  (map-get? revenue-analytics-tracking { ai-model-identifier: ai-model-identifier })
)

(define-read-only (verify-license-subscription-validity (ai-model-identifier uint) (user-address principal))
  (match (get-license-subscription-details ai-model-identifier user-address)
    license-subscription-data 
      (>= (get license-expiration-block license-subscription-data) block-height)
    false
  )
)

(define-read-only (get-next-available-model-identifier)
  (var-get next-available-model-id)
)

(define-read-only (get-current-platform-commission-rate)
  (var-get current-platform-commission-rate)
)

(define-read-only (calculate-platform-commission-fee (payment-amount uint))
  (/ (* payment-amount (var-get current-platform-commission-rate)) basis-points-divisor)
)

(define-read-only (check-marketplace-operational-status)
  (not (var-get marketplace-operational-status))
)

(define-read-only (get-license-duration-constraints)
  {
    minimum-duration: (var-get minimum-allowed-license-duration),
    maximum-duration: (var-get maximum-allowed-license-duration)
  }
)

;; PRIVATE VALIDATION AND UTILITY FUNCTIONS

(define-private (verify-contract-administrator-privileges)
  (is-eq tx-sender contract-administrator)
)

(define-private (verify-model-creator-ownership (ai-model-identifier uint))
  (match (get-ai-model-information ai-model-identifier)
    ai-model-data 
      (is-eq tx-sender (get model-creator-address ai-model-data))
    false
  )
)

(define-private (validate-license-duration-parameters (duration-blocks uint))
  (and 
    (>= duration-blocks (var-get minimum-allowed-license-duration))
    (<= duration-blocks (var-get maximum-allowed-license-duration))
  )
)

(define-private (verify-marketplace-operational-status)
  (not (var-get marketplace-operational-status))
)

(define-private (validate-long-text-input (text-input (string-ascii 256)))
  (and 
    (> (len text-input) u0)
    (<= (len text-input) u256)
  )
)

(define-private (validate-short-text-input (text-input (string-ascii 64)))
  (and 
    (> (len text-input) u0)
    (<= (len text-input) u64)
  )
)

(define-private (validate-medium-text-input (text-input (string-ascii 128)))
  (and 
    (> (len text-input) u0)
    (<= (len text-input) u128)
  )
)

(define-private (validate-license-type-parameter (license-type-string (string-ascii 32)))
  (and 
    (> (len license-type-string) u0)
    (<= (len license-type-string) u32)
  )
)

(define-private (validate-version-string-format (version-string (string-ascii 16)))
  (and 
    (> (len version-string) u0)
    (<= (len version-string) u16)
  )
)

(define-private (validate-numeric-value-range (input-value uint) (minimum-value uint) (maximum-value uint))
  (and 
    (>= input-value minimum-value)
    (<= input-value maximum-value)
  )
)

(define-private (validate-hash-string-format (hash-string (string-ascii 64)))
  (and 
    (>= (len hash-string) u32)
    (<= (len hash-string) u64)
  )
)

(define-private (update-model-revenue-analytics 
    (ai-model-identifier uint) 
    (license-payment-amount uint))
  (let (
    (current-revenue-statistics (default-to 
      { 
        total-revenue-earned: u0,
        active-license-subscriptions-count: u0,
        platform-commission-fees-paid: u0,
        last-analytics-update-timestamp: u0
      }
      (get-model-revenue-analytics ai-model-identifier)))
    (calculated-platform-commission (calculate-platform-commission-fee license-payment-amount))
  )
    (map-set revenue-analytics-tracking
      { ai-model-identifier: ai-model-identifier }
      {
        total-revenue-earned: (+ (get total-revenue-earned current-revenue-statistics) license-payment-amount),
        active-license-subscriptions-count: (+ (get active-license-subscriptions-count current-revenue-statistics) u1),
        platform-commission-fees-paid: (+ (get platform-commission-fees-paid current-revenue-statistics) calculated-platform-commission),
        last-analytics-update-timestamp: block-height
      }
    )
  )
)

;; AI MODEL PUBLICATION AND REGISTRATION

(define-public (publish-ai-model-to-marketplace
    (model-title (string-ascii 64))
    (model-description (string-ascii 256))
    (licensing-fee-amount uint)
    (license-validity-duration uint)
    (model-version-string (string-ascii 16))
    (model-file-hash-signature (string-ascii 64))
    (model-file-size-bytes uint)
    (model-accuracy-score uint)
    (training-dataset-information (string-ascii 128))
    (hardware-system-requirements (string-ascii 64))
    (framework-compatibility-list (string-ascii 128)))
  (let (
    (new-model-identifier (var-get next-available-model-id))
  )
    ;; Verify marketplace operational status
    (asserts! (verify-marketplace-operational-status) ERR-UNAUTHORIZED-ACCESS)
    
    ;; Comprehensive input parameter validation
    (asserts! (validate-short-text-input model-title) ERR-INVALID-INPUT-PARAMETERS)
    (asserts! (validate-long-text-input model-description) ERR-INVALID-INPUT-PARAMETERS)
    (asserts! (> licensing-fee-amount u0) ERR-INVALID-INPUT-PARAMETERS)
    (asserts! (validate-license-duration-parameters license-validity-duration) ERR-INVALID-INPUT-PARAMETERS)
    (asserts! (validate-version-string-format model-version-string) ERR-INVALID-INPUT-PARAMETERS)
    (asserts! (validate-hash-string-format model-file-hash-signature) ERR-INVALID-INPUT-PARAMETERS)
    (asserts! (validate-numeric-value-range model-file-size-bytes u1 maximum-model-file-size-bytes) ERR-INVALID-INPUT-PARAMETERS)
    (asserts! (validate-numeric-value-range model-accuracy-score u0 maximum-accuracy-score-basis-points) ERR-INVALID-INPUT-PARAMETERS)
    (asserts! (validate-medium-text-input training-dataset-information) ERR-INVALID-INPUT-PARAMETERS)
    (asserts! (validate-short-text-input hardware-system-requirements) ERR-INVALID-INPUT-PARAMETERS)
    (asserts! (validate-medium-text-input framework-compatibility-list) ERR-INVALID-INPUT-PARAMETERS)
    
    ;; Register AI model in primary marketplace registry
    (map-set ai-model-registry
      { ai-model-identifier: new-model-identifier }
      {
        model-creator-address: tx-sender,
        model-title: model-title,
        model-description: model-description,
        licensing-fee-amount: licensing-fee-amount,
        license-validity-duration: license-validity-duration,
        model-active-status: true,
        model-creation-timestamp: block-height,
        total-license-sales-count: u0
      }
    )
    
    ;; Store comprehensive technical metadata
    (map-set ai-model-technical-metadata
      { ai-model-identifier: new-model-identifier }
      {
        model-version-string: model-version-string,
        model-file-hash-signature: model-file-hash-signature,
        model-file-size-bytes: model-file-size-bytes,
        model-accuracy-score: model-accuracy-score,
        training-dataset-information: training-dataset-information,
        hardware-system-requirements: hardware-system-requirements,
        framework-compatibility-list: framework-compatibility-list
      }
    )
    
    ;; Initialize revenue analytics tracking
    (map-set revenue-analytics-tracking
      { ai-model-identifier: new-model-identifier }
      {
        total-revenue-earned: u0,
        active-license-subscriptions-count: u0,
        platform-commission-fees-paid: u0,
        last-analytics-update-timestamp: block-height
      }
    )
    
    ;; Increment model identifier counter
    (var-set next-available-model-id (+ new-model-identifier u1))
    
    (ok new-model-identifier)
  )
)

;; LICENSE ACQUISITION AND SUBSCRIPTION MANAGEMENT

(define-public (purchase-ai-model-license-subscription 
    (ai-model-identifier uint) 
    (license-subscription-type (string-ascii 32)))
  (let (
    (ai-model-information (unwrap! (get-ai-model-information ai-model-identifier) ERR-AI-MODEL-NOT-FOUND))
    (total-license-cost (get licensing-fee-amount ai-model-information))
    (calculated-platform-commission (calculate-platform-commission-fee total-license-cost))
    (creator-payment-amount (- total-license-cost calculated-platform-commission))
    (license-expiration-block (+ block-height (get license-validity-duration ai-model-information)))
  )
    ;; Verify marketplace and model availability
    (asserts! (verify-marketplace-operational-status) ERR-UNAUTHORIZED-ACCESS)
    (asserts! (get model-active-status ai-model-information) ERR-AI-MODEL-CURRENTLY-UNAVAILABLE)
    (asserts! (validate-license-type-parameter license-subscription-type) ERR-INVALID-INPUT-PARAMETERS)
    
    ;; Prevent duplicate active license subscriptions
    (asserts! (not (verify-license-subscription-validity ai-model-identifier tx-sender)) ERR-ACTIVE-LICENSE-ALREADY-EXISTS)
    
    ;; Process secure payment transfers
    (try! (stx-transfer? creator-payment-amount tx-sender (get model-creator-address ai-model-information)))
    (try! (stx-transfer? calculated-platform-commission tx-sender contract-administrator))
    
    ;; Create new license subscription record
    (map-set license-subscription-registry
      { ai-model-identifier: ai-model-identifier, license-holder-address: tx-sender }
      {
        license-expiration-block: license-expiration-block,
        license-purchase-timestamp: block-height,
        license-subscription-type: license-subscription-type,
        license-payment-amount: total-license-cost
      }
    )
    
    ;; Update model sales statistics
    (map-set ai-model-registry
      { ai-model-identifier: ai-model-identifier }
      (merge ai-model-information 
        { total-license-sales-count: (+ (get total-license-sales-count ai-model-information) u1) })
    )
    
    ;; Update comprehensive revenue analytics
    (update-model-revenue-analytics ai-model-identifier total-license-cost)
    
    (ok true)
  )
)

(define-public (renew-license-subscription (ai-model-identifier uint))
  (let (
    (ai-model-information (unwrap! (get-ai-model-information ai-model-identifier) ERR-AI-MODEL-NOT-FOUND))
    (existing-license-subscription (unwrap! (get-license-subscription-details ai-model-identifier tx-sender) ERR-AI-MODEL-NOT-FOUND))
    (license-renewal-cost (get licensing-fee-amount ai-model-information))
    (calculated-platform-commission (calculate-platform-commission-fee license-renewal-cost))
    (creator-payment-amount (- license-renewal-cost calculated-platform-commission))
    (new-license-expiration-block (+ block-height (get license-validity-duration ai-model-information)))
  )
    ;; Verify marketplace operational status
    (asserts! (verify-marketplace-operational-status) ERR-UNAUTHORIZED-ACCESS)
    (asserts! (get model-active-status ai-model-information) ERR-AI-MODEL-CURRENTLY-UNAVAILABLE)
    
    ;; Process license renewal payments
    (try! (stx-transfer? creator-payment-amount tx-sender (get model-creator-address ai-model-information)))
    (try! (stx-transfer? calculated-platform-commission tx-sender contract-administrator))
    
    ;; Update license subscription with extended expiration
    (map-set license-subscription-registry
      { ai-model-identifier: ai-model-identifier, license-holder-address: tx-sender }
      (merge existing-license-subscription 
        { license-expiration-block: new-license-expiration-block })
    )
    
    ;; Update revenue analytics for renewal
    (update-model-revenue-analytics ai-model-identifier license-renewal-cost)
    
    (ok true)
  )
)

;; AI MODEL MANAGEMENT FUNCTIONS

(define-public (update-ai-model-information
    (ai-model-identifier uint)
    (updated-model-title (string-ascii 64))
    (updated-model-description (string-ascii 256))
    (updated-licensing-fee-amount uint)
    (updated-license-validity-duration uint))
  (let (
    (current-model-information (unwrap! (get-ai-model-information ai-model-identifier) ERR-AI-MODEL-NOT-FOUND))
  )
    ;; Verify authorization and input validation
    (asserts! (verify-marketplace-operational-status) ERR-UNAUTHORIZED-ACCESS)
    (asserts! (verify-model-creator-ownership ai-model-identifier) ERR-ACCESS-PERMISSION-DENIED)
    (asserts! (validate-short-text-input updated-model-title) ERR-INVALID-INPUT-PARAMETERS)
    (asserts! (validate-long-text-input updated-model-description) ERR-INVALID-INPUT-PARAMETERS)
    (asserts! (> updated-licensing-fee-amount u0) ERR-INVALID-INPUT-PARAMETERS)
    (asserts! (validate-license-duration-parameters updated-license-validity-duration) ERR-INVALID-INPUT-PARAMETERS)
    
    ;; Update AI model information in registry
    (map-set ai-model-registry
      { ai-model-identifier: ai-model-identifier }
      (merge current-model-information {
        model-title: updated-model-title,
        model-description: updated-model-description,
        licensing-fee-amount: updated-licensing-fee-amount,
        license-validity-duration: updated-license-validity-duration
      })
    )
    
    (ok true)
  )
)

(define-public (update-ai-model-technical-specifications
    (ai-model-identifier uint)
    (updated-model-version-string (string-ascii 16))
    (updated-model-file-hash-signature (string-ascii 64))
    (updated-model-file-size-bytes uint)
    (updated-model-accuracy-score uint)
    (updated-training-dataset-information (string-ascii 128))
    (updated-hardware-system-requirements (string-ascii 64))
    (updated-framework-compatibility-list (string-ascii 128)))
  (begin
    ;; Verify authorization and comprehensive input validation
    (asserts! (verify-marketplace-operational-status) ERR-UNAUTHORIZED-ACCESS)
    (asserts! (is-some (get-ai-model-information ai-model-identifier)) ERR-AI-MODEL-NOT-FOUND)
    (asserts! (verify-model-creator-ownership ai-model-identifier) ERR-ACCESS-PERMISSION-DENIED)
    (asserts! (validate-version-string-format updated-model-version-string) ERR-INVALID-INPUT-PARAMETERS)
    (asserts! (validate-hash-string-format updated-model-file-hash-signature) ERR-INVALID-INPUT-PARAMETERS)
    (asserts! (validate-numeric-value-range updated-model-file-size-bytes u1 maximum-model-file-size-bytes) ERR-INVALID-INPUT-PARAMETERS)
    (asserts! (validate-numeric-value-range updated-model-accuracy-score u0 maximum-accuracy-score-basis-points) ERR-INVALID-INPUT-PARAMETERS)
    (asserts! (validate-medium-text-input updated-training-dataset-information) ERR-INVALID-INPUT-PARAMETERS)
    (asserts! (validate-short-text-input updated-hardware-system-requirements) ERR-INVALID-INPUT-PARAMETERS)
    (asserts! (validate-medium-text-input updated-framework-compatibility-list) ERR-INVALID-INPUT-PARAMETERS)
    
    ;; Update comprehensive technical metadata
    (map-set ai-model-technical-metadata
      { ai-model-identifier: ai-model-identifier }
      {
        model-version-string: updated-model-version-string,
        model-file-hash-signature: updated-model-file-hash-signature,
        model-file-size-bytes: updated-model-file-size-bytes,
        model-accuracy-score: updated-model-accuracy-score,
        training-dataset-information: updated-training-dataset-information,
        hardware-system-requirements: updated-hardware-system-requirements,
        framework-compatibility-list: updated-framework-compatibility-list
      }
    )
    
    (ok true)
  )
)

(define-public (deactivate-ai-model-from-marketplace (ai-model-identifier uint))
  (let (
    (current-model-information (unwrap! (get-ai-model-information ai-model-identifier) ERR-AI-MODEL-NOT-FOUND))
  )
    (asserts! (verify-marketplace-operational-status) ERR-UNAUTHORIZED-ACCESS)
    (asserts! (verify-model-creator-ownership ai-model-identifier) ERR-ACCESS-PERMISSION-DENIED)
    
    (map-set ai-model-registry
      { ai-model-identifier: ai-model-identifier }
      (merge current-model-information { model-active-status: false })
    )
    
    (ok true)
  )
)

(define-public (reactivate-ai-model-in-marketplace (ai-model-identifier uint))
  (let (
    (current-model-information (unwrap! (get-ai-model-information ai-model-identifier) ERR-AI-MODEL-NOT-FOUND))
  )
    (asserts! (verify-marketplace-operational-status) ERR-UNAUTHORIZED-ACCESS)
    (asserts! (verify-model-creator-ownership ai-model-identifier) ERR-ACCESS-PERMISSION-DENIED)
    
    (map-set ai-model-registry
      { ai-model-identifier: ai-model-identifier }
      (merge current-model-information { model-active-status: true })
    )
    
    (ok true)
  )
)

;; PLATFORM ADMINISTRATION AND GOVERNANCE

(define-public (configure-platform-commission-rate (updated-commission-rate uint))
  (begin
    (asserts! (verify-contract-administrator-privileges) ERR-UNAUTHORIZED-ACCESS)
    (asserts! (<= updated-commission-rate maximum-platform-commission-rate) ERR-INVALID-INPUT-PARAMETERS)
    (var-set current-platform-commission-rate updated-commission-rate)
    (ok true)
  )
)

(define-public (update-license-duration-constraints 
    (updated-minimum-duration uint) 
    (updated-maximum-duration uint))
  (begin
    (asserts! (verify-contract-administrator-privileges) ERR-UNAUTHORIZED-ACCESS)
    (asserts! (< updated-minimum-duration updated-maximum-duration) ERR-INVALID-INPUT-PARAMETERS)
    (var-set minimum-allowed-license-duration updated-minimum-duration)
    (var-set maximum-allowed-license-duration updated-maximum-duration)
    (ok true)
  )
)

(define-public (suspend-marketplace-operations)
  (begin
    (asserts! (verify-contract-administrator-privileges) ERR-UNAUTHORIZED-ACCESS)
    (var-set marketplace-operational-status true)
    (ok true)
  )
)

(define-public (resume-marketplace-operations)
  (begin
    (asserts! (verify-contract-administrator-privileges) ERR-UNAUTHORIZED-ACCESS)
    (var-set marketplace-operational-status false)
    (ok true)
  )
)

(define-public (admin-deactivate-ai-model (ai-model-identifier uint))
  (let (
    (current-model-information (unwrap! (get-ai-model-information ai-model-identifier) ERR-AI-MODEL-NOT-FOUND))
  )
    (asserts! (verify-contract-administrator-privileges) ERR-UNAUTHORIZED-ACCESS)
    (asserts! (> ai-model-identifier u0) ERR-INVALID-INPUT-PARAMETERS)
    
    (map-set ai-model-registry
      { ai-model-identifier: ai-model-identifier }
      (merge current-model-information { model-active-status: false })
    )
    
    (ok true)
  )
)