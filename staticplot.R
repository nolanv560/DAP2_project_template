# Data Skills R - II
# Final Project: Static Plots

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
us_oil <- read.csv(paste0(path, "us_oil.csv"))
global_flaring <- read.csv(paste0(path, "global_flaring.csv"))

# Plot 1: U.S. crude oil production and gas flaring (2012-2023)

## Aggregating U.s. gas flaring volumes
us_flaring_vol <- flaring_data %>% group_by(country, year) %>% mutate(year = as.numeric(year)) %>%
  summarize(total_bcm = sum(bcm))

## Plotting
oil_output_flaring_plot <- ggplot(us_oil, aes(x = year)) +
  geom_line(aes(y = output/1000, color = "Crude oil output (million barrels per day)"), size = 1) +
  geom_line(data = us_flaring_vol, aes(y = total_bcm, color = "Gas flared upstream (billion cubic meters)"), size = 1) +
  labs(title = "U.S. crude oil production and gas flaring, 2012-2023",
       x = "Year",
       color = element_blank(),
       caption = "Source: U.S. Energy Information Administration (EIA), Colorado School of Mines") +
  scale_x_continuous(breaks = seq(2012, 2023, 2)) +
  scale_color_manual(values = c(
    "Crude oil output (million barrels per day)" = "black",
    "Gas flared upstream (billion cubic meters)" = "red")
  ) +
  theme_minimal() +
  theme(legend.position = "bottom",
        axis.title.y = element_blank())
oil_output_flaring_plot

## Saving plot as .png file
ggsave(oil_output_flaring_plot, 
       filename = "oil_output_flaring_plot.png",
       device = "png",
       width = 8)

# Plot 2: Top five gas flaring nations per year (2012-2023)

## Plotting
top_flaring_countries_plot <- ggplot(global_flaring, aes(x = year, y = bcm, fill = country)) + 
  geom_bar(stat = "identity", color = "black") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(title = "Top five gas flaring nations, 2012-2023",
       x = "Year",
       y = "Billion cubic meters (bcm)",
       fill = "Country",
       caption = "Source: Global Gas Flaring Reduction Partnership, World Bank") +
  scale_fill_brewer(palette = "YlOrBr")
top_flaring_countries_plot

## Saving plot as .png file
ggsave(top_flaring_countries_plot, 
       filename = "top_flaring_countries_plot.png",
       device = "png",
       width = 8)

# Plot 3: Upstream gas flaring by U.S. state (2012-2023)

## Aggregating annual mean count and volumes of gas flaring sites by U.S. state
mean_flaring <- flaring_data %>% group_by(state, year) %>% mutate(
  flare_count = n(),
  state_bcm = sum(bcm)
) %>% 
  ungroup() %>% 
  group_by(state) %>% 
  summarize(
    flare_count = mean(flare_count),
    state_bcm = mean(state_bcm)
  )

## Plotting
state_flaring_plot <- ggplot(mean_flaring, aes(state_bcm, flare_count, alpha = state)) +
  geom_point(size = 5, color = "darkred") +
  theme_minimal() +
  theme(legend.position = "none") +
  geom_text(
    data = mean_flaring[mean_flaring$state %in% c("Texas", "North Dakota", "New Mexico"), ],
    aes(label = state),
    vjust = 2, hjust = 1,
    size = 3) +
  labs(title = "Upstream gas flaring by U.S. state, 2012-2023",
       x = "Mean gas flared (billion cubic meters)",
       y = "Number of gas flaring sites",
       caption = "Source: Earth Observation Group, Colorado School of Mines")
state_flaring_plot

## Saving plot as .png file
ggsave(state_flaring_plot, 
       filename = "state_flaring_plot.png",
       device = "png")