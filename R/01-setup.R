# Summary -----------------------------------------------------------------
# This script loads the required packages and contains custom functions
# and variables needed for the project.

# Packages ----------------------------------------------------------------
library(here)
library(googledrive)
library(googlesheets4)
library(tidyverse)
library(vroom)
library(janitor)
library(hms)
library(writexl)

# Authenticate ------------------------------------------------------------
#drive_auth()
#gs4_auth(token = drive_token())
gs4_deauth()

# Functions ---------------------------------------------------------------
# Create a datetime dimension table from a vector of datetime values.
make_datetime_dimension <- function(dt, prefix = "datetime") {
  df <- tibble(
    datetime = dt
  ) |> 
    mutate(
      key = as.integer(datetime),
      .before = 1
    ) |> 
    mutate(
      date = as_date(datetime),
      time = as_hms(datetime),
      year = year(datetime),
      month = month(datetime),
      day = day(datetime),
      hour = hour(datetime),
      day_of_week = wday(
        datetime,
        label = TRUE,
        week_start = getOption("lubridate.week.start", 1)
      ),
      weekend_flag = case_when(
        day_of_week %in% c("Sat", "Sun") ~ "Weekend",
        TRUE ~ "Weekday"
      ),
      season = case_when(
        between(month, 3, 5) ~ "Spring",
        between(month, 6, 8) ~ "Summer",
        between(month, 9, 11) ~ "Autumn",
        month %in% c(12,1,2) ~ "Winter",
        TRUE ~ "Not defined"
      )
    ) |> 
    rename_with( ~ paste(prefix, .x, sep = "_"))
  
  return(df)
}
