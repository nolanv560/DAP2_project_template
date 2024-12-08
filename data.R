# Data Skills R - II
# Final Project: Data

# Load libraries
req_libraries <- c("tidyverse", "dplyr", "stringr", "readxl", "sf", "ggplot2", "usmap", "tigris", "shiny", "rvest", "tidytext", "textdata", "sentimentr", "fixest", "httr")
load_libraries <- function(libraries) {
  for (i in libraries) {
    if (!requireNamespace(i, quietly = TRUE)) {
      install.packages(i)
    }
    library(i, character.only = TRUE)
  }
}
load_libraries(req_libraries)

## All data have been downloaded. However, it is possible to set a personal path using the code below.
path <- "C:/Users/nolan/Documents/Academia/Maestría en Políticas Públicas, Universidad de Chicago/Datos y Programación para Política Pública - R II/"

# DATA IMPORT

# U.S. crude oil field production data - EIA

## Inspecting Excel files to find the relevant sheets before importing oil production data was necessary. However, the step outlined below is optional.
##excel_sheets(paste0(path, "MCRFPUS2a.xls"))

us_oil <- read_excel(paste0(path, "MCRFPUS2a.xls"), sheet = 2, skip = 2)

# Global gas flaring data - GGFR, World Bank
global_flaring <- read_xlsx(paste0(path, "Flare-volume-and-intensity-estimates-2012-2023.xlsx"))

# Gas flaring sites data - Earth Observation Group

## Inspecting Excel files to find the relevant sheets before importing  annual gas flaring data was necessary. However, these steps outlined below are optional.
## excel_sheets(paste0(path, "VIIRS_Global_flaring_d.7_slope_0.0298_2012-2016_web.xlsx"))
## excel_sheets(paste0(path, "VIIRS_Global_flaring_d.7_slope_0.029353_2017_web_v1.xlsx"))
## excel_sheets(paste0(path, "VIIRS_Global_flaring_d.7_slope_0.029353_2018_web.xlsx"))
## excel_sheets(paste0(path, "VIIRS_Global_flaring_d.7_slope_0.029353_2019_web_v20201114.xlsx"))
## excel_sheets(paste0(path, "VIIRS_Global_flaring_d.7_slope_0.029353_2020_web_v1.xlsx"))
## excel_sheets(paste0(path, "VIIRS_Global_flaring_d.7_slope_0.029353_2021_web.xlsx"))
## excel_sheets(paste0(path, "VIIRS_Global_flaring_d.7_slope_0.029353_2022_v20230526_web.xlsx"))
## excel_sheets(paste0(path, "VIIRS_Global_flaring_d.7_slope_0.029353_2023_v20230614_web_IDmatch.xlsx"))

## Saving annual upstream gas flaring data (2012-2016)
flaring_2012_2016 <- read_excel(paste0(path, "VIIRS_Global_flaring_d.7_slope_0.0298_2012-2016_web.xlsx"), sheet = 1)
flaring_2017 <- read_excel(paste0(path, "VIIRS_Global_flaring_d.7_slope_0.029353_2017_web_v1.xlsx"), sheet = 1)
flaring_2018 <- read_excel(paste0(path, "VIIRS_Global_flaring_d.7_slope_0.029353_2018_web.xlsx"), sheet = 4)
flaring_2019 <- read_excel(paste0(path, "VIIRS_Global_flaring_d.7_slope_0.029353_2019_web_v20201114.xlsx"), sheet = 4)
flaring_2020 <- read_excel(paste0(path, "VIIRS_Global_flaring_d.7_slope_0.029353_2020_web_v1.xlsx"), sheet = 1)
flaring_2021 <- read_excel(paste0(path, "VIIRS_Global_flaring_d.7_slope_0.029353_2021_web.xlsx"), sheet = )
flaring_2022 <- read_excel(paste0(path, "VIIRS_Global_flaring_d.7_slope_0.029353_2022_v20230526_web.xlsx"), sheet = 1)
flaring_2023 <- read_excel(paste0(path, "VIIRS_Global_flaring_d.7_slope_0.029353_2023_v20230614_web_IDmatch.xlsx"), sheet = 1)

# Air Quality Index - EPA

## Option to use archived version of retrieved dataset
use_archived_data <- readline("Would you like to retrieve dataset from the web?(Yes/No): ")
archived_data <- "annual_aqi_by_county_2023.zip"
aqi_url <- "https://aqs.epa.gov/aqsweb/airdata/annual_aqi_by_county_2023.zip"

## Load data based on input
if (tolower(use_archived_data) == "yes" & file.exists(archived_data)) {
  message("Loading archived dataset.")
  zippath <- path
  zipF <- list.files(zippath, pattern = "^annual_aqi_by_county_\\d{4}\\.zip$", full.names = TRUE)
  zipF <- sapply(zipF, unzip)
  aqi <- lapply(zipF, read.csv, row.names = NULL)
  aqi <- do.call(rbind, aqi)
} else {
  message("Retrieving data using API.")
  response <- GET(aqi_url)
  aqi <- content(response, as = "raw")
  writeBin(aqi, "annual_aqi_by_county_2023.zip")
  aqi <- unzip("annual_aqi_by_county_2023.zip")
  aqi <- lapply(aqi, read.csv, row.names = NULL)
  aqi <- do.call(rbind, aqi)
  
  message("Data have been retrieved.")
}

## It is an option to manually retrieve online data using API endpoint as follows.
## aqi_url <- "https://aqs.epa.gov/aqsweb/airdata/annual_aqi_by_county_2023.zip"
## response <- GET(aqi_url)
## aqi <- content(response, as = "raw")
## writeBin(aqi, "annual_aqi_by_county_2023.zip")
## aqi <- unzip("annual_aqi_by_county_2023.zip")
## aqi <- lapply(aqi, read.csv, row.names = NULL)
## aqi <- do.call(rbind, aqi)

## Alternatively, these data have been downloaded and can be loaded using your persona path file as follows.
## zippath <- "your-path-here"
## zipF <- list.files(zippath, pattern = "^annual_aqi_by_county_\\d{4}\\.zip$", full.names = TRUE)
## zipF <- sapply(zipF, unzip)
## aqi <- lapply(zipF, read.csv, row.names = NULL)
## aqi <- do.call(rbind, aqi)

# Air Quality Life Index (AQLI) - University of Chicago
uchicago <- read.csv(paste0(path, "aqli_country_data_United States.csv"))

# DATA CLEANING

# U.S. oil production

## Filtering for 2012-2023 and cleaning
us_oil$Date <- year(us_oil$Date)
names(us_oil)[2] <- "output"
us_oil <- us_oil %>% rename(year = Date) %>% filter(year >= 2012 & year <= 2023)

## Saving cleaned dataframe as .csv file
write_csv(us_oil, "us_oil.csv")

# Global gas flaring

## Pivoting to year column
global_flaring <- global_flaring %>% pivot_longer(cols = starts_with("20"),
                                                  names_to = "year",
                                                  values_to = "bcm")

## Restricting top five flaring nations per year
global_flaring <- global_flaring %>% rename(country = `Country, bcm`) %>% 
  filter(country != "Total") %>%
  group_by(year) %>% 
  arrange(year, desc(bcm)) %>%
  slice_head(n = 5) %>% 
  ungroup()

## Saving  cleaned dataframe as .csv file
write_csv(global_flaring, "global_flaring.csv")

# Gas flaring sites
## Separating 2012-2015 and 2016 series into different dataframes for ease of cleaning
flaring_2016 <- flaring_2012_2016 %>% filter(str_starts(id_key, "VNF_e2016"))
flaring_2012 <- flaring_2012_2016 %>% filter(str_starts(id_key, "VNF_e2012"))

## Standardizing ID key format for 2012-2015, 2016 and 2023 dataframes
flaring_2016$id_key <- str_extract(flaring_2016$id_key, "(?<=n)(\\d+)")
flaring_2012$id_key <- str_extract(flaring_2012$id_key, "(?<=n)(\\d+)")
flaring_2023 <- flaring_2023 %>% select(!starts_with("id2"))

## Function to filter across time series for United States flaring sites and conducting data cleaning
years <- c(2012, 2016:2023)

for(year in years){
  df <- get(paste0("flaring_", year))
  
  colnames(df) <- tolower(colnames(df))
  
  df <- df %>% 
    filter(country == "United States") %>%
    select(starts_with("id"), latitude, longitude, country, starts_with("bcm"))
  
  df <- df %>% pivot_longer(
    cols = starts_with("bcm"),
    names_to = "year",
    values_to = "bcm"
  ) %>% 
    mutate(year = str_extract(year, "\\d{4}")) %>%
    rename(id = starts_with("id"))
  
  assign(paste0("flaring_", year), df)
}

## Merging annual U.S. upstream gas flaring data into single dataframe and further clean
flaring_dfs <- mget(paste0("flaring_", c(2012, 2016:2023)))
flaring_data <- do.call(rbind, flaring_dfs)
flaring_data <- flaring_data %>% 
  rownames_to_column() %>% 
  select(-rowname) %>%
  filter(bcm != 0) %>% 
  mutate(bcm = as.numeric(bcm))

## Converting into geometric data
flaring_data <- flaring_data %>% st_as_sf(coords = c("longitude", "latitude"), crs = 4326)
flaring_data <- flaring_data %>% rename(geom = geometry)

## Matching with U.S. state and county level identifiers for geo-referenced time-series
counties <- counties(cb = TRUE)
counties <- st_transform(counties, crs = 4326)
st_crs(flaring_data) == st_crs(counties)
flaring_data <- st_join(flaring_data, counties)
flaring_data <- flaring_data %>% select(id, country, STATE_NAME, NAMELSAD, year, bcm, geom) %>% 
  rename(state = STATE_NAME, county = NAMELSAD)
flaring_data <- flaring_data %>% filter(!is.na(county)) %>% filter(!state == "Puerto Rico")
flaring_data <- usmap_transform(flaring_data)
flaring_data <- st_as_sf(flaring_data)

## Saving cleaned dataframe as .csv file
write_csv(flaring_data, "flaring_data.csv")

## Saving cleaned dataframe as .rds file
saveRDS(flaring_data, "flaring_data.rds")

## Air Quality Index - EPA
## Adjusting column names and filtering out non-U.S. states
colnames(aqi) <- tolower(colnames(aqi))
colnames(aqi) <- gsub("\\.", "_", colnames(aqi))
aqi <- aqi %>% rename(days_pm2.5 = days_pm2_5) %>% 
  filter(!state == "Country Of Mexico" & !state == "Puerto Rico" & !state == "Virgin Islands")
row.names(aqi) <- NULL

## Standardizing variable names and formats for joining with U.S. geometric data
counties <- counties(cb = TRUE, year = 2021)
counties <- counties %>% rename(county = NAME, state = STATE_NAME)
aqi$state[aqi$state == "District Of Columbia"] <- "District of Columbia"
aqi$county <- gsub("(?i)city", "City", aqi$county, perl = TRUE)
aqi$county <- gsub("Saint", "St.", aqi$county, perl = TRUE)
aqi$county <- gsub("St.e", "Ste.", aqi$county, perl = TRUE)
aqi$county <- gsub("Dona Ana", "Doña Ana", aqi$county, perl = TRUE)
aqi$county <- trimws(aqi$county)
counties$county[counties$county == "St. Louis" & counties$NAMELSAD == "St. Louis city"] <- "St. Louis City"
aqi$county[aqi$county == "Baltimore (City)"] <- "Baltimore City"
counties$county[counties$county == "Baltimore" & counties$NAMELSAD == "Baltimore city"] <- "Baltimore City"
aqi$county[aqi$county == "Alexandria City"] <- "Alexandria"
aqi$county[aqi$county == "Bristol City"] <- "Bristol"
aqi$county[aqi$county == "Charles" & aqi$state == "Virginia"] <- "Charles City"
aqi$county[aqi$county == "Fredericksburg City"] <- "Fredericksburg"
aqi$county[aqi$county == "Hampton City"] <- "Hampton"
aqi$county[aqi$county == "Hopewell City"] <- "Hopewell"
aqi$county[aqi$county == "Lynchburg City"] <- "Lynchburg"
aqi$county[aqi$county == "Norfolk City"] <- "Norfolk"
aqi$county[aqi$county == "Richmond City"] <- "Richmond"
aqi$county[aqi$county == "Roanoke City"] <- "Roanoke"
aqi$county[aqi$county == "Salem City"] <- "Salem"
aqi$county[aqi$county == "Suffolk City"] <- "Suffolk"
aqi$county[aqi$county == "Virginia Beach City"] <- "Virginia Beach"
aqi$county[aqi$county == "Winchester City"] <- "Winchester"

## Matching for geo-referenced and cleaned dataframe
aqi_geo <- left_join(aqi, counties, by = c("state", "county"))
aqi_geo %>% filter(is.na(NAMELSAD)) # checking for unmatched rows
aqi_geo <- aqi_geo %>% select(!c(STATEFP, COUNTYFP, COUNTYNS, AFFGEOID, GEOID, NAMELSAD, STUSPS, LSAD, ALAND, AWATER))

## Saving cleaned dataframe as .csv file
write_csv(aqi_geo, "aqi_geo.csv")

## Saving cleaned dataframe as .rds file
saveRDS(aqi_geo, "aqi_geo.rds")

## Air Quality Life Index (AQLI) - University of Chicago
## Selecting relevant variables and cleaning
uchicago <- uchicago %>% pivot_longer(cols = starts_with("pm"),
                                      names_to = "year",
                                      values_to = "pm2.5") %>% 
  select(name, population, year, starts_with("pm")) %>% 
  mutate(year = str_extract(year, "\\d{4}")) %>% 
  rename(state = name)

## Matching with U.S. geometric data for georeferenced dataframe at the state level
states <- us_map(regions = "state")
states <- states %>% rename(state = full)
uchicago_geo <- left_join(uchicago, states, by = "state")

## Saving cleaned dataframe as .csv file
write_csv(uchicago_geo, "uchicago_geo.csv")

## Saving cleaned dataframe as .shp file
saveRDS(uchicago_geo, "uchicago_geo.rds")