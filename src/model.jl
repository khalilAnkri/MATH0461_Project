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
@variable(model, E[t in time] >= 0)                # Battery energy [Wh]

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

# Battery dynamics
@constraint(model, E[1] == 0.5*capacityBattery + efficiencyBattery*deltat*PBPlus[1] - (deltat/efficiencyBattery)*PBMinus[1])
@constraint(model, [t in 2:T],
    E[t] == E[t-1] + efficiencyBattery*deltat*PBPlus[t] - (deltat/efficiencyBattery)*PBMinus[t]
)
@constraint(model, [t in time], E[t] <= capacityBattery)
@constraint(model, E[T] == E[1])

# -----------------------------
# Force PV and battery use
# -----------------------------
# Ensure at least 30% of load comes from PV
@constraint(model, sum(PPV[t] for t in time) >= 0.3 * sum(consumption))

# Optionally, force some battery usage
@constraint(model, sum(PBPlus[t] for t in time) >= 0.05 * sum(consumption))  # store at least 5% of daily consumption

# -----------------------------
# Objective function
# -----------------------------
# No amortization needed for 24h, but PV/battery fractions scaled to kW/kWh
@objective(model, Min,
    costPV*(capacityPanel/1000) +
    costBattery*(capacityBattery/1000) +
    sum((costGPlus*PGPlus[t]*deltat/1000 - costGMinus*PGMinus[t]*deltat/1000) for t in time)
)

# -----------------------------
# Comment section
# -----------------------------
# I have added the fractions "/1000" in the objective function to ensure that the units are consistent,
#  converting W to kW and Wh to kWh where necessary for cost calculations.
