
nparLDInput <- function(id) {
  ns <- NS(id)
  tagList(

    fluidRow(
      column(
        width=6,  # outer column to fit wellPanel and inner row/cols
        offset=3,
        wellPanel(
          fluidRow(
            column(
              width=3,
              uiOutput(ns("outcome"))
            ),
            column(
              width=3,
              uiOutput(ns("group"))
            ),
            column(
              width=3,
              uiOutput(ns("time"))
            ),
            column(
              width=3,
              uiOutput(ns("subject"))
            )
          ),
          tags$hr(),
          fluidRow(
            column(
              width=4,
              tags$div(
                shinyjs::disabled(
                  radioButtons(
                    ns("alpha"),
                    "Alpha",
                    choices=list(
                      "1%"=0.01,
                      "5%"=0.05,
                      "10%"=0.1
                    ),
                    selected=0.05,
                    inline=TRUE
                  )
                )
              )
            ),
            column(
              width=2,
              offset=6,
              tags$div(
                shinyjs::disabled(
                  actionButton(
                    ns("action"),
                    "Go!",
                    class="btn btn-primary"  # bootstrap
                  )
                ),
                style="float:right;"
              )
            )
          )
        )
      )
    )
  )
}


nparLDOutput <- function(id) {
  ns <- NS(id)
  tagList(

    fluidRow(
      column(
        width=5,
        offset=2,
        uiOutput(
          ns("rte")
        )
      ),
      column(
        width=3,
        tags$div(
          uiOutput(
            ns("table")
          ),
          style="float:right;"
        )
      )
    )
  )
}


tabPanel(
  "nparLD",
  nparLDInput("nparLD"),
  nparLDOutput("nparLD")
)