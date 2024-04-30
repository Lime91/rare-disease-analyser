
################################
#### LIBRARY CODE
################################


create_buyse_args <- function(shiny_input) {
  
  # create vector of endpoint names in prioritization order
  endpoint=character()
  order_values <- trimws(
    unlist(
      strsplit(
        shiny_input$gpc_prio_order_values,
        ","
      )
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


build_group_factor <- function(shiny_input, group_values) {
  ugroup <- unique(group_values)
  # weirdly, shiny_input$gpc_treatment_group_label selection becomes a character
  verum_label <- ugroup[[as.integer(shiny_input$gpc_treatment_group_label)]]
  control_label <- setdiff(ugroup, verum_label)
  factor(
    group_values,
    levels=c(
      control_label,
      verum_label
    )
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
  wide_df <- reshape(
    df,
    timevar=shiny_input$time_var,
    idvar=c(shiny_input$subject_var, shiny_input$group_var),
    direction="wide"
  )
  # BuyseTest doesn't say how to tell the treatment group label
  # apparently, one needs a factor with sorted labels to specify this
  group_values <- wide_df[[shiny_input$group_var]]
  group_factor <- build_group_factor(shiny_input, group_values)
  wide_df[[shiny_input$group_var]] <- group_factor
  wide_df
}


assemble_summary <- function(raw_summary, hierarchical) {
  title <- trimws(raw_summary[1])
  body <- list()
  body[[1]] <- strsplit(raw_summary[8], "- ")[[1]][2]  # treatment groups
  # BuyseTest output seems to be broken and doesn't yield the following:
  if (hierarchical)
    body[[2]] <- "neutral pairs are re-analyzed using lower priority endpoints"
  else
    body[[2]] <- "all pairs are compared for all endpoints (full GPC)"
  body[[3]] <- 
  "p-value computed using the permutation distribution (10.000 permutations)"
  body[[4]] <- "confidence interval based on asymptotic distribution"
  list("title"=title, "body"=body)
}


perform_buyse_test <- function(wide_data, group_var, args) {
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
        n.resampling=1e4
      )
    }
  ))
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
  summary_text <- capture.output(
    {
      gpc_summary <- summary(
        gpc_p,
        percentage=FALSE
      )
    }
  )
  header_list <- assemble_summary(summary_text, args$hierarchical)
  gpc_est <- gpc_summary$table.print
  gpc_ci <- BuyseTest::confint(gpc_u)
  gpc_est$neutral <- gpc_est$neutral + gpc_est$uninf
  gpc_est <- gpc_est[, c(
    "endpoint", "favorable", "unfavorable", "neutral", "delta", "p.value"
  )
  ]
  gpc_final <- rbind(
    gpc_est,
    c(
      "Total",
      sum(gpc_est$favorable),
      sum(gpc_est$unfavorable),
      sum(gpc_est$neutral),
      paste0(
        round(gpc_ci$estimate[n], 4),
        " [",
        round(gpc_ci$lower.ci[n], 4),
        ", ", 
        round(gpc_ci$upper.ci[n], 4),
        "]"
      ),
      gpc_est$p.value[n]
    )
  )
  if (args$hierarchical) {  # special cell value for prioritised GPC
    gpc_final[n + 1, "neutral"] <- gpc_final[n, "neutral"]
  } 
  gpc_final$p.value <- ifelse(
    gpc_final$endpoint == "Total",
    round(as.numeric(gpc_final$p.value), 4),
    ""
  )
  list(
    "headers"=header_list,
    "table"=gpc_final
  )
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
    label <- "Prioritisation Order"
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


output$gpc_treatment_group <- renderUI(
  {
    tag_id <- "gpc_treatment_group_label"
    label <- "Treatment Group Label"
    if (inputs_disabled()) {
      shinyjs::disabled(
        radioButtons(
          tag_id,
          label,
          choices=list(
            "  "=1,
            " "=2
          ),
          selected=1,
          inline=FALSE
        )
      )
    } else {
      group_labels <- unique(data()[[input$group_var]])
      if (length(group_labels) != 2) {
        shinyjs::disable("gpc_action")
        message <- paste0(
          "There must be exactly 2 group labels, but the variable '",
          input$group_var,
          "' contains ",
          length(group_labels),
          ": ",
          paste(
            group_labels,
            collapse=", "
          ),
        )
        shinyjs::alert(
          paste("Input data error:", message)
        )
        shinyjs::disabled(
          radioButtons(
            tag_id,
            label,
            choices=list(
              "  "=1,
              " "=2
            ),
            selected=1,
            inline=FALSE
          )
        )
      } else {
        shinyjs::enable("gpc_action")
        choices_list <- list(1, 2)
        names(choices_list) <- group_labels
        radioButtons(
          tag_id,
          label,
          choices=choices_list,
          selected=1,
          inline=FALSE
        )
      }
    }
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
          tags$div(
            tags$ul(
              tags$li(gpc_out$headers$body[[1]]),
              tags$li(gpc_out$headers$body[[2]]),
              tags$li(gpc_out$headers$body[[3]]),
              tags$li(gpc_out$headers$body[[4]]),
            )
          )
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
