# Data Skills R - II
# Final Project: Model Fit

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

# Import data
path <- "C:/Users/nolan/Documents/"
flaring_data <- read.csv(paste0(path, "flaring_data.csv"))
uchicago_geo <- read.csv(paste0(path, "uchicago_geo.csv"))

# Regression analysis

## Merging datasets
## Aggregating number of flaring sites and volumes by U.S. state
flaring_state <- flaring_data %>%
  group_by(state, year) %>% 
  summarize(flaring_sites = n(),
            bcm = sum(bcm))

## Creating merged dataframe with flaring and air quality data by U.S. state
flaring_airq <- left_join(uchicago_geo, flaring_state, by = c("state", "year")) %>%
  mutate(year = as.numeric(year)) %>% 
  filter(year >= 2012 & year <= 2022) %>% 
  mutate(flaring_sites = replace(flaring_sites, is.na(flaring_sites), 0),
         bcm = replace(bcm, is.na(bcm), 0),
         flaring = ifelse(flaring_sites > 0, 1, 0)) # creating flaring dummy

# OLS linear regression

## On dummy variable for flaring
summary(lm(pm2.5 ~ flaring, flaring_airq))

## On number of flaring sites
summary(lm(pm2.5 ~ flaring_sites, flaring_airq))

# Fixed effects regression

## On dummy variable for flaring
summary(feols(pm2.5 ~ flaring | state + year,
              cluster = ~state,
              data = flaring_airq))

## On number of flaring sites
summary(feols(pm2.5 ~ flaring_sites | state + year,
              cluster = ~state,
              data = flaring_airq))
