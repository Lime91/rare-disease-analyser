
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


nparLDInputServer <- function(id, inputs_disabled) {
  moduleServer(
    id,
    function(input, output, session) {

      ns <- session$ns

      observe(
        {
          if (!inputs_disabled()) {
            shinyjs::enable(ns("action"))
            shinyjs::enable(ns("alpha"))
          }
        }
      )

      output$outcome <- renderUI(
        { 
          tag_id <- ns("outcome_var")
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

      output$group <- renderUI(
        {
          tag_id <- ns("group_var")
          label <- "Group Factor"
          if (inputs_disabled())
            shinyjs::disabled(provide_selectize(tag_id, label, ""))
          else
            provide_selectize(
              tag_id,
              label,
              setdiff(colnames(data()), input$outcome_var),
              "group"
            )
        }
      )

      output$time <- renderUI(
        {
          tag_id <- ns("time_var")
          label <- "Time Factor"
          if (inputs_disabled())
            shinyjs::disabled(provide_selectize(tag_id, label, ""))
          else
            provide_selectize(
              tag_id,
              label,
              setdiff(colnames(data()), c(input$outcome_var, input$group_var)),
              "time"
            )
        }
      )

      output$subject <- renderUI(
        {
          tag_id <- ns("subject")
          label <- "Subject"
          if (inputs_disabled())
            shinyjs::disabled(provide_selectize(tag_id, label, ""))
          else
            provide_selectize(
              tag_id,
              label,
              setdiff(
                colnames(data()),
                c(input$outcome_var, input$group_var, input$time_var)),
              c("subject", "id")
            )
        }
      )
    }
  )
}


nparLDComputeServer <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {

      observeEvent(
        input$action,
        { 
          out <- tryCatch(
            { 
              form <- as.formula(
                paste(
                  input$outcome_var,
                  paste(
                    input$group_var,
                    input$time_var,
                    sep="*"
                  ),
                  sep="~"
                )
              )
              nparLD::nparLD(
                form,
                data(),
                input$subject_var,
                description=FALSE,
                order.warning=FALSE,
                alpha=input$alpha
              )
            },
            error=function(e) {
              shinyjs::alert(
                paste("nparLD error:", e$message)
              )
              return(NULL)
            }
          )
          out
        }
      )
    }
  )
}


nparLDOutputServer <- function(id, nparLD_out) {
  moduleServer(
    id,
    function(input, output, session) {

      ns <- session$ns

      output$rte <- renderUI(
        {
          if (is.null(nparLD_out()))
            tags$div(id="rte_placeholder")  # is this necessary?
          else {
            output$rte_plot <- renderPlot(
              {
                nparLD::plot.nparLD(nparLD_out())
              }
            )
            plotOutput(ns("rte"))
          }
        }
      )

      output$table <- renderUI(
        {
          if (is.null(nparLD_out()))
            tags$div(id="table_placeholder")
          else {
            output$table_content <- renderTable(
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
              tableOutput(ns("table"))
            )
          }
        }
      )
    }
  )
}


# invoke server
inputs_disabled <- reactive(
  {
    is.null(data())
  }
)
nparLD_out <- reactiveVal(NULL)
nparLDInputServer("nparLD", inputs_disabled)
nparLD_out(nparLDComputeServer("nparLD"))
nparLDOutputServer("nparLD", nparLD_out)
