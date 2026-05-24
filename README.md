# Neoclassical Growth and Structural Change — Calibration and Fiscal Policy

> Master's degree project — *N.F.*
> All rights reserved. See `LICENSE` for details.

---

## Overview

This project extends a standard neoclassical growth framework to study **structural change** — the long-run shift in economic activity across Agriculture, Manufacturing, and Services. Unlike a partial equilibrium approach, the model features **endogenous capital accumulation**: investment decisions and sectoral consumption shares are determined simultaneously within a general equilibrium setting.

The project covers three main topics:

1. **Balanced Growth Path (BGP) simulation** of a neoclassical growth model
2. **Fiscal policy analysis** — how sector-specific taxes and subsidies alter expenditure shares (nominal and real)
3. **Structural calibration** — fitting model parameters to replicate observed sectoral dynamics using numerical optimisation

---

## Project Structure

```
.
├── doc_codes1/
│   ├── main.m                         # Exercise 1 – BGP simulation
│   └── growthmodel.m                  # Helper function: simulates the growth model
│
├── doc_codes2/
│   ├── 2b/
│   │   ├── main_ex2bfunzionante.m     # Exercise 2b – Fiscal policy simulation
│   │   └── solve_consumption_foc_taxes.m  # FOC solver with tax wedges
│   └── 2c/
│       ├── main2C_pb2.m               # Exercise 2c – Income growth calibration
│       ├── calculate_real_shares.m    # Computes real expenditure shares over time
│       ├── calibrate_gamma_w.m        # Objective function for fzero calibration
│       └── solve_consumption_foc.p    # Compiled helper: FOC system solver
│
└── doc_codes3/
    ├── es3aa.m                        # Exercise 3a – General equilibrium structural change
    ├── main_3b.m                      # Exercise 3b – Calibration via fminsearch
    ├── simulate_model_3b.m            # Simulation function called during calibration
    ├── objective_sse_3b.m             # SSE objective function for fminsearch
    └── solve_consumption_foc.p        # Compiled helper: FOC system solver
```

---

## Models and Methodology

### Exercise 1 — Balanced Growth Path Simulation

Simulates a neoclassical growth model with **labour-augmenting technology** (`A_t`) growing at a constant rate `γ_A`. The initial capital stock is set analytically to place the economy exactly on the BGP from period 1, so all quantities grow at the same rate and factor prices are constant.

**Production function:**

$$Y_t = K_t^\theta \cdot A_t^{1-\theta}$$

**BGP capital stock** (derived from the Euler equation and market clearing):

$$K_0 = \left( \frac{\theta \beta}{1 + \gamma_A - \beta(1 - \delta)} \right)^{\frac{1}{1-\theta}} A_0$$

**Output:** log-scale plots of `Y`, `K`, `C` over 200 periods; dual-axis plot of the interest rate `r` (constant on BGP) and log wage `w` (growing at `γ_A`).

---

### Exercise 2b — Fiscal Policy and Sectoral Expenditure Shares

Introduces **sector-specific tax wedges** that evolve over time: a growing tax on Agriculture and a growing subsidy on Services. The effective price faced by the consumer becomes:

$$\tilde{p}_i = p_i \cdot \tau_i$$

A custom FOC solver (`solve_consumption_foc_taxes.m`) incorporates these wedges directly into the optimality conditions. The script simulates two economies in parallel over 200 periods:

- **Benchmark:** no fiscal policy (`τ_i = 1` for all sectors)
- **Policy:** taxes and subsidies grow according to specified laws of motion

**Output:** side-by-side plots of nominal and real expenditure shares for both scenarios, making it possible to distinguish price effects from quantity effects.

---

### Exercise 2c — Calibration via Income Growth Rate

Asks: *what income growth rate would a benchmark economy (with no fiscal intervention) need, in order to reach the same service sector share achieved by the policy economy at period 200?*

This is solved as a **root-finding problem**: `fzero` is used to find the value of `γ_w` such that the simulated service share at `t = 200` matches the policy target. The calibration uses real expenditure shares computed via `calculate_real_shares.m`.

---

### Exercise 3a — General Equilibrium Structural Change

The most complete model in the project. Combines:

- **Neoclassical capital accumulation** (endogenous investment)
- **Four sector-specific productivity processes** (`A_x`, `A_a`, `A_m`, `A_s`) growing at different rates
- **Stone-Geary CES preferences** over the three consumption sectors

Relative prices are endogenous and derived from productivity differentials:

$$p_i(t) = \left( \frac{A_x(t)}{A_i(t)} \right)^{1-\theta}$$

At each period, the FOC system is solved numerically via `fsolve` to find optimal consumption across sectors given income `PC(t) = Y(t) - X(t)`.

**Validation:** the script also derives the analytical closed-form solution for sectoral consumption and computes the maximum and mean absolute errors between the numerical and analytical paths — confirming the numerical solver's accuracy.

**Output:** nominal and real expenditure shares (including the investment share) over 150 periods.

---

### Exercise 3b — Structural Calibration via fminsearch

Calibrates three model parameters simultaneously by minimising the **sum of squared errors (SSE)** between simulated and target service sector shares at three specific periods:

| Period | Target share (services) |
|--------|------------------------|
| t = 1 | 0.2507 |
| t = 67 | 0.3623 |
| t = 121 | 0.4551 |

**Parameters calibrated:**

| Parameter | Description |
|-----------|-------------|
| `γ_As` | Productivity growth rate of the Services sector |
| `β` | Household discount factor |
| `ε` | Elasticity of substitution across sectors |

`fminsearch` calls `objective_sse_3b.m` at each iteration, which in turn calls `simulate_model_3b.m` to produce the full 150-period path and extract the relevant moments.

**Output:** plot of the calibrated service sector share path against the three target observations.

---

## Requirements

- MATLAB R2020a or later
- Optimization Toolbox (for `fsolve`, `fzero`, `fminsearch`)
- The `.p` file (`solve_consumption_foc.p`) must be in the same folder as the scripts that use it — it is a pre-compiled helper and cannot be inspected directly

---

## Usage

Each folder is self-contained. Run `main.m` (or `es3aa.m` / `main_3b.m`) directly in MATLAB. All parameters are defined at the top of each script and can be adjusted for sensitivity analysis.

---

## License

This project is protected by copyright. See the [`LICENSE`](LICENSE) file for full terms.
**Reusing, copying, modifying, or redistributing** the code without explicit written permission from the author is not permitted.
