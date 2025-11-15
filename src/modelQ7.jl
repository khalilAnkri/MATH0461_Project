using JuMP, HiGHS
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

# C0_2 Emissions parameters
thetaPV = 1000 #kg CO_2/kW_p 
thetaB = 150 #kg CO_2/kWh_p 
thetaG = 0.1 #kg CO_2/kWh

# -----------------------------
# Model definition
# -----------------------------

model = Model(HiGHS.Optimizer)

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
@variable(model, Buffer >= 0)                      # Buffer variable [Wh]

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

# Buffer constraint
@constraint(model, Buffer == sum(PGPlus[t] * deltat for t in time))

# -----------------------------
# Objective function
# -----------------------------

@objective(model, Min,
    thetaPV*capacityPanel +
    thetaB*capacityBattery +
    thetaG*Buffer
)

optimize!(model)

println("Optimal PV capacity [Wp]: ", value(capacityPanel))
println("Optimal battery capacity [Wh]: ", value(capacityBattery))
println("Optimal Buffer value [Wh]: ", value(Buffer))

report = lp_sensitivity_report(model)
println("Sensitivity report for θG (via Buffer variable): ", report[Buffer])

thetaG_range = report[Buffer]  # returns a tuple (min_change, max_change)

thetaG_min = thetaG + thetaG_range[1]
thetaG_max = thetaG + thetaG_range[2]

println("Allowable θG range: [", thetaG_min, ", ", thetaG_max, "] kgCO2/kWh")