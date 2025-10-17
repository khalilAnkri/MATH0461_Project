using JuMP, Gurobi
include("data.jl")

model = Model(Gurobi.Optimizer)
time = ...
deltat = 1
efficiencyPanel = 0.86
efficiencyBattery = 0.95
costPV = 800
costBattery = 500
costGPlus = 0.1
costGMinus = 0.02

# variables
@variable(model, capacityPanel >= 0)
@variable(model, capacityBattery >= 0)
@variable(model, PGPlus[time] >= 0)
@variable(model, PGMinus[time] >= 0)
@variable(model, PPV[time] >= 0)
@variable(model, PBPlus[time] >=0)
@variable(model, PBMinus[time] >=0)
@variable(model, 0 <= SOC[time] <= 1)

#constraints
@constraints(model, [t in time], PPV[t] <= efficiencyPanel * irradiance[t] * capacityPanel)
@constraint(model, [t in time], consumption[t] + PBMinus[t] + PGMinus[t] = PPV[t] + PGPlus[t] + PBPlus[t])
@constraint(model, SOC[1] == ...) # Need to choose the value for initiale feasible physical value
@constraint(model, [t in time[2:end]] , SOC[t] = SOC[t-1] + (efficiencyBattery * deltat * PBPlus[t])/capacityBattery - (deltat * PBMinus[t]) / (efficiencyBattery * capacityBattery))

#objective
@objective(model, Min, costPV*capacityPanel+costBattery*capacityBattery+sum((costGPlus*PGPlus[t]-costGMinus*PGMinus[t])*deltat) for t in time)
