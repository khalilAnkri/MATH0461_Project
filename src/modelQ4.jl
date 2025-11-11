using JuMP, Gurobi
include("data.jl")  # provides: consumption, irradiance

# -----------------------------
# Time setup
# -----------------------------
T = length(consumption)
time = 1:T
deltat = 1.0  # hours
years = T*deltat/(24*365)  
AP = 20 # years
alpha = years/AP

# -----------------------------
# System parameters
# -----------------------------
efficiencyPanel = 0.86
efficiencyBattery = 0.95

# Cost parameters
costPV = 800       # €/kW_p
costBattery = 500  # €/kWh_p
costGPlus = 0.1    # €/kWh
costGMinus = 0.02  # €/kWh

# -----------------------------
# Model definition
# -----------------------------

model = Model(Gurobi.Optimizer)
set_optimizer_attribute(model, "Method", 3)  # 1 for the Simplex algo and 3 for barrier method

# -----------------------------
# Decision variables
# -----------------------------
@variable(model, capacityPanel >= 0)               # PV capacity [Wp]
@variable(model, capacityBattery >= 0)             # Battery capacity [Wh]
@variable(model, PGPlus[t in time] >= 0)           # Power bought from grid [W]
@variable(model, PGMinus[t in time] >= 0)          # Power sold to grid [W]
@variable(model, PBPlus[t in time] >= 0)           # Battery charging [W]
@variable(model, PBMinus[t in time] >= 0)          # Battery discharging [W]
@variable(model, PPV[t in time] >= 0)              # PV generation [W]

@variable(model, sumPBPlus[t in time] >= 0)
@variable(model, sumPBMinus[t in time] >= 0)
# -----------------------------
# Constraints
# -----------------------------

# Power balance
@constraint(model, [t in time],
    consumption[t] + PBPlus[t] + PGMinus[t] == PPV[t] + PGPlus[t] + PBMinus[t]
)

# PV generation limit
@constraint(model, [t in time],
    PPV[t] <= efficiencyPanel * irradiance[t] * capacityPanel
)

# Cumulative PBMinus and PBPlus in order to avoid to recompute all the sum at each setup

@constraint(model, sumPBPlus[1] == PBPlus[1])
@constraint(model, sumPBMinus[1] == PBMinus[1])
@constraint(model, [t in 2:T], sumPBPlus[t] == sumPBPlus[t-1] + PBPlus[t])
@constraint(model, [t in 2:T], sumPBMinus[t] == sumPBMinus[t-1] + PBMinus[t])

# Battery dynamics
@constraint(model, [t in time], 0.5*capacityBattery +  efficiencyBattery*deltat*sumPBPlus[t]
                                - (deltat/efficiencyBattery)*sumPBMinus[t] <= capacityBattery)

@constraint(model, [t in time], 0.5*capacityBattery +  efficiencyBattery*deltat*sumPBPlus[t]
                                - (deltat/efficiencyBattery)*sumPBMinus[t] >= 0)

@constraint(model, efficiencyBattery*deltat*(sumPBPlus[T]-PBPlus[1])
                    - (deltat/efficiencyBattery)*(sumPBMinus[T]-PBMinus[1]) == 0)

# -----------------------------
# Objective function
# -----------------------------

@objective(model, Min,
    costPV*alpha*capacityPanel +
    costBattery*alpha*capacityBattery +
    years * sum((costGPlus*PGPlus[t]*deltat - costGMinus*PGMinus[t]*deltat) for t in time)
)
