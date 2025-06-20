;; Decentralized Professional Services Marketplace Contract
;; 
;; A comprehensive blockchain-based marketplace system that facilitates secure
;; professional service engagements between freelancers and clients. Features
;; include automated contract lifecycle management, escrow-style payment handling,
;; integrated dispute resolution mechanisms, and transparent reputation scoring
;; for service providers in a trustless environment.

;; SYSTEM ERROR DEFINITIONS

(define-constant ERR-ACCESS-DENIED-UNAUTHORIZED-USER (err u100))
(define-constant ERR-DUPLICATE-SERVICE-CONTRACT-EXISTS (err u101))
(define-constant ERR-SERVICE-CONTRACT-RECORD-NOT-FOUND (err u102))
(define-constant ERR-INVALID-CONTRACT-STATE-TRANSITION (err u103))
(define-constant ERR-PAYMENT-AMOUNT-BELOW-MINIMUM-THRESHOLD (err u104))
(define-constant ERR-MALFORMED-BLOCKCHAIN-ADDRESS-FORMAT (err u105))
(define-constant ERR-INPUT-VALIDATION-FAILED-PARAMETERS (err u106))

;; GLOBAL CONTRACT CONFIGURATION

(define-data-var marketplace-administrator-wallet-address principal tx-sender)
(define-data-var total-processed-service-contracts-counter uint u0)
(define-data-var platform-active-status-flag bool true)


;; CORE DATA ARCHITECTURE


;; Professional service engagement contract registry
(define-map professional-service-engagement-database
    { 
        engagement-contract-unique-identifier: uint 
    }
    {
        freelancer-wallet-blockchain-address: principal,
        client-organization-wallet-address: principal,
        engagement-commencement-timestamp: uint,
        engagement-completion-deadline-timestamp: uint,
        mutually-agreed-compensation-amount: uint,
        contract-execution-workflow-status: (string-ascii 35),
        comprehensive-service-specification-document: (string-ascii 256)
    }
)

;; Freelancer marketplace reputation and performance analytics
(define-map freelancer-reputation-analytics-dashboard
    { 
        freelancer-blockchain-wallet-identifier: principal 
    }
    {
        weighted-average-client-satisfaction-score: uint,
        cumulative-lifetime-engagement-contracts-count: uint,
        successfully-delivered-projects-completion-count: uint,
        marketplace-registration-timestamp: uint,
        freelancer-specialization-category-tag: (string-ascii 50)
    }
)

;; Client organization profile and engagement history
(define-map client-organization-profile-registry
    {
        client-organization-wallet: principal
    }
    {
        organization-display-name: (string-ascii 100),
        total-initiated-service-contracts: uint,
        average-project-budget-allocation: uint,
        client-registration-block-height: uint
    }
)

;; Comprehensive dispute management and resolution system
(define-map service-contract-dispute-resolution-database
    { 
        disputed-engagement-contract-identifier: uint 
    }
    {
        dispute-filing-party-wallet-address: principal,
        detailed-dispute-circumstances-description: (string-ascii 256),
        dispute-arbitration-workflow-status: (string-ascii 35),
        administrative-resolution-decision-documentation: (optional (string-ascii 256)),
        dispute-submission-blockchain-timestamp: uint,
        estimated-dispute-resolution-timeline: uint
    }
)

;; PLATFORM ADMINISTRATION AND GOVERNANCE

;; Transfer administrative control to new marketplace operator
(define-public (transfer-marketplace-administrative-privileges 
    (incoming-administrator-wallet-address principal))
    (begin
        (asserts! (is-eq tx-sender (var-get marketplace-administrator-wallet-address)) 
                  ERR-ACCESS-DENIED-UNAUTHORIZED-USER)
        (asserts! (validate-blockchain-wallet-address-format incoming-administrator-wallet-address) 
                  ERR-MALFORMED-BLOCKCHAIN-ADDRESS-FORMAT)
        (var-set marketplace-administrator-wallet-address incoming-administrator-wallet-address)
        (ok true)
    )
)

;; Toggle platform operational status for maintenance
(define-public (modify-platform-operational-status (new-operational-state bool))
    (begin
        (asserts! (is-eq tx-sender (var-get marketplace-administrator-wallet-address)) 
                  ERR-ACCESS-DENIED-UNAUTHORIZED-USER)
        (var-set platform-active-status-flag new-operational-state)
        (ok true)
    )
)

;; SERVICE CONTRACT LIFECYCLE ORCHESTRATION

;; Initialize new professional service engagement contract
(define-public (establish-new-professional-service-engagement
    (unique-engagement-contract-number uint)
    (selected-freelancer-service-provider principal)
    (requesting-client-organization principal)
    (project-commencement-block-timestamp uint)
    (project-delivery-deadline-timestamp uint)
    (negotiated-total-project-compensation uint)
    (detailed-project-requirements-specification (string-ascii 256)))
    
    (let ((platform-operational-check (var-get platform-active-status-flag))
          (existing-contract-verification (query-service-engagement-contract-details 
                                         unique-engagement-contract-number)))
        
        (asserts! platform-operational-check ERR-ACCESS-DENIED-UNAUTHORIZED-USER)
        (asserts! (is-none existing-contract-verification) ERR-DUPLICATE-SERVICE-CONTRACT-EXISTS)
        (asserts! (>= project-delivery-deadline-timestamp project-commencement-block-timestamp) 
                  ERR-INVALID-CONTRACT-STATE-TRANSITION)
        (asserts! (> negotiated-total-project-compensation u0) 
                  ERR-PAYMENT-AMOUNT-BELOW-MINIMUM-THRESHOLD)
        (asserts! (validate-blockchain-wallet-address-format selected-freelancer-service-provider) 
                  ERR-MALFORMED-BLOCKCHAIN-ADDRESS-FORMAT)
        (asserts! (validate-blockchain-wallet-address-format requesting-client-organization) 
                  ERR-MALFORMED-BLOCKCHAIN-ADDRESS-FORMAT)
        (asserts! (validate-text-content-length-requirements detailed-project-requirements-specification) 
                  ERR-INPUT-VALIDATION-FAILED-PARAMETERS)
        
        ;; Register new service engagement contract
        (map-set professional-service-engagement-database
            { engagement-contract-unique-identifier: unique-engagement-contract-number }
            {
                freelancer-wallet-blockchain-address: selected-freelancer-service-provider,
                client-organization-wallet-address: requesting-client-organization,
                engagement-commencement-timestamp: project-commencement-block-timestamp,
                engagement-completion-deadline-timestamp: project-delivery-deadline-timestamp,
                mutually-agreed-compensation-amount: negotiated-total-project-compensation,
                contract-execution-workflow-status: "awaiting-freelancer-acceptance",
                comprehensive-service-specification-document: detailed-project-requirements-specification
            }
        )
        
        ;; Update marketplace statistics and participant profiles
        (initialize-or-update-freelancer-profile-metrics selected-freelancer-service-provider)
        (initialize-or-update-client-organization-profile requesting-client-organization)
        (var-set total-processed-service-contracts-counter 
                 (+ (var-get total-processed-service-contracts-counter) u1))
        (ok true)
    )
)

;; Freelancer confirms acceptance of service engagement terms
(define-public (confirm-freelancer-engagement-acceptance 
    (target-engagement-contract-identifier uint))
    (let ((engagement-contract-information 
           (unwrap! (query-service-engagement-contract-details target-engagement-contract-identifier) 
                    ERR-SERVICE-CONTRACT-RECORD-NOT-FOUND)))
        
        (asserts! (is-eq (get contract-execution-workflow-status engagement-contract-information) 
                         "awaiting-freelancer-acceptance") 
                  ERR-INVALID-CONTRACT-STATE-TRANSITION)
        (asserts! (is-eq tx-sender (get freelancer-wallet-blockchain-address engagement-contract-information)) 
                  ERR-ACCESS-DENIED-UNAUTHORIZED-USER)
        
        (map-set professional-service-engagement-database
            { engagement-contract-unique-identifier: target-engagement-contract-identifier }
            (merge engagement-contract-information 
                   { contract-execution-workflow-status: "active-development-phase" })
        )
        (ok true)
    )
)

;; Client validates and approves completed service deliverables
(define-public (approve-completed-service-deliverables 
    (target-engagement-contract-identifier uint))
    (let ((engagement-contract-information 
           (unwrap! (query-service-engagement-contract-details target-engagement-contract-identifier) 
                    ERR-SERVICE-CONTRACT-RECORD-NOT-FOUND)))
        
        (asserts! (is-eq (get contract-execution-workflow-status engagement-contract-information) 
                         "active-development-phase") 
                  ERR-INVALID-CONTRACT-STATE-TRANSITION)
        (asserts! (is-eq tx-sender (get client-organization-wallet-address engagement-contract-information)) 
                  ERR-ACCESS-DENIED-UNAUTHORIZED-USER)
        
        ;; Finalize contract as successfully completed
        (map-set professional-service-engagement-database
            { engagement-contract-unique-identifier: target-engagement-contract-identifier }
            (merge engagement-contract-information 
                   { contract-execution-workflow-status: "successfully-completed-approved" })
        )
        
        ;; Update freelancer success metrics
        (increment-freelancer-successful-completion-statistics 
         (get freelancer-wallet-blockchain-address engagement-contract-information))
        (ok true)
    )
)

;; DISPUTE RESOLUTION AND ARBITRATION SYSTEM

;; Submit formal dispute regarding service engagement quality or terms
(define-public (submit-formal-service-engagement-dispute
    (disputed-contract-identifier uint)
    (comprehensive-dispute-explanation-documentation (string-ascii 256)))
    
    (let ((engagement-contract-information 
           (unwrap! (query-service-engagement-contract-details disputed-contract-identifier) 
                    ERR-SERVICE-CONTRACT-RECORD-NOT-FOUND)))
        
        (asserts! (or (is-eq tx-sender (get freelancer-wallet-blockchain-address engagement-contract-information))
                      (is-eq tx-sender (get client-organization-wallet-address engagement-contract-information))) 
                  ERR-ACCESS-DENIED-UNAUTHORIZED-USER)
        (asserts! (validate-text-content-length-requirements comprehensive-dispute-explanation-documentation) 
                  ERR-INPUT-VALIDATION-FAILED-PARAMETERS)
        
        ;; Create comprehensive dispute record
        (map-set service-contract-dispute-resolution-database
            { disputed-engagement-contract-identifier: disputed-contract-identifier }
            {
                dispute-filing-party-wallet-address: tx-sender,
                detailed-dispute-circumstances-description: comprehensive-dispute-explanation-documentation,
                dispute-arbitration-workflow-status: "pending-administrative-review",
                administrative-resolution-decision-documentation: none,
                dispute-submission-blockchain-timestamp: block-height,
                estimated-dispute-resolution-timeline: (+ block-height u144) ;; ~24 hours in blocks
            }
        )
        
        ;; Update contract status to reflect active dispute
        (map-set professional-service-engagement-database
            { engagement-contract-unique-identifier: disputed-contract-identifier }
            (merge engagement-contract-information 
                   { contract-execution-workflow-status: "under-dispute-arbitration-review" })
        )
        (ok true)
    )
)

;; Administrative resolution of contested service engagement disputes
(define-public (execute-administrative-dispute-resolution
    (disputed-contract-identifier uint)
    (comprehensive-resolution-decision-documentation (string-ascii 256))
    (final-contract-status-determination (string-ascii 35)))
    
    (let ((engagement-contract-information 
           (unwrap! (query-service-engagement-contract-details disputed-contract-identifier) 
                    ERR-SERVICE-CONTRACT-RECORD-NOT-FOUND))
          (dispute-case-information 
           (unwrap! (query-dispute-resolution-case-details disputed-contract-identifier) 
                    ERR-SERVICE-CONTRACT-RECORD-NOT-FOUND)))
        
        (asserts! (is-eq tx-sender (var-get marketplace-administrator-wallet-address)) 
                  ERR-ACCESS-DENIED-UNAUTHORIZED-USER)
        (asserts! (is-eq (get contract-execution-workflow-status engagement-contract-information) 
                         "under-dispute-arbitration-review") 
                  ERR-INVALID-CONTRACT-STATE-TRANSITION)
        (asserts! (validate-contract-status-transition-rules final-contract-status-determination) 
                  ERR-INVALID-CONTRACT-STATE-TRANSITION)
        (asserts! (validate-text-content-length-requirements comprehensive-resolution-decision-documentation) 
                  ERR-INPUT-VALIDATION-FAILED-PARAMETERS)
        
        ;; Document final dispute resolution decision
        (map-set service-contract-dispute-resolution-database
            { disputed-engagement-contract-identifier: disputed-contract-identifier }
            (merge dispute-case-information {
                dispute-arbitration-workflow-status: "administratively-resolved-final",
                administrative-resolution-decision-documentation: 
                (some comprehensive-resolution-decision-documentation)
            })
        )
        
        ;; Apply final contract status based on resolution
        (map-set professional-service-engagement-database
            { engagement-contract-unique-identifier: disputed-contract-identifier }
            (merge engagement-contract-information 
                   { contract-execution-workflow-status: final-contract-status-determination })
        )
        (ok true)
    )
)

;; REPUTATION AND QUALITY ASSURANCE SYSTEM

;; Submit comprehensive freelancer performance evaluation and rating
(define-public (submit-freelancer-performance-quality-evaluation
    (evaluated-freelancer-wallet-address principal)
    (client-satisfaction-rating-score uint)
    (service-specialization-category (string-ascii 50)))
    
    (let ((freelancer-reputation-profile 
           (unwrap! (map-get? freelancer-reputation-analytics-dashboard 
                            { freelancer-blockchain-wallet-identifier: evaluated-freelancer-wallet-address }) 
                    ERR-SERVICE-CONTRACT-RECORD-NOT-FOUND)))
        
        (asserts! (validate-blockchain-wallet-address-format evaluated-freelancer-wallet-address) 
                  ERR-MALFORMED-BLOCKCHAIN-ADDRESS-FORMAT)
        (asserts! (and (<= client-satisfaction-rating-score u5) (> client-satisfaction-rating-score u0)) 
                  ERR-INVALID-CONTRACT-STATE-TRANSITION)
        
        ;; Update freelancer reputation with weighted average calculation
        (map-set freelancer-reputation-analytics-dashboard
            { freelancer-blockchain-wallet-identifier: evaluated-freelancer-wallet-address }
            (merge freelancer-reputation-profile {
                weighted-average-client-satisfaction-score: 
                (calculate-updated-weighted-reputation-average 
                    (get weighted-average-client-satisfaction-score freelancer-reputation-profile)
                    (get cumulative-lifetime-engagement-contracts-count freelancer-reputation-profile)
                    client-satisfaction-rating-score),
                freelancer-specialization-category-tag: service-specialization-category
            })
        )
        (ok true)
    )
)


;; PUBLIC DATA QUERY AND RETRIEVAL INTERFACE


(define-read-only (query-service-engagement-contract-details 
    (engagement-contract-identifier uint))
    (map-get? professional-service-engagement-database 
              { engagement-contract-unique-identifier: engagement-contract-identifier })
)

(define-read-only (query-freelancer-reputation-and-performance-metrics 
    (freelancer-wallet-address principal))
    (map-get? freelancer-reputation-analytics-dashboard 
              { freelancer-blockchain-wallet-identifier: freelancer-wallet-address })
)

(define-read-only (query-client-organization-profile-information 
    (client-wallet-address principal))
    (map-get? client-organization-profile-registry 
              { client-organization-wallet: client-wallet-address })
)

(define-read-only (query-dispute-resolution-case-details 
    (disputed-contract-identifier uint))
    (map-get? service-contract-dispute-resolution-database 
              { disputed-engagement-contract-identifier: disputed-contract-identifier })
)

(define-read-only (get-current-marketplace-administrator-address)
    (var-get marketplace-administrator-wallet-address)
)

(define-read-only (get-total-platform-contract-processing-statistics)
    (var-get total-processed-service-contracts-counter)
)

(define-read-only (get-current-platform-operational-status)
    (var-get platform-active-status-flag)
)

;; INTERNAL BUSINESS LOGIC AND HELPER FUNCTIONS

;; Initialize or update freelancer marketplace profile and engagement statistics
(define-private (initialize-or-update-freelancer-profile-metrics 
    (freelancer-wallet-address principal))
    (match (map-get? freelancer-reputation-analytics-dashboard 
                     { freelancer-blockchain-wallet-identifier: freelancer-wallet-address })
        existing-freelancer-profile-data
        (map-set freelancer-reputation-analytics-dashboard
            { freelancer-blockchain-wallet-identifier: freelancer-wallet-address }
            (merge existing-freelancer-profile-data {
                cumulative-lifetime-engagement-contracts-count: 
                (+ (get cumulative-lifetime-engagement-contracts-count existing-freelancer-profile-data) u1)
            })
        )
        (map-set freelancer-reputation-analytics-dashboard
            { freelancer-blockchain-wallet-identifier: freelancer-wallet-address }
            {
                weighted-average-client-satisfaction-score: u0,
                cumulative-lifetime-engagement-contracts-count: u1,
                successfully-delivered-projects-completion-count: u0,
                marketplace-registration-timestamp: block-height,
                freelancer-specialization-category-tag: "general-services"
            }
        )
    )
)

;; Initialize or update client organization marketplace profile
(define-private (initialize-or-update-client-organization-profile 
    (client-organization-wallet principal))
    (match (map-get? client-organization-profile-registry 
                     { client-organization-wallet: client-organization-wallet })
        existing-client-profile-data
        (map-set client-organization-profile-registry
            { client-organization-wallet: client-organization-wallet }
            (merge existing-client-profile-data {
                total-initiated-service-contracts: 
                (+ (get total-initiated-service-contracts existing-client-profile-data) u1)
            })
        )
        (map-set client-organization-profile-registry
            { client-organization-wallet: client-organization-wallet }
            {
                organization-display-name: "Registered-Client-Organization",
                total-initiated-service-contracts: u1,
                average-project-budget-allocation: u0,
                client-registration-block-height: block-height
            }
        )
    )
)

;; Update freelancer successful project completion statistics
(define-private (increment-freelancer-successful-completion-statistics 
    (freelancer-wallet-address principal))
    (match (map-get? freelancer-reputation-analytics-dashboard 
                     { freelancer-blockchain-wallet-identifier: freelancer-wallet-address })
        freelancer-reputation-data
        (begin
            (map-set freelancer-reputation-analytics-dashboard
                { freelancer-blockchain-wallet-identifier: freelancer-wallet-address }
                (merge freelancer-reputation-data {
                    successfully-delivered-projects-completion-count: 
                    (+ (get successfully-delivered-projects-completion-count freelancer-reputation-data) u1)
                })
            )
            true
        )
        false
    )
)

;; Calculate updated weighted average reputation score
(define-private (calculate-updated-weighted-reputation-average
    (current-weighted-average-score uint)
    (total-historical-engagements uint)
    (new-client-rating-input uint))
    (/ (+ (* current-weighted-average-score total-historical-engagements) new-client-rating-input)
       (+ total-historical-engagements u1))
)

;; DATA VALIDATION AND SECURITY FUNCTIONS

;; Validate contract status transition business rules
(define-private (validate-contract-status-transition-rules 
    (proposed-status-value (string-ascii 35)))
    (or (is-eq proposed-status-value "awaiting-freelancer-acceptance")
        (is-eq proposed-status-value "active-development-phase")
        (is-eq proposed-status-value "successfully-completed-approved")
        (is-eq proposed-status-value "under-dispute-arbitration-review")
        (is-eq proposed-status-value "administratively-cancelled")
        (is-eq proposed-status-value "payment-processing-completed"))
)

;; Validate blockchain wallet address format and integrity
(define-private (validate-blockchain-wallet-address-format 
    (target-wallet-address principal))
    (and (not (is-eq target-wallet-address tx-sender))
         (is-ok (principal-destruct? target-wallet-address)))
)

;; Validate text content meets length and quality requirements
(define-private (validate-text-content-length-requirements 
    (text-content-input (string-ascii 256)))
    (and (>= (len text-content-input) u1)
         (<= (len text-content-input) u256))
)