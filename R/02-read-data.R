# Summary -----------------------------------------------------------------
# This script retrieves the data required for the project.

source(here::here("R/01-setup.R"))

# Setup -------------------------------------------------------------------
# Set parameters
folder <- here("data/src/usage")
files <- list.files(folder, full.names = TRUE)

# Get Data ----------------------------------------------------------------
# Store the raw imported data in a variable "XXX_raw" so that we
# maintain a copy of the unaltered data in R.

# Usage
usage_raw <- vroom(
  files,
  id = "filename"
)

# Tariffs
tariffs_raw <- 
  read_sheet(
    drive_get("tariffs-data")
  )
