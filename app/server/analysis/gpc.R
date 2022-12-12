
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


assemble_summary <- function(raw_summary) {
  title <- trimws(raw_summary[1])
  body <- strsplit(raw_summary[8], "- ")[[1]][2]
  list("title"=title, "body"=body)
}


perform_buyse_test <- function(wide_data, group_var, args) {
  set.seed(1)
  n <- length(args$endpoint)

  invisible(capture.output(
    {
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
    }
  ))

  summary_text <- capture.output(
    {
      gpc_summary <- summary(
        gpc_p,
        percentage=FALSE
      )
    }
  )
  header_list <- assemble_summary(summary_text)

  gpc_est <- gpc_summary$table.print

  invisible(capture.output(
    {
      gpc_u <- BuyseTest::BuyseTest(
        data=wide_data,
        treatment=group_var,
        endpoint=args$endpoint,
        operator=args$operator,
        type=args$type,
        hierarchical=args$hierarchical,
        method.inference="u-statistic"
      )
    }
  ))
  
  gpc_ci <- BuyseTest::confint(gpc_u)

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
        round(gpc_ci$lower.ci[n], 4),
        "; ", 
        round(gpc_ci$upper.ci[n], 4),
        ")"
      ),
      gpc_est$p.value[n]
    )
  )
  gpc_final$p.value <- ifelse(
    gpc_final$endpoint == "Total", gpc_final$p.value, "")

  return(list(
    "headers"=header_list,
    "table"=gpc_final
  ))
}


################################
#### SERVER LOGIC
################################


gpc_out <- reactiveValues(
  headers=NULL,
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
      shinyjs::enable("gpc_best")
      shinyjs::enable("gpc_action")
    }
  }
)


observeEvent(
  input$gpc_action,
  { 
    tryCatch(
      {
        gpc_args <- create_buyse_args(input)
        gpc_df <- get_wide_data(input, data())
        l <- perform_buyse_test(gpc_df, input$group_var, gpc_args)
        gpc_out$headers <- l$headers
        gpc_out$table <- l$table
      },
      error=function(e) {
        shinyjs::alert(
          paste("GPC error:", e$message)
        )
        return(NULL)
      }
    )
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
          tags$h3(gpc_out$headers$title)),
          tags$p(
            gpc_out$headers$body,
            style="margin-left:1.1em;")
        ),
        tags$hr(),
        fluidRow(column(
          width=10,
          offset=1,
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
