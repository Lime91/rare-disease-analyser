
tabPanel(
  "nparLD",
  
  fluidRow(
    
    column(
      width=6,  # outer column to fit wellPanel and inner row/cols
      offset=3,
      
      wellPanel(
        fluidRow(
          
          column(
            width=4,
            uiOutput("nparLD_outcome")
          ),
          
          column(
            width=4,
            uiOutput("nparLD_group_factor")
          ),
          
          column(
            width=4,
            uiOutput("nparLD_time_factor")
          )
        )
      )
    )
  )
)