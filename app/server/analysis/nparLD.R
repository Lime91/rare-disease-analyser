
sort_choices <- function(choices, values) {
  matches <- integer()
  for (val in values) {
    matches <- c(
      matches,
      grep(val, tolower(choices), fixed=T, value=F)
    )
  }
  if (length(matches) > 0)
    choices <- c(choices[matches], choices[-matches])
  return(choices)
}


provide_selectize <- function(
  tag_id, label, choices, prioritzed_terms="") {
    choices <- sort_choices(choices, prioritzed_terms)
    selectizeInput(tag_id, label=label, choices=choices)
}


inputs_disabled <- reactive(
  {
    is.null(data())
  }
)


nparLD_out <- reactiveVal(NULL)


output$nparLD_outcome <- renderUI(
  { 
    tag_id <- "nparLD_outcome_var"
    label <- "Outcome"
    if (inputs_disabled())
      shinyjs::disabled(provide_selectize(
        tag_id, label, "upload dataset!")
      )
    else
      provide_selectize(
        tag_id, label, colnames(data()), c("value", "count", "outcome")
      )
  }
)

output$nparLD_group <- renderUI(
  {
    tag_id <- "nparLD_group_var"
    label <- "Group Factor"
    if (inputs_disabled())
      shinyjs::disabled(provide_selectize(tag_id, label, ""))
    else
      provide_selectize(
        tag_id,
        label,
        setdiff(colnames(data()), input$nparLD_outcome_var),
        "group"
      )
  }
)

output$nparLD_time <- renderUI(
  {
    tag_id <- "nparLD_time_var"
    label <- "Time Factor"
    if (inputs_disabled())
      shinyjs::disabled(provide_selectize(tag_id, label, ""))
    else
      provide_selectize(
        tag_id,
        label,
        setdiff(
          colnames(data()),
          c(input$nparLD_outcome_var, input$nparLD_group_var)),
        "time"
      )
  }
)

output$nparLD_subject <- renderUI(
  {
    tag_id <- "nparLD_subject_var"
    label <- "Subject"
    if (inputs_disabled())
      shinyjs::disabled(provide_selectize(tag_id, label, ""))
    else
      provide_selectize(
        tag_id,
        label,
        setdiff(
          colnames(data()),
          c(
            input$nparLD_outcome_var,
            input$nparLD_group_var,
            input$nparLD_time_var)),
        c("subject", "id")
      )
  }
)

observe(
  {
    if (!inputs_disabled()) {
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
