using JuMP, Gurobi
include("data.jl")  # provides: consumption, irradiance

# -----------------------------
# Time setup
# -----------------------------
T = length(consumption)
time = 1:T
deltat = 1.0  # hours

# -----------------------------
# System parameters
# -----------------------------
efficiencyPanel = 0.86
efficiencyBattery = 0.95

# Cost parameters
costPV = 800       # AC/kWp
costBattery = 500  # AC/kWh
costGPlus = 0.1    # AC/kWh
costGMinus = 0.02  # AC/kWh

# -----------------------------
# Model definition
# -----------------------------

modelQ4 = Model(Gurobi.Optimizer)
set_optimizer_attribute(model, "Method", 3)  # 1 for the Simplex algo and 3 for barrier method

# -----------------------------
# Decision variables
# -----------------------------
@variable(modelQ4, capacityPanel >= 0)               # PV capacity [Wp]
@variable(modelQ4, capacityBattery >= 0)             # Battery capacity [Wh]
@variable(modelQ4, PGPlus[t in time] >= 0)           # Power bought from grid [W]
@variable(modelQ4, PGMinus[t in time] >= 0)          # Power sold to grid [W]
@variable(modelQ4, PBPlus[t in time] >= 0)           # Battery charging [W]
@variable(modelQ4, PBMinus[t in time] >= 0)          # Battery discharging [W]
@variable(modelQ4, PPV[t in time] >= 0)              # PV generation [W]

# -----------------------------
# Constraints
# -----------------------------

# Power balance
@constraint(modelQ4, [t in time],
    consumption[t] + PBPlus[t] + PGMinus[t] == PPV[t] + PGPlus[t] + PBMinus[t]
)

# PV generation limit
@constraint(modelQ4, [t in time],
    PPV[t] <= efficiencyPanel * irradiance[t] * capacityPanel
)

# Battery dynamics
@constraint(modelQ4, [t in time], 0.5*capacityBattery +  efficiencyBattery*deltat*sum(PBPlus[t] for t in t)
                                - (deltat/efficiencyBattery)*sum(PBMinus[t] for t in t) <= 0.5*capacityBattery)

@constraint(modelQ4, [t in time], 0.5*capacityBattery +  efficiencyBattery*deltat*sum(PBPlus[t] for t in t)
                                - (deltat/efficiencyBattery)*sum(PBMinus[t] for t in t) >= 0)

@constraint(modelQ4, efficiencyBattery*deltat*sum(PBPlus[i]  for i in 2:T) 
                    - (deltat/efficiencyBattery)*sum(PBMinus[i] for i in 2:T) == 0)
# -----------------------------
# Force PV and battery use
# -----------------------------
# Ensure at least 30% of load comes from PV
@constraint(modelQ4, sum(PPV[t] for t in time) >= 0.3 * sum(consumption))

# Optionally, force some battery usage
@constraint(modelQ4, sum(PBPlus[t] for t in time) >= 0.05 * sum(consumption))  # store at least 5% of daily consumption

# -----------------------------
# Objective function
# -----------------------------
# No amortization needed for 24h, but PV/battery fractions scaled to kW/kWh
@objective(modelQ4, Min,
    costPV*(capacityPanel/1000) +
    costBattery*(capacityBattery/1000) +
    sum((costGPlus*PGPlus[t]*deltat/1000 - costGMinus*PGMinus[t]*deltat/1000) for t in time)
)

# -----------------------------
# Comment section
# -----------------------------
# I have added the fractions "/1000" in the objective function to ensure that the units are consistent,
#  converting W to kW and Wh to kWh where necessary for cost calculations.