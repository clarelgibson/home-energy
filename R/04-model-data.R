# Summary -----------------------------------------------------------------
# This script prepares a dimensional model from the data needed for the project

source(here::here("R/03-prep-data.R"))

# Dimensions --------------------------------------------------------------

# Start datetime
start <- 
  usage |> 
  select(start) |> 
  distinct() |> 
  pull(start)

dim_start <- 
  make_datetime_dimension(start, "start")

# End datetime
end <- 
  usage |> 
  select(end) |> 
  distinct() |> 
  pull(end)

dim_end <- 
  make_datetime_dimension(end, "end")

# Date
dim_date <- dim_start |> 
  select(
    date = start_date,
    year = start_year,
    month = start_month,
    day = start_day,
    day_of_week = start_day_of_week,
    weekend_flag = start_weekend_flag,
    season = start_season
  ) |> 
  distinct() |> 
  mutate(
    date_key = as.integer(date),
    .before = 1
  )

# Tariff
dim_tariff <- 
  tariffs

# Facts -------------------------------------------------------------------
# Half-hourly usage
fct_half_hourly_usage <- 
  usage |> 
  mutate(
    start_key = as.integer(start),
    end_key = as.integer(end)
  ) |> 
  left_join(
    select(
      dim_start,
      start_key,
      start_time
    )
  ) |> 
  left_join(
    select(
      dim_end,
      end_key,
      end_time
    )
  ) |> 
  left_join(
    dim_tariff,
    relationship = "many-to-many"
  ) |> 
  mutate(
    tariff_type = case_when(
      off_peak_flag == "No off-peak tariff" ~ "Standard",
      start_time <= off_peak_start & end_time > off_peak_end ~ "Standard",
      TRUE ~ "Off-peak"
    ),
    cost_p = case_when(
      tariff_type == "Off-peak" ~ consumption_kwh * off_peak_unit_cost,
      TRUE ~ consumption_kwh * unit_cost
    )
  ) |> 
  select(
    ends_with("_key"),
    consumption_kwh,
    cost_p
  )

# Daily usage (with standing charge)
fct_daily_usage <- 
  fct_half_hourly_usage |> 
  mutate(
    date_key = as.integer(as_date(as_datetime(start_key)))
  ) |> 
  summarise(
    consumption_kwh = sum(consumption_kwh),
    cost_p = sum(cost_p),
    .by = c(date_key, tariff_key)
  ) |> 
  left_join(
    select(
      dim_tariff,
      tariff_key,
      standing_charge_p = standing_charge
    )
  ) |> 
  mutate(total_cost_p = cost_p + standing_charge_p)