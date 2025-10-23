# Notes Tracker

This file tracks all notes created in Notes-extra for quick lookup and organization.

## Structure

```
Notes-extra/
├── VRF-Concepts/
│   ├── cryptographic-verification.md
│   ├── dapplink-bls-implementation.md
│   ├── dapplink-coordination-model.md
│   └── my-understanding-corrected.md
└── _notes-tracker.md (this file)
```

## Notes Index

### VRF-Concepts
- **cryptographic-verification.md**: Explains how VRF uses cryptography (ECDSA, BLS) to prove randomness is honest and unbiased
- **dapplink-bls-implementation.md**: Deep dive into DappLink VRF's BLS implementation using BN254 curve, pairing verification, aggregate signatures, and decentralization analysis
- **dapplink-coordination-model.md**: Complete explanation of off-chain coordination between multiple oracle nodes - how they coordinate (not compete) using WebSocket communication, aggregate signatures off-chain, and submit via a single manager node
- **my-understanding-corrected.md**: **[PERSONALIZED STUDY GUIDE]** My own summary of VRF concepts with corrections highlighting what I understood correctly (✅), critical errors I made (❌), and areas I need to clarify (🔍). Structured based on my learning progression.

## Topics Covered
- VRF (Verifiable Random Function) fundamentals
- Cryptographic verification methods
- ECDSA vs BLS signatures
- On-chain verification process
- BLS signature aggregation
- BN254 elliptic curve pairing
- Ethereum precompile usage (ecAdd, ecMul, ecPairing)
- Production VRF implementation patterns
- Oracle decentralization models and trust assumptions
- Key aggregation for multi-operator verification
- Off-chain coordination protocols (WebSocket-based)
- Threshold signature schemes (M-of-N security)
- Competitive vs coordinated oracle models
- Manager-worker architecture for oracle networks
