
tabPanel(
  "nparLD",
  fluidRow(
    column(
      width=6,  # outer column to fit wellPanel and inner row/cols
      offset=3,
      wellPanel(
        titlePanel("nparLD"),
        tags$hr(),
        fluidRow(
          column(
            width=4,
            tags$div(
              shinyjs::disabled(
                radioButtons(
                  "nparLD_study_design",
                  "Study Design",
                  choices=list(
                    "Single Trial Period"=1,
                    "Cross Over"=2
                  ),
                  selected=1,
                  inline=FALSE
                )
              )
            )
          ),
          column(
            width=4,
            uiOutput("nparLD_period")
          )
        ),
        fluidRow(
          column(
            width=2,
            offset=10,
            tags$div(
              shinyjs::disabled(
                actionButton(
                  "nparLD_action",
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
  ),
  fluidRow(
    column(
      width=8,
      offset=2,
      uiOutput("nparLD_out")
    )
  )
)