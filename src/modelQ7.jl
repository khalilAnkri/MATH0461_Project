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

# C0_2 Emissions parameters
thetaPV = 1000 #(kg CO_2 / kW_p) 
thetaB = 150 #(kg CO_2 / kWh_p) 
thetaG = 0.1 #(kg CO_2 / kWh)

AP = 20

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
# Objective function
# -----------------------------

@objective(model, Min,
    thetaPV*(years/AP)*capacityPanel +
    thetaB*(years/AP)*capacityBattery +
    thetaG*sum(PGPlus[t] * deltat for t in time)
)
