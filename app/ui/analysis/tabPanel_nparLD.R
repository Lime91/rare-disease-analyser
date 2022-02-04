
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
            uiOutput("nparLD_group_factor")
          ),
          
          column(
            width=3,
            uiOutput("nparLD_time_factor")
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
            offset=8,
            tags$div(
              shinyjs::disabled(
                actionButton(
                  "nparLD_action",
                  "Go!",
                  class="btn btn-primary"  # bootstrap
                )
              ),
              style="float:right"
            )
          )
        )
      )
    )
  )
)