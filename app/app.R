
library(shiny)
# library(DT)
# library(shinyjs)
# library(nparLD)
# library(shinybusy)
library(BuyseTest)  # must be imported as BuyseTest expects the namespace to be loaded
library(pbapply)  # needed by BuyseTest but not specified in pacakage header


options(
  shiny.autoreload=TRUE
)

ui <- tagList(  # needed for useShinyjs() to be present in the top level ui
  shinyjs::useShinyjs(),
  shinybusy::add_busy_spinner(
    spin="self-building-square",
    color="#4682B4",
    timeout=200,
    position="full-page",
    onstart=TRUE
  ),
  navbarPage(
    "Rare Disease Analyser",
    source(file.path("ui", "tabPanel_user-manual.R"), local=T, chdir=T)$value,
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
