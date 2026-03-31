# Verifiable Lottery (VRF-based)

A professional-grade implementation of a trustless lottery system. This repository solves the "on-chain randomness" problem by utilizing Chainlink VRF to fetch a cryptographically secure random number, ensuring that neither the contract owner nor any external actor can influence the winning outcome.

## Core Features
* **Provable Fairness:** Uses VRF v2.5 for off-chain randomness with on-chain verification.
* **Automated Payouts:** Winners are identified and paid out in a single transaction sequence.
* **Security:** Implements `ReentrancyGuard` and strict state machine logic (Open -> Calculating -> Closed).
* **Flat Structure:** All VRF consumer logic and lottery management in one directory.

## Workflow
1. **Enter:** Users buy tickets with a fixed ETH amount.
2. **Request:** Owner calls `endLottery()`, triggering a request to Chainlink VRF.
3. **Fulfill:** Chainlink nodes return a random number to `fulfillRandomWords`.
4. **Distribute:** The contract uses the random number to pick a winner and sends the pot.

## Setup
1. `npm install`
2. Update `SubscriptionId` and `KeyHash` in `Lottery.sol` for your network.
