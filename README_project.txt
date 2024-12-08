Nolan Villasmil
Date Created: 12/07/2024
Date Modified: 12/07/2024

Required R packages: tidyverse, dplyr, stringr, readxl, sf, ggplot2, usmap, tigris, shiny, rvest, tidytext, textdata, sentimentr, fixest, httr
Version of R used: 4.3.2 (2023-10-31.ucrt)

Summary of code:
[Please note that all code scripts must be run from beginning to end. Users should replace file paths with the path were the data have been saved for proper replication. Raw, archived and cleaned data have been saved for ease in a folder called 'data'.]

data.R loads a combination of .csv and .zip files that contain data on global gas flaring volumes, global flaring sites, U.S. oil production, and U.S. air quality. Global gas flaring volumes were filtered to obtain gas flaring volumes from the top five flaring nations over the last five years. Similarly, U.S. oil production was filtered to obtain information from 2012 to 2023. Overall, the remaining data were filtered to obtain U.S. data from 2012 to 2023 and subsequently cleaned and matched with U.S. geographic information from the packages tigris and usmap. These were later saved as .csv and .RDS files, together with the cleaned data on U.S. oil production and flaring volumes from the top five flaring nations.

staticplot.R loads three cleaned datasets that contain information about U.S. flaring sites, U.S. oil production, and flaring volumes from the top five flaring nations. These were aggregated to estimate the number of flaring sites by U.S. state and an average count of these sites and their average flaring volumes for 2012-2023. Three plots were produced:

- Plot 1: A plot showing U.S. crude oil production and total gas flaring volumes from 2012 to 2023.
- Plot 2: A bar chart showing the top five flaring nations and their flaring volumes from 2012 to 2023.
- Plot 3: A scatterplot showing the main U.S. flaring states based on their average flaring volumes from 2012 to 2023.

These plots were saved in a folder titled 'images'.

shinyapp.R loads three cleaned datasets that contain georeferenced information about U.S. flaring sites and air quality. These were used to create two shiny apps:

- Shiny App 1: An interactive national and state-level map of U.S. flaring sites from 2012 to 2023.
- Shiny App 2: An interactive heatmap based on air pollution levels and a histogram showing U.S. states with the worst air pollution levels from 2012 to 2022.

model.R loads two cleaned datasets that contain information about U.S. flaring sites and air quality. These were merged into a single dataframe and two variables were created: a flare count by U.S. state and a dummy variable for flaring states. These were later used as stand-alone explanatory variables of air pollution in linear OLS and fixed-effects regression models. Results were subsequently reported.

textprocess.R retrieves a press release about a recent scientific article on the health impacts of gas flaring and venting in the U.S. Title, date and content were recovered using webscraping. Content was then tokenized by word and sentence for sentiment analysis. Three plots were produced:

- Plot 4: A histogram showing word-based sentiment analysis using AFINN.
- Plot 5: A histogram showing word-based sentiment analysis using NRC.
- Plot 6: A histogram showing word-based sentiment analysis using Bing.

These plots were saved in a folder titled 'images'.
Explanation of the original data source:

The Annual Gas Flared Volume data by the Earth Observatory Group (EOG) and Colorado School of Mines comprised information about every gas flare site detected globally through satellite monitoring, including country of origin, year, estimated volumes of flared gas (expressed in billion cubic meters), longitude and latitude. This initial data was saved in multiple Excel files which divided the data on upstream and downstream. These data is updated annually on the EOG's website through the following link: https://eogdata.mines.edu/products/vnf/global_gas_flare.html

The Air Quality Index (AQI) by the U.S. Environmental Protection Agency (EPA) comprised a time series of index measurements for each reporting county in the United States. This included the number of days with different levels of air quality, as well as the total number of days in the year for which AQI observations were recorded by local air quality monitors. Data is updated annually and can be downloaded from the EPA's website: https://aqs.epa.gov/aqsweb/airdata/download_files.html#Annual

The Air Quality Life Index (AQLI) by the Energy Policy Institute at the University of Chicago (EPIC) comprised a time series containing measurements of population-weighted atmospheric particulate pollution (particulate mater (PM) 2.5 micrograms per cubic meter or less), alongside estimations of additional days of live saved if WHO and U.S. air quality standards were met. This information was available for all U.S. states. Unlike the AQI data, these estimations were calculated based on satellite estimations and aggregated for the relevant administrative unit.

The U.S. Energy Information Administration (EIA) published the data on U.S. oil crude field production. This time series is available from 1990 to 2023. It can be downloaded from the EIA's official website: https://www.eia.gov/petroleum/production/

Global gas flaring volumes were published by the Global Gas Flaring Reduction Partnership (GGFR). These data are available for all major gas flaring nations by year. It can be downloaded from the World Bank's website: https://www.worldbank.org/en/programs/gasflaringreduction/global-flaring-data#:~:text=Global%20Gas%20Flaring%20Data,-The%20World%20Bank%27s%20Global