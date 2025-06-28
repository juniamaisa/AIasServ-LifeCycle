# CNSM 2025: A Protocol-Based Framework for Distributed AI Lifecycle Management in 6G via NWDAF
An work about *AIasServ-LifeCycle*


# NWDAF AI-as-a-Service — Formal Specification (TLA+)

This repository contains the **complete, executable TLA+ model** that accompanies the short paper

> **“A Protocol-Based Framework for Distributed AI Lifecycle Management in 6G via NWDAF”**  
> (submitted to IEEE CNSM 2025).

The model formalises the two service-based interfaces proposed in the paper—**MTCP** (Model Training & Creation Protocol) and **MEP** (Model Execution Protocol)—and demonstrates, via the **TLC** model checker, that they satisfy the key safety and liveness requirements claimed in the manuscript.

---

## Repository layout

```text
.
├── MTCP_MEP.tla   # TLA+ specification: variables, actions, properties
├── MTCP_MEP.cfg   # TLC configuration: constants, invariants, liveness goals
└── README.md      # This file
└── run_output     # Execution evidence
└── run.tlc.sh     # Execution script. On terminal type: 0bash run_tlc.sh


```
---

# Quick start

1 · Prerequisites

- Java 8 or newer
- tla2tools.jar ≥ 2.19 → [download](https://github.com/tlaplus/tlaplus/releases)
(alternatively install the TLA+ Toolbox, which bundles the JAR)

2 · Run the model checker

Place MTCP_MEP.tla, MTCP_MEP.cfg and tla2tools.jar in the same directory

MacOS Execute:
```text
java -XX:+UseParallelGC -cp tla2tools.jar tlc2.TLC \
     -workers 4 \
     -config MTCP_MEP.cfg MTCP_MEP.tla
```
Windows execute:
```text
java -cp tla2tools.jar tlc2.TLC -config MTCP_MEP.cfg MTCP_MEP.tla
```


Expected summary is presented in the image.

# Verified properties

| Property                | Type      | Meaning in protocol terms                                  |
| ----------------------- | --------- | ---------------------------------------------------------- |
| **NoStaleLoad**         | Invariant | An NF never loads a model that has already been *retired*. |
| **DeadlockFreedom**     | Invariant | The system always has at least one enabled transition.     |
| **EventuallyPublished** | Liveness  | Every model marked *valid* is eventually *published*.      |
| **EventuallyFeedback**  | Liveness  | Every inference triggers feedback eventually.              |


# Scaling the constants

To explore larger scenarios, edit MTCP_MEP.cfg:
```text
CONSTANTS
  NFs        = {nf1, nf2, nf3, nf4, nf5}
  Versions   = {v1, v2, v3}
  startModel = v2
```

# Relation to the paper

Section V-A (Formal Verification) of the manuscript cites this artefact.
The TLC statistics (states, depth) match those reported in Table IV of the camera-ready version, confirming reproducibility.



# Contributions via Issues or Pull Requests are welcome!


Feel free to fork and extend the specification to cover message loss,
timeouts, or authentication scopes as described in the paper.


*Replace `juniamaisa` with your GitHub handle before committing.*


If you use this artefact, please cite our CNSM 2025 short paper:
@inproceedings{...}
