# data.jl

# 24-hour daily profile from the statement
daily_consumption = [120, 140, 160, 200, 280, 360, 440, 520, 480, 400, 360, 340,
                     340, 360, 400, 440, 480, 560, 640, 720, 680, 560, 360, 120]

daily_irradiance = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.257, 0.494, 0.678,
                     0.789, 0.831, 0.797, 0.670, 0.484, 0.258, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

# Number of days in the year
days = 365

# Repeat daily profile for 1 year  , to try it for 5 years just change days = 365 * 5
consumption = repeat(daily_consumption, days)
irradiance = repeat(daily_irradiance, days)
