
tabPanel(
  "GPC",
  fluidRow(
    column(
      width=6,  # outer column to fit wellPanel and inner row/cols
      offset=3,
      wellPanel(
        titlePanel("GPC"),
        tags$hr(),
        fluidRow(
          column(
            width=4,
            tags$div(
              shinyjs::disabled(
                radioButtons(
                  "gpc_prio",
                  "Timepoint Prioritization",
                  choices=list(
                    "Non-Prioritzed"=1,
                    "Prioritzed"=2
                  ),
                  selected=1,
                  inline=FALSE
                )
              )
            )
          ),
          column(
            width=4,
            uiOutput("gpc_prio_order")
          )
        ),
        tags$hr(),
        fluidRow(
          # column(
          #   width=4,
          #   tags$div(
          #     shinyjs::disabled(
          #       radioButtons(
          #         "gpc_side",
          #         "Sidedness",
          #         choices=list(
          #           "One-Sided"=1,
          #           "Two-Sided"=2
          #         ),
          #         selected=1,
          #         inline=FALSE
          #       )
          #     )
          #   )
          # ),
          column(
            width=4,
            tags$div(
              shinyjs::disabled(
                radioButtons(
                  "gpc_best",
                  "Desired Outcome Values",
                  choices=list(
                    "Lower"=1,
                    "Higher"=2
                  ),
                  selected=1,
                  inline=FALSE
                )
              )
            )
          )
        ),
        fluidRow(
          column(
            width=2,
            offset=10,
            tags$div(
              shinyjs::disabled(
                actionButton(
                  "gpc_action",
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
      width=6,
      offset=3,
      uiOutput("gpc_out")
    )
  )
)