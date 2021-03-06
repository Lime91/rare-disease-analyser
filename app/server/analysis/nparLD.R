
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
      shinyjs::disabled(selectize_outcome("upload dataset!"))
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
    if (!disabled()) {
      shinyjs::enable("nparLD_action")
      shinyjs::enable("nparLD_alpha")
    }
  }
)
  
observeEvent(
  input$nparLD_action,
  {
    out <- tryCatch(
      {
        form <- as.formula(
          paste(
            input$nparLD_outcome_var,
            paste(
              input$nparLD_group_var,
              input$nparLD_time_var,
              sep="*"
            ),
            sep="~"
          )
        )
        nparLD::nparLD(
          form,
          data(),
          input$nparLD_subject_var,
          description=FALSE,
          order.warning=FALSE,
          alpha=input$nparLD_alpha
        )
      },
      error=function(e) {
        shinyjs::alert(
          paste("nparLD error:", e$message)
        )
        return(NULL)
      }
    )
    nparLD_out(out)
  }
)

output$nparLD_rte <- renderUI(
  {
    if (is.null(nparLD_out()))
      tags$div(id="nparLD_rte_placeholder")  # is this necessary?
    else {
      output$nparLD_rte_plot <- renderPlot(
        {
          nparLD::plot.nparLD(nparLD_out())
        }
      )
      plotOutput("nparLD_rte_plot")
    }
  }
)

output$nparLD_table <- renderUI(
  {
    if (is.null(nparLD_out()))
      tags$div(id="nparLD_table_placeholder")
    else {
      output$nparLD_table_content <- renderTable(
        {
          df <- data.frame(
            nparLD_out()$ANOVA.test
          )
          df$df <- as.integer(df$df)  # cast degrees of freedom to integer
          return(df)
        },
        rownames=TRUE,
        colnames=TRUE,
        align="r",
        digits=4
      )
      tags$div(
        tags$br(),
        tags$h4(
          "ANOVA-Type Statistic",
          style="font-weight:bold;"
        ),
        tags$br(),
        tableOutput("nparLD_table_content")
      )
    }
  }
)
