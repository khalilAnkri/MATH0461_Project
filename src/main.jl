using MathOptInterface
const MOI = MathOptInterface

include("data.jl")      # Provides consumption_1yr, irradiance_1yr
# include("model.jl")     # Uses consumption_1yr, irradiance_1yr
include("analysis.jl")
#include("modelQ4.jl")
#include("modelQ7.jl")
# include("modelQ8.jl")

@time optimize!(model)

println("Optimal PV capacity (Wp): ", value(capacityPanel))
println("Optimal battery capacity (Wh): ", value(capacityBattery))
# println("Optimal wind capacity (Wp) :", value(capacityWind))
# println("Optimal value of S :", value(S))

#### for Question 8 only modelQ8#########################
# @time optimize!(model)
# status = termination_status(model)

# if status == MOI.OPTIMAL
#     println("Optimal PV capacity (Wp): ", value(capacityPanel))
#     println("Optimal battery capacity (Wh): ", value(capacityBattery))
#     println("Optimal wind capacity (Wp): ", value(capacityWind))
#     println("Worst-case scenario cost: ", value(S))
#     println("Scenario costs: ", value(cost1), ", ", value(cost2), ", ", value(cost3))
# elseif status == MOI.INFEASIBLE_OR_UNBOUNDED 
#     println("Model is unbounded! Wind capacity (and positive selling price) allows infinite profit.")
# else
#     println("Solver terminated with status: ", status)
# end
###########################################################

# plot_week(Array(value(PPV)),Array(value(PBPlus)),Array(value(PBMinus)),Array(value(PGPlus)),
#             Array(value(PGMinus)),Array(value(E)),consumption)
