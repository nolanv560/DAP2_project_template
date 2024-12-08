# Data Skills R - II
# Final Project: Shiny App

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
flaring_data <- readRDS(paste0(path, "flaring_data.rds"))
aqi_geo <- readRDS(paste0(path, "aqi_geo.rds"))
uchicago_geo <- readRDS(paste0(path, "uchicago_geo.rds"))

# Loading as spatial data
states <- us_map(regions = "state")
counties <- us_map(regions = "county")

# Shiny app 1: Gas flaring sites by U.S. state, 2023

## UI set up

ui <- fluidPage(
  titlePanel("Gas flaring sites by U.S. state, 2012-2023"),
  
  sidebarLayout(
    sidebarPanel(
      
      selectInput(inputId = "year", label = "Please choose a year", choices = 2012:2023),
      selectInput(inputId = "state", label = "Please choose a state", 
                  choices = NULL)
      
    ),
    
    tabsetPanel(
      tabPanel("U.S. map", plotOutput("map")),
      tabPanel("State map", plotOutput("detail"))
    )
  )
)

## Server set up

server <- function(input, output) {
  flaring_data_year <- reactive({
    flaring_data |> filter(year == input$year)
  })
  
  observeEvent(flaring_data_year(), {
    state_choices <- unique(flaring_data_year()$state)
    state_choices <- sort(state_choices)
    updateSelectInput(inputId = "state", choices = state_choices)
  })
  
  flaring_data_year_state <- reactive({
    flaring_data_year() %>% filter(state == input$state)
  })
  
  output$map <- renderPlot({
    ggplot(states) +
      geom_sf() +
      geom_sf(data = flaring_data_year_state(), aes(geometry = geom)) +
      theme_void()
  })
  
  output$detail <- renderPlot({
    counties_filtered <- counties %>% filter(full == input$state)
    
    ggplot(counties_filtered) +
      geom_sf() +
      geom_sf(data = flaring_data_year_state(), aes(geometry = geom)) +
      theme_void()
  })
}

shinyApp(ui, server)

# Shiny app 2: Air pollution by U.S. state, 1998-2022

## UI set up

ui2 <- fluidPage(
  titlePanel("Air pollution by U.S. state, 1998-2022"),
  
  sidebarLayout(
    sidebarPanel(
      
      selectInput(inputId = "year", label = "Please select a year", 
                  choices = 1998:2022)
      
    ),
    
    tabsetPanel(
      tabPanel("Heatmap", plotOutput("map")),
      tabPanel("Top 10 states", plotOutput("hist"))
    )
  ),

  textOutput(outputId = "pm2_5")
  )

## Server set up

server2 <- function(input, output) {
  uchicago_year <- reactive({
    uchicago_geo %>% filter(year == input$year)
  })
  
  output$map <- renderPlot({
    ggplot(states) +
      geom_sf() +
      geom_sf(data = uchicago_year(), aes(geometry = geom, fill = pm2.5)) +
      scale_fill_gradient(low = "lightyellow", high = "red") +
      theme_void() +
      labs(fill = "Particulate matter (PM 2.5) level")
  })
  
  output$hist <- renderPlot({
    uchicago_top10states <- uchicago_year() %>% 
      group_by(state) %>% 
      arrange(desc(pm2.5)) %>% 
      head(10)
    
    ggplot(uchicago_top10states, aes(x = pm2.5, y = fct_reorder(state, pm2.5))) +
      geom_point(size = 4) +
      theme(axis.text.x = element_text(size = 14)) +
      theme(axis.text.y = element_text(size = 14)) +
      labs(x = "PM2.5",
           y = "State")
  })
  
  output$pm2_5 <- renderText(
    paste0("Particulate matter pollution of 2.5 micograms or less (PM 2.5) is the most serious type of air pollution and is associated with cardiovascular and respiratory disease as well as cancer. WHO establishes that annual PM 2.5 concentrations should not exceed 5 micograms per cubic meter.")
  )
}

shinyApp(ui2, server2)
