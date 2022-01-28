
library(shiny)


ui <- navbarPage(
  "Rare Disease Analyser",
  source(file.path("ui", "tabPanel_data.R"), local=T, chdir=T)$value,
  source(file.path("ui", "navbarMenu_analysis.R"), local=T, chdir=T)$value
)


server <- function(input, output) {
  source(file.path("server", "data.R"), local=T, chdir=T)$value
  source(file.path("server", "analysis.R"), local=T, chdir=T)$value
}


app_options <- list(
  port=9999
)


shinyApp(
  ui=ui,
  server=server,
  options=app_options
)



