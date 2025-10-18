using Plots

function plot_week(PPV, PBPlus, PBMinus, PGPlus, PGMinus, E, consumption)
    # Extract first week (7 days × 24 hours = 168 points)
    week_idx = 1:168
    # Extract first day (24 hours = 24 points)
    day_idx = 1:24

    plt1 = plot(week_idx, PPV[week_idx], label="PV production [W]", lw=2)
    plot!(week_idx, PBPlus[week_idx], label="Battery charge [W]", lw=2)
    plot!(week_idx, PBMinus[week_idx], label="Battery discharge [W]", lw=2)
    plot!(week_idx, PGPlus[week_idx], label="Grid bought [W]", lw=2)
    plot!(week_idx, PGMinus[week_idx], label="Grid sold [W]", lw=2)
    plot!(week_idx, consumption[week_idx], label="Load [W]", lw=2, ls=:dash)
    
    xlabel!("Hour")
    ylabel!("Power [W]")
    title!("Microgrid operation - Typical week")
    
    savefig(plt1, "microgrid_week.pdf")

    plt2 = plot(day_idx, PPV[day_idx], label="PV production [W]", lw=2)
    plot!(day_idx, PBPlus[day_idx], label="Battery charge [W]", lw=2)
    plot!(day_idx, PBMinus[day_idx], label="Battery discharge [W]", lw=2)
    plot!(day_idx, PGPlus[day_idx], label="Grid bought [W]", lw=2)
    plot!(day_idx, PGMinus[day_idx], label="Grid sold [W]", lw=2)
    plot!(day_idx, consumption[day_idx], label="Load [W]", lw=2, ls=:dash)
    
    xlabel!("Hour")
    ylabel!("Power [W]")
    title!("Microgrid operation - Typical day")
    savefig(plt2, "microgrid_day.pdf")

    # Plot SOC
    plt3 = plot(week_idx, E[week_idx], label="Battery SOC [Wh]", lw=2)
    xlabel!("Hour")
    ylabel!("Energy [Wh]")
    title!("Battery State of Charge - Typical week")
    savefig(plt3, "SOC_week.pdf")
end

