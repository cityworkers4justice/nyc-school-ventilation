# load libraries
library(tidyverse)
library(sf)
library(basemapR)

# read in data
ventilation_data <- read_csv("output/NYC_Schools_Ventilation_Data.csv")
school_locations <- read_csv("data/NYC_School_Locations.csv")
nta_data <- nycgeo::nyc_boundaries(geography = "nta", add_acs_data = TRUE) %>%
  mutate(pop_nonwhite_pct_est = 1 - pop_white_pct_est)

# rename columns
names(ventilation_data) <- c("Primary_building_code","rooms_total","windows","windows_open", 
                             "supplyFan_operational","supplyFan_partOperational","supplyFan_nonOperational",
                             "exhaustFan_operational","exhaustFan_partOperational","exhaustFan_nonOperational",
                             "unitVentilator_operational","unitVentilator_partOperational","unitVentilator_nonOperational")

# calculate totals
ventilation_data <- ventilation_data %>%
  rowwise() %>%
  mutate(supplyFan_total = sum(supplyFan_operational,supplyFan_partOperational,supplyFan_nonOperational),
         exhaustFan_total = sum(exhaustFan_operational,exhaustFan_partOperational,exhaustFan_nonOperational),
         unitVentilator_total = sum(unitVentilator_operational,unitVentilator_partOperational,unitVentilator_nonOperational)) %>%
  ungroup() %>%
  select(Primary_building_code, rooms_total, windows, windows_open,
         supplyFan_total, supplyFan_operational, supplyFan_partOperational, supplyFan_nonOperational, 
         exhaustFan_total, exhaustFan_operational, exhaustFan_partOperational, exhaustFan_nonOperational, 
         unitVentilator_total, unitVentilator_operational, unitVentilator_partOperational, unitVentilator_nonOperational)

# calculate percentages
school_data <- ventilation_data %>%
  mutate(perc_rooms_windows = round(windows/rooms_total, digits = 6),
         perc_rooms_windows_open = round(windows_open/rooms_total, digits = 6),
         perc_rooms_supplyFan = round(supplyFan_total/rooms_total, digits = 6),
         perc_rooms_supplyFan_operational = round(supplyFan_operational/rooms_total, digits = 6),
         perc_rooms_supplyFan_partOperational = round(supplyFan_partOperational/rooms_total, digits = 6),
         perc_rooms_supplyFan_nonOperational = round(supplyFan_nonOperational/rooms_total, digits = 6),
         perc_rooms_exhaustFan = round(exhaustFan_total/rooms_total, digits = 6),
         perc_rooms_exhaustFan_operational = round(exhaustFan_operational/rooms_total, digits = 6),
         perc_rooms_exhaustFan_partOperational = round(exhaustFan_partOperational/rooms_total, digits = 6),
         perc_rooms_exhaustFan_nonOperational = round(exhaustFan_nonOperational/rooms_total, digits = 6),
         perc_rooms_unitVentilator = round(unitVentilator_total/rooms_total, digits = 6),
         perc_rooms_unitVentilator_operational = round(unitVentilator_operational/rooms_total, digits = 6),
         perc_rooms_unitVentilator_partOperational = round(unitVentilator_partOperational/rooms_total, digits = 6),
         perc_rooms_unitVentilator_nonOperational = round(unitVentilator_nonOperational/rooms_total, digits = 6))

total_cols <- c("rooms_total","windows","windows_open",
                "supplyFan_total","supplyFan_operational","supplyFan_partOperational","supplyFan_nonOperational",
                "exhaustFan_total","exhaustFan_operational","exhaustFan_partOperational","exhaustFan_nonOperational",
                "unitVentilator_total","unitVentilator_operational","unitVentilator_partOperational","unitVentilator_nonOperational")

# group by NTA
district_data <- ventilation_data %>%
  left_join(school_locations, by = "Primary_building_code") %>%
  select(NTA, NTA_Name, total_cols) %>%
  group_by(NTA) %>%
  mutate(across(all_of(total_cols), sum)) %>%
  unique() %>%
  ungroup() %>%
  mutate(perc_rooms_windows = round(windows/rooms_total, digits = 6),
         perc_rooms_windows_open = round(windows_open/rooms_total, digits = 6),
         perc_rooms_supplyFan = round(supplyFan_total/rooms_total, digits = 6),
         perc_rooms_supplyFan_operational = round(supplyFan_operational/rooms_total, digits = 6),
         perc_rooms_supplyFan_partOperational = round(supplyFan_partOperational/rooms_total, digits = 6),
         perc_rooms_supplyFan_nonOperational = round(supplyFan_nonOperational/rooms_total, digits = 6),
         perc_rooms_exhaustFan = round(exhaustFan_total/rooms_total, digits = 6),
         perc_rooms_exhaustFan_operational = round(exhaustFan_operational/rooms_total, digits = 6),
         perc_rooms_exhaustFan_partOperational = round(exhaustFan_partOperational/rooms_total, digits = 6),
         perc_rooms_exhaustFan_nonOperational = round(exhaustFan_nonOperational/rooms_total, digits = 6),
         perc_rooms_unitVentilator = round(unitVentilator_total/rooms_total, digits = 6),
         perc_rooms_unitVentilator_operational = round(unitVentilator_operational/rooms_total, digits = 6),
         perc_rooms_unitVentilator_partOperational = round(unitVentilator_partOperational/rooms_total, digits = 6),
         perc_rooms_unitVentilator_nonOperational = round(unitVentilator_nonOperational/rooms_total, digits = 6)) %>%
  # make park-cemetery data NA
  mutate(across(contains("perc_"), ~ifelse(str_detect(NTA_Name, "park-cemetery"), NA, .)))
