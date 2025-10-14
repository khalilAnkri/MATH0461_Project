# 📄 Project Report Structure: Optimal Sizing of a Solar Microgrid

This structure is designed to guide the creation of your final PDF report, ensuring all project questions (Q1-Q8) are addressed concisely within the 6-page limit.

## 1. Introduction (Approx. 0.5 page)

### 1.1. Context and System Overview
* [cite_start]Introduce the solar microgrid system: PV panels, battery, load, and grid connection[cite: 3, 11].
* [cite_start]State the core challenge: balancing high initial investment costs versus lower variable operating costs[cite: 6].

### 1.2. Problem Statement
* [cite_start]Clearly state the objective: **Minimize the total cost** (investment + operation) by optimally sizing the **PV panels ($C^{PV}$)** and the **battery ($E^{B}$)**[cite: 4, 32].
* [cite_start]State the primary constraint: **Satisfying the load demand** at all times[cite: 4, 32].
* [cite_start]Identify the methodology: Formulation and solution as a **Linear Optimization Model (LOM)**[cite: 40].

---

## 2. Core Optimization Model and Sizing (Q1-Q4) (Approx. 2.0 pages)

### 2.1. Mathematical Formulation (Q1)
* **Decision Variables:** List all sizing and operational variables.
* **Objective Function (Total Cost):**
    $$ \min Z = \left( \pi^{PV} C^{PV} + \pi^{B} E^{B} \right) + \sum_{t=1}^{T} \left( \pi^{G+} P_{t}^{G+} - \pi^{G-} P_{t}^{G-} \right) \Delta t $$
* **Key Constraints:**
    * [cite_start]**Power Balance:** $P_{t}^{PV, \text{util}} + P_{t}^{G+} + P_{t}^{D, B} = P_{t}^{C} + P_{t}^{G-} + P_{t}^{C, B}$[cite: 16].
    * [cite_start]**PV Production Limit:** $P_{t}^{PV, \text{util}} \le \eta^{PV} i_{t} C^{PV}$[cite: 19].
    * [cite_start]**SOC Dynamics:** $SOC_{t+1} = SOC_{t} + \left( \eta^{B} P_{t}^{C, B} - \frac{1}{\eta^{B}} P_{t}^{D, B} \right) \Delta t$[cite: 26].
    * [cite_start]**SOC Limits and Cycling:** $0 \le SOC_{t} \le E^{B}$ and $SOC_{T+1} = SOC_{1}$ (as per hint [cite: 41]).

### 2.2. Base Case Results and Discussion (Q2)
* **Optimal Sizing Table:** Report the calculated values for $C^{PV}$, $E^{B}$, and the total cost $Z$ for the **1-year** and **5-year** simulations. Discuss the impact of the time horizon on investment decisions.
* **Typical Week Operation Plots:**
    * **Plot 1: Power Flows:** Show $P_{t}^{PV, \text{util}}$, $P_{t}^{C}$, $P_{t}^{G+}$, $P_{t}^{G-}$, $P_{t}^{C, B}$, and $P_{t}^{D, B}$ for a typical 7-day period.
    * **Plot 2: Battery SOC:** Show $SOC_t$ over the same 7-day period.
    * **Discussion:** Analyze the system's operational strategy (charging/discharging, grid interaction).

### 2.3. Solver Performance Analysis (Q3)
* **Results Table:** Report the time to solve the problem using the **Simplex Algorithm** and the **Barrier Method** for different operation years (e.g., 1, 3, 5 years).
* **Discussion:** Discuss the scaling of each method with the increasing problem size ($T$), noting which is more efficient for this type of large LOM.

### 2.4. Reduced Variable Model (Q4)
* **Reformulation:** Briefly present the modified model where $SOC_{t}$ is substituted by a function of initial $SOC$ and cumulative net charged/discharged power.
* **Performance:** Compare the new solving performance against the original formulation. Discuss why the change in the number of variables affects the solver (e.g., density of constraints).

---

## 3. Sensitivity Analysis (Q5-Q6) (Approx. 1.0 page)

### 3.1. Interpretation of Dual Variables (Q5)
* Provide an economic interpretation of the **dual variables (shadow prices)** associated with the main equality constraints (e.g., Power Balance and SOC Dynamics).

### 3.2. Battery Cost Sensitivity ($\pi^B$) (Q6)
* Determine the interval $\Delta\pi^{B}$ outside of which the **optimal basis changes**.
* Give the resulting optimal solution characteristics (e.g., how $C^{PV}$ and $E^B$ change) when $\Delta\pi^{B}$ is outside this interval.
* **Interpretation:** Explain the economic consequence of the sensitivity findings.

---

## 4. Model Reformulation and Uncertainty (Q7-Q8) (Approx. 1.5 pages)

### 4.1. Sustainability Model (Q7)
* **New Objective:** Reformulate the problem to minimize the total $\text{CO}_2$ emissions (using $\theta^{PV}, \theta^{B}, \theta^{G}$).
* **Sensitivity ($\theta^G$):** Rerun the sensitivity analysis (Q6) on the **grid $\text{CO}_2$ emissions parameter ($\theta^G$)** for this new objective. Discuss the new trade-off.

### 4.2. Wind Turbine and Worst-Case Scenario (Q8)
* **Objective Formulation:** Introduce the new decision variable $C_W$ and the three scenarios $s \in \{1, 2, 3\}$. Formulate the robust objective function:
    $$\min Z_{\text{robust}} = \text{Investment Cost} + \sum_{s=1}^{3} \left(\frac{1}{3} \cdot \text{Operation Cost}_s\right) + \lambda \cdot \max_{s} \left(\text{Operation Cost}_s\right)$$
* **Results and Discussion:** Report the new optimal sizing ($C^{PV}, E^B, C^W$). Discuss how the consideration of uncertainty and the worst-case penalty affects the final investment decisions.

---

## 5. Conclusion (Approx. 0.5 page)

* **Summary of Key Findings:** Briefly summarize the final optimal design strategy and the most significant influences (e.g., time horizon, solver choice, sustainability goal, and uncertainty).
* **Outlook:** Suggest potential extensions for future work (e.g., incorporating non-linear degradation, dynamic electricity pricing).

***