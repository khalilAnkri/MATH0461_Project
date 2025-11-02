# data.jl

# 24-hour daily profile from the statement
daily_consumption = [120, 140, 160, 200, 280, 360, 440, 520, 480, 400, 360, 340,
                     340, 360, 400, 440, 480, 560, 640, 720, 680, 560, 360, 120]

daily_irradiance = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.257, 0.494, 0.678,
                     0.789, 0.831, 0.797, 0.670, 0.484, 0.258, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

# wind power time series [-]
daily_wind_1 = [0.55, 0.63, 0.67, 0.51, 0.4, 0.38, 0.48, 0.48, 0.57, 0.52, 0.64, 0.74, 0.91, 0.9, 0.86, 0.83, 0.45, 0.2, 0.14, 0.15, 0.2, 0.33, 0.34, 0.49]
daily_wind_2 = [0.52, 0.55, 0.65, 0.41, 0.53, 0.48, 0.36, 0.67, 0.54, 0.46, 0.53, 0.63, 0.36, 0.5, 0.47, 0.38, 0.59, 0.54, 0.57, 0.45, 0.44, 0.68, 0.65, 0.43]
daily_wind_3 = [0.15, 0.14, 0.17, 0.25, 0.33, 0.33, 0.49, 0.59, 0.51, 0.4, 0.41, 0.39, 0.34, 0.35, 0.43, 0.4, 0.48, 0.55, 0.67, 0.77, 0.66, 0.61, 0.33, 0.15]

# Number of days in the year
days = 1*365

# Repeat daily profile for 1 year  , to try it for 5 years just change days = 365 * 5
consumption = repeat(daily_consumption, days)
irradiance = repeat(daily_irradiance, days)
wind_1 = repeat(daily_wind_1, days)
wind_2 = repeat(daily_wind_2, days)
wind_3 = repeat(daily_wind_3, days)
