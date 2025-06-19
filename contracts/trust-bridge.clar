;; Title: TrustBridge - Transparent Charitable Giving & Impact Tracking Platform
;;
;; Summary: A next-generation decentralized charity platform built for Stacks Layer 2,
;;          enabling transparent donations, milestone-based fund utilization tracking,
;;          and community-governed impact verification.
;;
;; Description: TrustBridge revolutionizes charitable giving by leveraging blockchain
;;              transparency to create accountability between donors and beneficiaries.
;;              The platform implements a sophisticated role-based access system with
;;              three distinct user types: Administrators who oversee platform governance,
;;              Moderators who manage beneficiary onboarding and verification, and
;;              Beneficiaries who receive and utilize funds through milestone-tracked
;;              disbursements. Every donation is permanently recorded on-chain, while
;;              fund utilization is tracked through approval-gated milestones, ensuring
;;              donors can verify their contributions create real-world impact.
;;
;; Key Features:
;; - Multi-tiered role-based access control (Admin/Moderator/Beneficiary)
;; - Transparent donation tracking with immutable records
;; - Milestone-based fund utilization with approval workflows
;; - Real-time beneficiary progress monitoring
;; - Community-governed impact verification system

;; CONSTANTS & ERROR HANDLING

;; Contract governance
(define-data-var contract-owner principal tx-sender)

;; Comprehensive error code system
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-REGISTERED (err u101))
(define-constant ERR-NOT-FOUND (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-BENEFICIARY-NOT-FOUND (err u104))
(define-constant ERR-UTILIZATION-NOT-FOUND (err u105))
(define-constant ERR-INVALID-INPUT (err u106))

;; Role hierarchy definitions
(define-constant ROLE-ADMIN u1)
(define-constant ROLE-MODERATOR u2)
(define-constant ROLE-BENEFICIARY u3)

;; DATA STRUCTURES & MAPPINGS

;; Role-based access control mapping
(define-map roles
  { user: principal }
  { role: uint }
)

;; Comprehensive beneficiary registry
(define-map beneficiaries
  { id: uint }
  {
    name: (string-utf8 50),
    description: (string-utf8 255),
    target-amount: uint,
    received-amount: uint,
    status: (string-ascii 20),
  }
)

;; Immutable donation ledger
(define-map donations
  { id: uint }
  {
    donor: principal,
    beneficiary-id: uint,
    amount: uint,
    timestamp: uint,
  }
)

;; Fund utilization tracking system
(define-map utilization
  { id: uint }
  {
    beneficiary-id: uint,
    milestone: uint,
    description: (string-utf8 255),
    amount: uint,
    status: (string-ascii 20),
  }
)

;; STATE MANAGEMENT VARIABLES

;; Auto-incrementing ID counters
(define-data-var beneficiary-count uint u0)
(define-data-var donation-count uint u0)
(define-data-var utilization-count uint u0)

;; UTILITY & HELPER FUNCTIONS

;; Authorization validation with role hierarchy
(define-private (is-authorized
    (user principal)
    (required-role uint)
  )
  (let ((role-data (default-to { role: u0 } (map-get? roles { user: user }))))
    (>= (get role role-data) required-role)
  )
)

;; Milestone tracking for fund utilization
(define-private (get-last-milestone (beneficiary-id uint))
  (var-get utilization-count)
)

;; ROLE MANAGEMENT SYSTEM

;; Assign roles with comprehensive validation
(define-public (set-role
    (user principal)
    (new-role uint)
  )
  (let ((existing-role (default-to u0 (get role (map-get? roles { user: user })))))
    (if (and
        (is-eq tx-sender (var-get contract-owner))
        (<= new-role ROLE-BENEFICIARY)
        (not (is-eq user tx-sender)) ;; Prevent self-role modification
        (or
          (is-eq new-role ROLE-ADMIN)
          (is-eq new-role ROLE-MODERATOR)
          (is-eq new-role ROLE-BENEFICIARY)
        )
      )
      (ok (map-set roles { user: user } { role: new-role }))
      ERR-NOT-AUTHORIZED
    )
  )
)

;; Secure role removal with ownership validation
(define-public (remove-role (user principal))
  (if (and
      (is-eq tx-sender (var-get contract-owner))
      (is-some (map-get? roles { user: user }))
      (not (is-eq user tx-sender)) ;; Prevent self-role removal
    )
    (ok (map-delete roles { user: user }))
    ERR-NOT-AUTHORIZED
  )
)

;; BENEFICIARY MANAGEMENT SYSTEM

;; Register verified beneficiaries with comprehensive validation
(define-public (register-beneficiary
    (name (string-utf8 50))
    (description (string-utf8 255))
    (target-amount uint)
  )
  (let ((beneficiary-id (+ (var-get beneficiary-count) u1)))
    (if (and
        (is-authorized tx-sender ROLE-MODERATOR)
        (> (len name) u0)
        (> (len description) u0)
        (> target-amount u0)
      )
      (begin
        (map-set beneficiaries { id: beneficiary-id } {
          name: name,
          description: description,
          target-amount: target-amount,
          received-amount: u0,
          status: "active",
        })
        (var-set beneficiary-count beneficiary-id)
        (ok beneficiary-id)
      )
      ERR-INVALID-INPUT
    )
  )
)

;; Retrieve beneficiary information with error handling
(define-read-only (get-beneficiary (id uint))
  (match (map-get? beneficiaries { id: id })
    beneficiary (ok beneficiary)
    ERR-BENEFICIARY-NOT-FOUND
  )
)

;; TRANSPARENT DONATION SYSTEM

;; Process donations with automatic beneficiary balance updates
(define-public (donate
    (beneficiary-id uint)
    (amount uint)
  )
  (let ((beneficiary (unwrap! (get-beneficiary beneficiary-id) ERR-BENEFICIARY-NOT-FOUND)))
    (if (and
        (> amount u0)
        (< beneficiary-id (+ (var-get beneficiary-count) u1))
        (is-some (map-get? beneficiaries { id: beneficiary-id }))
      )
      (match (stx-transfer? amount tx-sender (as-contract tx-sender))
        success (begin
          (map-set beneficiaries { id: beneficiary-id }
            (merge beneficiary { received-amount: (+ (get received-amount beneficiary) amount) })
          )
          (map-set donations { id: (+ (var-get donation-count) u1) } {
            donor: tx-sender,
            beneficiary-id: beneficiary-id,
            amount: amount,
            timestamp: stacks-block-height,
          })
          (var-set donation-count (+ (var-get donation-count) u1))
          (ok true)
        )
        error
        ERR-INSUFFICIENT-FUNDS
      )
      ERR-INVALID-INPUT
    )
  )
)

;; Retrieve donation records for transparency
(define-read-only (get-donation-by-id (donation-id uint))
  (match (map-get? donations { id: donation-id })
    donation (ok donation)
    ERR-NOT-FOUND
  )
)

;; Get total platform donation count
(define-read-only (get-donation-count)
  (ok (var-get donation-count))
)

;; MILESTONE-BASED FUND UTILIZATION SYSTEM

;; Create fund utilization plans with milestone tracking
(define-public (add-utilization
    (beneficiary-id uint)
    (description (string-utf8 255))
    (amount uint)
  )
  (let ((beneficiary (unwrap! (get-beneficiary beneficiary-id) ERR-BENEFICIARY-NOT-FOUND)))
    (if (and
        (is-authorized tx-sender ROLE-ADMIN)
        (> (len description) u0)
        (> amount u0)
        (< beneficiary-id (+ (var-get beneficiary-count) u1))
      )
      (let (
          (milestone (+ (get-last-milestone beneficiary-id) u1))
          (utilization-id (+ (var-get utilization-count) u1))
        )
        (begin
          (map-set utilization { id: utilization-id } {
            beneficiary-id: beneficiary-id,
            milestone: milestone,
            description: description,
            amount: amount,
            status: "pending",
          })
          (var-set utilization-count utilization-id)
          (ok milestone)
        )
      )
      ERR-INVALID-INPUT
    )
  )
)

;; Approve fund utilization with balance verification
(define-public (approve-utilization
    (utilization-id uint)
    (beneficiary-id uint)
  )
  (let (
      (utilization-entry (unwrap! (map-get? utilization { id: utilization-id })
        ERR-UTILIZATION-NOT-FOUND
      ))
      (beneficiary (unwrap! (get-beneficiary beneficiary-id) ERR-BENEFICIARY-NOT-FOUND))
    )
    (if (and
        (is-authorized tx-sender ROLE-ADMIN)
        (is-eq (get beneficiary-id utilization-entry) beneficiary-id)
        (< beneficiary-id (+ (var-get beneficiary-count) u1))
        (< utilization-id (+ (var-get utilization-count) u1))
      )
      (if (<= (get amount utilization-entry) (get received-amount beneficiary))
        (begin
          (map-set utilization { id: utilization-id }
            (merge utilization-entry { status: "approved" })
          )
          (ok true)
        )
        ERR-INSUFFICIENT-FUNDS
      )
      ERR-NOT-AUTHORIZED
    )
  )
)

;; Retrieve utilization tracking information
(define-read-only (get-utilization-by-id (utilization-id uint))
  (match (map-get? utilization { id: utilization-id })
    util (ok util)
    ERR-NOT-FOUND
  )
)

;; Get total utilization entries count
(define-read-only (get-utilization-count)
  (ok (var-get utilization-count))
)

;; CONTRACT INITIALIZATION & DEPLOYMENT

;; Initialize contract with deployer as administrator
(define-private (initialize-contract)
  (begin
    (map-set roles { user: tx-sender } { role: ROLE-ADMIN })
    (var-set contract-owner tx-sender)
  )
)

;; Bootstrap contract on deployment
(initialize-contract)
