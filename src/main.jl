include("data.jl")    # Provides consumption_1yr, irradiance_1yr
include("model.jl")   # Uses consumption_1yr, irradiance_1yr

optimize!(model)

println("Optimal PV capacity (Wp): ", value(capacityPanel))
println("Optimal battery capacity (Wh): ", value(capacityBattery))
