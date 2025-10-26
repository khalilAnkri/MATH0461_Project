using JuMP, Gurobi
include("data.jl")  # provides: consumption, irradiance

# -----------------------------
# Time setup
# -----------------------------
T = length(consumption)
time = 1:T
deltat = 1.0  # hours
scenario = 1:3

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
costW = 1500       # €/kwh

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
@variable(model, S >= 0)                                          # Variable related to the worst case scenario
@variable(model, PWind[t in time, s in scenario] >= 0)            # Power produces by the wind [W]
@variable(model, cost[s in scenario] >= 0)                        # Cost of the s scenario [€]

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

@constraint(model, [s in scenario], cost[s] == sum((costGPlus*PGPlus[t,s]*deltat/1000 - costGPlus*PGMinus[t,s]*deltat/1000)
                                                  for t in time))


# -----------------------------
# Force PV and battery use
# -----------------------------
# Ensure at least 30% of load comes from PV
@constraint(model, [s in scenario], sum(PPV[t,s] for t in time) >= 0.3 * sum(consumption))

# Optionally, force some battery usage
@constraint(model, [s in scenario], sum(PBPlus[t,s] for t in time) >= 0.05 * sum(consumption))  # store at least 5% of daily consumption

# -----------------------------
# Objective function
# -----------------------------
# No amortization needed for 24h, but PV/battery fractions scaled to kW/kWh
@objective(model, Min,
    costPV*(capacityPanel/1000) + costBattery*(capacityBattery/1000) + costW * (capacityWind/1000) + sum(cost[s] for s in scenario) + S )

# -----------------------------
# Comment section
# -----------------------------
# I have added the fractions "/1000" in the objective function to ensure that the units are consistent,
#  converting W to kW and Wh to kWh where necessary for cost calculations.