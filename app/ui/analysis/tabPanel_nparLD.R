
tabPanel(
  "nparLD",
  
  fluidRow(
    column(
      width=6,  # outer column to fit wellPanel and inner row/cols
      offset=3,
      
      wellPanel(
        fluidRow(
          column(
            width=3,
            uiOutput("nparLD_outcome")
          ),
          
          column(
            width=3,
            uiOutput("nparLD_group")
          ),
          
          column(
            width=3,
            uiOutput("nparLD_time")
          ),
          
          column(
            width=3,
            uiOutput("nparLD_subject")
          )
        ),
        
        tags$hr(),
        
        fluidRow(
          column(
            width=4,
            tags$div(
              shinyjs::disabled(
                radioButtons(
                  "nparLD_alpha",
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
      width=5,
      offset=2,
      uiOutput(
        "nparLD_rte"
      )
    ),
    
    column(
      width=3,
      tags$div(
        uiOutput(
          "nparLD_table"
        ),
        style="float:right;"
      )
    )
  )
)