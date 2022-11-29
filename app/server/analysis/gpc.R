
################################
#### LIBRARY CODE
################################


create_buyse_args <- function(shiny_input) {
  
  # create vector of endpoint names in prioritization order
  endpoint=character()
  order_values <- unlist(strsplit(
      shiny_input$gpc_prio_order_values,
      ", "
    )
  )
  n_ep <- length(order_values)
  for (v in order_values) {
    e <- paste(shiny_input$outcome_var, v, sep=".")  # tailored to R's reshape()
    endpoint <- c(endpoint, e)
  }

  # create lower/higher operator
  if (shiny_input$gpc_best == 1)  # lower values preferred
    operator <- rep("<0", n_ep)
  else # higher values preferred
    operator <- rep(">0", n_ep)
  
  # create alternative hypothesis
  if (shiny_input$gpc_side == 1)  # one-sided test
    if (shiny_input$gpc_best == 1)
      alternative <- "less"
    else
      alternative <- "greater"
  else  # two-sided test
    alternative <- "two.sided"
  
  # currently, only continuous types are supported
  type <- rep("c", n_ep) 
  
  # prioritized vs. non-prioritized gpc
  if (shiny_input$gpc_prio == 1)  # non-prioritized unmatched gpc
    hierarchical <- FALSE
  else  # prioritized unmatched gpc
    hierarchical <- TRUE
  
  list(
    "endpoint"=endpoint,
    "operator"=operator,
    "alternative"=alternative,
    "type"=type,
    "hierarchical"=hierarchical
  )
}


get_wide_data <- function(shiny_input, long_data) {
  df <- subset(
    long_data,
    select=c(
      shiny_input$outcome_var,
      shiny_input$group_var,
      shiny_input$time_var,
      shiny_input$subject_var
    )
  )
  reshape(
    df,
    timevar=shiny_input$time_var,
    idvar=c(shiny_input$subject_var, shiny_input$group_var),
    direction="wide"
  )
}


perform_buyse_test <- function(wide_data, group_var, args) {
  set.seed(1)
  rep.m <- length(args$endpoint)

  gpc_p <- BuyseTest::BuyseTest(
    data=wide_data,
    treatment=group_var,
    endpoint=args$endpoint,
    operator=args$operator,
    type=args$type,
    hierarchical=args$hierarchical,
    method.inference="permutation",
    n.resampling = 1e4
  )
  gpc_summary <- summary(
    gpc_p,
    percentage=FALSE
  )
  gpc_est <- gpc_summary$table.print

  gpc_b <- BuyseTest::BuyseTest(
    data=wide_data,
    treatment=group_var,
    endpoint=args$endpoint,
    operator=args$operator,
    type=args$type,
    hierarchical=args$hierarchical,
    method.inference="bootstrap",
    n.resampling = 1e4
  )
  gpc_ci <- BuyseTest::confint(
    gpc_b,
    alternative=args$alternative
  )

  gpc_est$neutral <- gpc_est$neutral + gpc_est$uninf
  gpc_final <- rbind(
    gpc_est[, -c(2, 6, 8, 10)],
    c(
      "Total",
      sum(gpc_est$favorable),
      sum(gpc_est$unfavorable),
      sum(gpc_est$neutral),
      paste0(
        sum(gpc_est$delta),
        " (",
        round(gpc_ci$lower.ci[rep.m], 4),
        "; ", 
        round(gpc_ci$upper.ci[rep.m], 4),
        ")"
      ),
      gpc_est$p.value[rep.m]
    )
  )
  gpc_final$p.value <- ifelse(
    gpc_final$endpoint == "Total", gpc_final$p.value, "")

  return(gpc_final)
}


################################
#### SERVER LOGIC
################################


gpc_out <- reactiveValues(
  table=NULL
)



output$gpc_prio_order <- renderUI(
  {
    tag_id <- "gpc_prio_order_values"
    label <- "Priorization Order"
    if (inputs_disabled())
      shinyjs::disabled(
        textInput(
          tag_id,
          label,
          "upload dataset!"
        )
      )
    else if (input$gpc_prio == 1)
      shinyjs::disabled(
        textInput(
          tag_id,
          label,
          value=paste0(
            unique(data()[[input$time_var]]),
            collapse=", ")
        )
      )
    else
      textInput(
        tag_id,
        label,
        value=paste0(
          unique(data()[[input$time_var]]),
          collapse=", ")
      )
  }
)


observe(
  {
    if (!inputs_disabled()) {
      shinyjs::enable("gpc_prio")
      shinyjs::enable("gpc_side")
      shinyjs::enable("gpc_best")
      shinyjs::enable("gpc_action")
    }
  }
)


observeEvent(
  input$gpc_action,
  { 
    gpc_args <- create_buyse_args(input)
    print(gpc_args)
    gpc_df <- get_wide_data(input, data())
    gpc_table <- perform_buyse_test(gpc_df, input$group_var, gpc_args)
    gpc_out$table <- gpc_table
  }
)


output$gpc_out <- renderUI(
  {
    if (is.null(gpc_out$table))
      tags$div(id="gpc_out_placeholder")
    else  {
      tags$div(
        fluidRow(column(
          width=12,
          tags$h3("Results"))
        ),
        tags$hr(),
        fluidRow(column(
          width=12,
          renderTable(
            {
              data.frame(gpc_out$table)
            },
            rownames=FALSE,
            colnames=TRUE,
            align="r",
            digits=4
          )
        ))
      )
    }
  }
)
