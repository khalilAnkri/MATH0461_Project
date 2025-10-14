# 🏠 Solar Microgrid Optimal Sizing and Operation

## 🎯 Project Goal
[cite_start]The primary objective of this project is to determine the **optimal sizing** of a solar microgrid's components—specifically the **PV panels** ($C^{PV}$) and the **battery** ($E^{B}$)—to **minimize the total system cost** over its lifetime while satisfying the electrical load demand at all times[cite: 4].

[cite_start]The total cost is the sum of **overnight investment costs** and **operating costs** over the system's lifetime[cite: 5]. [cite_start]The project involves formulating this trade-off as a Linear Optimization Model and conducting subsequent analysis[cite: 6].

## ⚙️ System Configuration
[cite_start]The microgrid system considered is composed of four main elements[cite: 2, 3]:
1.  [cite_start]**Solar panels (PV)**: Convert solar energy into electricity ($P_t^{PV}$)[cite: 3, 17].
2.  [cite_start]**Battery**: Stores electrical energy up to a capacity $E^B$[cite: 3, 25].
3.  [cite_start]**Load**: Represents the electrical consumption ($P_t^C$) that must be supplied[cite: 9, 16].
4.  [cite_start]**Network (Grid)**: Connection to the distribution network for buying electricity ($P_t^{G+}$) or selling electricity ($P_t^{G-}$)[cite: 3, 10, 22].

## 💻 Prerequisites and Setup

This project requires the following software environment and packages:

* [cite_start]**Julia** (Version 1.x or higher) [cite: 68]
* **JuMP.jl**: Julia's mathematical programming package.
* **Gurobi.jl**: Interface to the Gurobi solver.
* [cite_start]**Plots.jl** / **PGFPlotsX.jl**: For generating high-quality plots[cite: 67].
* **DataFrames.jl**: For easy handling and manipulation of time series data.

### 📝 Installation

```julia
using Pkg
# Add required packages
Pkg.add(["JuMP", "Gurobi", "Plots", "DataFrames"])
# Ensure Gurobi is correctly configured on your system (requires a license).