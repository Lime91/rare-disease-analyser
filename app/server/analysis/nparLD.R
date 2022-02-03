
disabled <- reactive(
  {
    is.null(dataset())
  }
)

selectize_outcome <- function(choices) {
  selectizeInput(
    "nparLD_outcome_var",
    label="Outcome Variable",
    choices=choices
  )
}

selectize_group <- function(choices) {
  selectizeInput(
    "nparLD_group_var",
    label="Group Variable",
    choices=choices
  )
}

selectize_time <- function(choices) {
  selectizeInput(
    "nparLD_time_var",
    label="Time Variable",
    choices=choices
  )
}

output$nparLD_outcome <- renderUI(
  {
    if (disabled())
      shinyjs::disabled(selectize_outcome("upload datset!"))
    else
      selectize_outcome(colnames(dataset()))
  }
)

output$nparLD_group_factor <- renderUI(
  {
    if (disabled())
      shinyjs::disabled(selectize_group(""))
    else
      selectize_group(
        setdiff(
          colnames(dataset()),
          input$nparLD_outcome_var
        )
      )
  }
)
 
output$nparLD_time_factor <- renderUI(
  {
    if (disabled())
      shinyjs::disabled(selectize_time(""))
    else
      selectize_time(
        setdiff(
          colnames(dataset()),
          c(input$nparLD_outcome_var, input$nparLD_group_var)
        )
      )
  }
)

observe(
  {
    if (!disabled())
      shinyjs::enable("nparLD_action")
  }
)
  
observeEvent(
  input$nparLD_action,
  {
    cat("action registered!\n")
  }
)
