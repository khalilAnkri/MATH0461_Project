include("data.jl")      # Provides consumption_1yr, irradiance_1yr
include("model.jl")     # Uses consumption_1yr, irradiance_1yr
include("analysis.jl")
#include("modelQ4.jl")
#include("modelQ7.jl")
#include("modelQ8.jl")

@time optimize!(model)

println("Optimal PV capacity (Wp): ", value(capacityPanel))
println("Optimal battery capacity (Wh): ", value(capacityBattery))
#println("Optimal wind capacity (Wp) :", value(capacityWind))
#println("Optimal value of S :", value(S))

plot_week(Array(value(PPV)),Array(value(PBPlus)),Array(value(PBMinus)),Array(value(PGPlus)),
            Array(value(PGMinus)),Array(value(E)),consumption)
