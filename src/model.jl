using JuMP, Gurobi
include("data.jl")  # provides: consumption, irradiance

# -----------------------------
# Time setup
# -----------------------------
T = length(consumption)
time = 1:T
deltat = 1.0  # hours
years = T*deltat/(24*365)  

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

AP = 20
# -----------------------------
# Model definition
# -----------------------------

model = Model(Gurobi.Optimizer)
set_optimizer_attribute(model, "Method", 1)  # 1 for the Simplex algo and 3 for barrier method

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
# Objective function
# -----------------------------
  
@objective(model, Min,
    costPV*(years/AP)*capacityPanel +
    costBattery*(years/AP)*capacityBattery +
    sum((costGPlus*PGPlus[t]*deltat- costGMinus*PGMinus[t]*deltat) for t in time)
)
