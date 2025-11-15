using JuMP, Gurobi
include("data.jl")  # provides: consumption, irradiance

# -----------------------------
# Time setup
# -----------------------------
T = length(consumption)
time = 1:T
deltat = 1.0  # hours
scenario = 1:3
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
costW = 1500       # €/kwh_p

# -----------------------------
# Model definition
# -----------------------------

model = Model(Gurobi.Optimizer)
set_optimizer_attribute(model, "Method", 3)  # 1 for the Simplex algo and 3 for barrier method

# -----------------------------
# Decision variables
# -----------------------------
@variable(model, capacityPanel >= 0)                              # PV capacity [Wp]   
@variable(model, capacityBattery >= 0)                            # Battery capacity [Wh]
@variable(model, capacityWind >= 0)                               # Wind cpacity [w]
@variable(model, PGPlus[t in time,s in scenario] >= 0)            # Power bought from grid [W]
@variable(model, PGMinus[t in time, s in scenario] >= 0)          # Power sold to grid [W]
@variable(model, PBPlus[t in time, s in scenario] >= 0)           # Battery charging [W]
@variable(model, PBMinus[t in time, s in scenario] >= 0)          # Battery discharging [W]
@variable(model, PPV[t in time, s in scenario] >= 0)              # PV generation [W]
@variable(model, E[t in time, s in scenario] >= 0)                # Battery energy [Wh]
@variable(model, S)                                          # Variable related to the worst case scenario
@variable(model, PWind[t in time, s in scenario] >= 0)            # Power produces by the wind [W]
@variable(model, cost[s in scenario])                             # Cost of the s scenario [€]

# -----------------------------
# Constraints
# -----------------------------

# Power balance
@constraint(model, [t in time, s in scenario],
    consumption[t] + PBPlus[t,s] + PGMinus[t,s] == PPV[t,s] + PGPlus[t,s] + PBMinus[t,s] + PWind[t,s]
)

# PV generation limit
@constraint(model, [t in time, s in scenario],
    PPV[t,s] <= efficiencyPanel * irradiance[t] * capacityPanel
)

# Battery dynamics
@constraint(model, [s in scenario], E[1,s] == 0.5*capacityBattery + efficiencyBattery*deltat*PBPlus[1,s] - (deltat/efficiencyBattery)*PBMinus[1,s])
@constraint(model, [t in 2:T, s in scenario],
    E[t,s] == E[t-1,s] + efficiencyBattery*deltat*PBPlus[t,s] - (deltat/efficiencyBattery)*PBMinus[t,s]
)
@constraint(model, [t in time, s in scenario], E[t,s] <= capacityBattery)
@constraint(model, [s in scenario], E[T,s] == E[1,s])

# Wind power
@constraint(model, [t in time], PWind[t,1] == wind_1[t] * capacityWind)
@constraint(model, [t in time], PWind[t,2] == wind_2[t] * capacityWind)
@constraint(model, [t in time], PWind[t,3] == wind_3[t] * capacityWind)

# Cost constraint
@constraint(model, [s in scenario], S >= cost[s])

@constraint(model, [s in scenario], cost[s] == sum((costGPlus*PGPlus[t,s]*deltat - costGMinus*PGMinus[t,s]*deltat)
                                                  for t in time))

# Constraint against unboundness
@constraint(model, capacityWind <= 1000)
@constraint(model, capacityPanel <= 4000)


# -----------------------------
# Objective function
# -----------------------------

@objective(model, Min,
    costPV*alpha*capacityPanel + costBattery*alpha*capacityBattery+ costW*alpha*capacityWind + S + (1/3)*sum(cost[s] for s in scenario))
