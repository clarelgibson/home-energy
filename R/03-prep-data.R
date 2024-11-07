# Summary -----------------------------------------------------------------
# This script cleans the data needed for the project

source(here::here("R/02-read-data.R"))

# Clean Data --------------------------------------------------------------
# Usage
# Clean names
usage <- usage_raw |> 
  clean_names()

# Add features
usage <- usage |> 
  mutate(
    fuel = if_else(
      str_detect(filename, "gas"),
      "Gas",
      "Electricity"
    ),
    .before = 1
  ) |> 
  select(!filename)

# Tariffs
tariffs <- 
  tariffs_raw |> 
  clean_names() |> 
  mutate(
    off_peak_start = as_hms(off_peak_start),
    off_peak_end = as_hms(off_peak_end),
    tariff_key = as.integer(tariff_key)
  )
