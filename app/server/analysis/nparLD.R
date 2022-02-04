
disabled <- reactive(
  {
    is.null(data())
  }
)

nparLD_out <- reactiveVal(NULL)

selectize_outcome <- function(choices) {
  selectizeInput(
    "nparLD_outcome_var",
    label="Outcome",
    choices=choices
  )
}

selectize_group <- function(choices) {
  selectizeInput(
    "nparLD_group_var",
    label="Group Factor",
    choices=choices
  )
}

selectize_time <- function(choices) {
  selectizeInput(
    "nparLD_time_var",
    label="Time Factor",
    choices=choices
  )
}

selectize_subject <- function(choices) {
  selectizeInput(
    "nparLD_subject_var",
    label="Subject",
    choices=choices
  )
}

output$nparLD_outcome <- renderUI(
  {
    if (disabled())
      shinyjs::disabled(selectize_outcome("upload datset!"))
    else
      selectize_outcome(colnames(data()))
  }
)

output$nparLD_group_factor <- renderUI(
  {
    if (disabled())
      shinyjs::disabled(selectize_group(""))
    else
      selectize_group(
        setdiff(
          colnames(data()),
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
          colnames(data()),
          c(input$nparLD_outcome_var,
            input$nparLD_group_var)
        )
      )
  }
)

output$nparLD_subject <- renderUI(
  {
    if (disabled())
      shinyjs::disabled(selectize_subject(""))
    else
      selectize_subject(
        setdiff(
          colnames(data()),
          c(input$nparLD_outcome_var,
            input$nparLD_group_var,
            input$nparLD_time_var)
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
    nparLD_out <- tryCatch(
      {
        df <- data()
        nparLD::f1.ld.f1(
          df[[input$nparLD_outcome_var]],
          df[[input$nparLD_time_var]],
          df[[input$nparLD_group_var]],
          df[[input$nparLD_subject_var]],
          time.name=input$nparLD_time_var,
          group.name=input$nparLD_group_var,
          plot.RTE=FALSE,
          order.warning=FALSE
        )
      },
      error=function(e) {
        shinyjs::alert(
          paste("nparLD error:", e$message)
        )
        return(NULL)
      }
    )
  }
)
