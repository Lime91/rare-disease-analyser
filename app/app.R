
library(shiny)
# library(DT)
# library(shinyjs)


ui <- tagList(  # needed for useShinyjs() to be present in the top level ui
  shinyjs::useShinyjs(),
  navbarPage(
    "Rare Disease Analyser",
    source(file.path("ui", "tabPanel_data.R"), local=T, chdir=T)$value,
    source(file.path("ui", "navbarMenu_analysis.R"), local=T, chdir=T)$value
  )
)


server <- function(input, output) {
  source(file.path("server", "data.R"), local=T, chdir=T)$value
  source(file.path("server", "analysis.R"), local=T, chdir=T)$value
}


app_options <- list(
  port=9999
)


app <- shinyApp(
  ui=ui,
  server=server,
  options=app_options
)

shiny::runApp(
  app
)

