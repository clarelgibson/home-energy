# Summary -----------------------------------------------------------------
# This script exports the data needed for the project

source(here::here("R/04-model-data.R"))

dest <- here("data/cln/data_model.xlsx")

# Export data -------------------------------------------------------------
write_xlsx(
  list(
    fct_daily_usage = fct_daily_usage,
    fct_half_hourly_usage = fct_half_hourly_usage,
    dim_date = dim_date,
    dim_start = dim_start,
    dim_end = dim_end,
    dim_tariff = dim_tariff
  ),
  path = dest
)