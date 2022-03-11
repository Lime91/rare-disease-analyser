
library(shiny)
# library(DT)
# library(shinyjs)
# library(nparLD)


ui <- tagList(  # needed for useShinyjs() to be present in the top level ui
  shinyjs::useShinyjs(),
  navbarPage(
    "Rare Disease Analyser",
    source(file.path("ui", "tabPanel_data.R"), local=T, chdir=T)$value,
    source(file.path("ui", "navbarMenu_analysis.R"), local=T, chdir=T)$value
  )
)


server <- function(input, output, session) {
  source(file.path("server", "data.R"), local=T, chdir=T)$value
  source(file.path("server", "analysis.R"), local=T, chdir=T)$value
}


# options set as environment variables (e.g., in Dockerfile)
app_options <- list(
  port=as.integer(
    Sys.getenv("LISTENING_PORT", unset="3838")
  ),
  host=Sys.getenv("LISTENING_ADDRESS", unset="127.0.0.1")
)


app <- shinyApp(
  ui=ui,
  server=server,
  options=app_options
)



