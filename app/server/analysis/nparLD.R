
################################
#### LIBRARY CODE
################################


render_nparLD_plot <- function(nparLD_output) {
  renderPlot(
    {
      nparLD::plot.nparLD(nparLD_output)
    }
  )
}


render_nparLD_table <- function(nparLD_output) {
  renderTable(
    {
      t <- data.frame(nparLD_output$ANOVA.test)
      t$df <- as.integer(t$df)  # cast degrees of freedom to integer
      return(t)
    },
    rownames=TRUE,
    colnames=TRUE,
    align="r",
    digits=4
  )
}


render_nparLD_single_period <- function(plot_id, table_id) {
  fluidRow(
    column(
      width=8,
      plotOutput(plot_id)
    ),
    column(
      width=4,
      tags$div(
        tags$div(
          tags$br(),
          tags$h4(
            "ANOVA-Type Statistic",
            style="font-weight:bold;"
          ),
          tags$br(),
          tableOutput(table_id)
        ),
        style="float:right;"
      )
    )
  )
}


render_nparLD_cross_over <- function(
    name_1,
    name_2,
    plot_id_1,
    plot_id_2,
    table_id_1,
    table_id_2) {

  tags$div(
    fluidRow(column(
      width=12,
      tags$h3(paste0("Period '", name_1, "'")))
    ),
    render_nparLD_single_period(plot_id_1, table_id_1),
    fluidRow(column(
      width=12,
      tags$hr())
    ),
    fluidRow(column(
      width=12,
      tags$h3(paste0("Period '", name_2, "'")))
    ),
    render_nparLD_single_period(plot_id_2, table_id_2)
  )
}


computeNparLD <- function(shiny_input, period_data) {
  tryCatch(
    {
      form <- as.formula(
        paste(
          shiny_input$outcome_var,
          paste(
            shiny_input$group_var,
            shiny_input$time_var,
            sep="*"
          ),
          sep="~"
        )
      )
      period_data <- period_data[
        order(
          period_data[[shiny_input$subject_var]],
          period_data[[shiny_input$time_var]]
        ),
      ]
      nparLD::nparLD(
        form,
        period_data,
        shiny_input$subject_var,
        description=FALSE,
        order.warning=FALSE,
        alpha=0.05  # this option is broken
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


splitDataset <- function(shiny_input, full_data) {
  tryCatch(
    {
      period_column <- full_data[[shiny_input$nparLD_period_var]]
      n_periods <- length(unique(period_column))
      if (n_periods != 2)
        stop(paste0(
          "Exactly two periods are required for cross over design. ",
          n_periods,
          " were found.")
        )
      period_1 <- unique(period_column)[1]
      period_2 <- unique(period_column)[2]
      l <- list(
        full_data[period_column == period_1, ],
        full_data[period_column == period_2, ]
      )
      names(l) <- paste0(c(period_1, period_2))
      l
    },
    error=function(e) {
      shinyjs::alert(
        paste("could not split data for periods:", e$message)
      )
      return(NULL)
    }
  )
}


check_for_na <- function(shiny_input, data) {
  na_cols <- character(0)
  if(sum(is.na(data[[shiny_input$group_var]])) > 0) {
    na_cols <- c(na_cols, shiny_input$group_var)
  }
  if(sum(is.na(data[[shiny_input$outcome_var]])) > 0) {
    na_cols <- c(na_cols, shiny_input$outcome_var)
  }
  if(sum(is.na(data[[shiny_input$time_var]])) > 0) {
    na_cols <- c(na_cols, shiny_input$time_var)
  }
  if(sum(is.na(data[[shiny_input$subject_var]])) > 0) {
    na_cols <- c(na_cols, shiny_input$subject_var)
  }
  if (shiny_input$nparLD_period_var %in% colnames(data)) {
    if(sum(is.na(data[[shiny_input$nparLD_period_var]])) > 0) {
      na_cols <- c(na_cols, shiny_input$nparLD_period_var)
    }
  }

  if (length(na_cols) > 0) {
    shinyjs::alert(
      paste(
        "Cannot compute nparLD as the following columns contain NA values:",
        paste(na_cols, collapse=", ")
      )
    )
    return(TRUE)
  } else {
    return(FALSE)
  } 
}


################################
#### SERVER LOGIC
################################


nparLD_out <- reactiveValues(
  cross_over=NULL,
  value_1=NULL,
  value_2=NULL,
  name_1=NULL,
  name_2=NULL
)


output$nparLD_period <- renderUI(
  {
    tag_id <- "nparLD_period_var"
    label <- "Period Variable"
    if (inputs_disabled())
      shinyjs::disabled(render_selectize(
        tag_id,
        label,
        "upload dataset!"))
    else if (input$nparLD_study_design == 1)
      shinyjs::disabled(render_selectize(
        tag_id, label, "only required in cross over design"))
    else
      render_selectize(
        tag_id,
        label,
        setdiff(
          colnames(data()),
          c(
            input$outcome_var,
            input$group_var,
            input$time_var,
            input$subject_var)),
        c("period")
      )
  }
)


observe(
  {
    if (!inputs_disabled()) {
      shinyjs::enable("nparLD_study_design")
      shinyjs::enable("nparLD_action")
    }
  }
)


observeEvent(
  input$nparLD_action,
  { 
    if(check_for_na(input, data())) {
      nparLD_out$value_1 <- NULL
      nparLD_out$value_2 <- NULL
      nparLD_out$name_1 <- NULL
      nparLD_out$name_2 <- NULL
    }
    else {
      if (input$nparLD_study_design == 1) {
        nparLD_out$cross_over <- FALSE
        nparLD_out$value_1 <- computeNparLD(input, data())
        nparLD_out$value_2 <- NULL
        nparLD_out$name_1 <- NULL
        nparLD_out$name_2 <- NULL
      } else {
        nparLD_out$cross_over <- TRUE
        data_split <- splitDataset(input, data())
        nparLD_out$value_1 <- computeNparLD(input, data_split[[1]])
        nparLD_out$value_2 <- computeNparLD(input, data_split[[2]])
        nparLD_out$name_1 <- names(data_split)[1]
        nparLD_out$name_2 <- names(data_split)[2]
      }
    }
  }
)


output$nparLD_out <- renderUI(
  {
    if (is.null(nparLD_out$cross_over))
      return(tags$div(id="nparLD_out_placeholder"))
    else if (nparLD_out$cross_over) {  # cross over

      if (is.null(nparLD_out$value_1) || is.null(nparLD_out$value_2))
        return(tags$div(id="nparLD_out_placeholder"))

      # period 1 renderings
      output$nparLD_rte_plot_1 <- render_nparLD_plot(nparLD_out$value_1)
      output$nparLD_table_content_1 <- render_nparLD_table(nparLD_out$value_1)

      # period 2 renderings
      output$nparLD_rte_plot_2 <- render_nparLD_plot(nparLD_out$value_2)
      output$nparLD_table_content_2 <- render_nparLD_table(nparLD_out$value_2)
      
      # ui
      render_nparLD_cross_over(
        nparLD_out$name_1,
        nparLD_out$name_2,
        "nparLD_rte_plot_1",
        "nparLD_rte_plot_2",
        "nparLD_table_content_1",
        "nparLD_table_content_2"
      )

    } else {  # single period

      if (is.null(nparLD_out$value_1))
        return(tags$div(id="nparLD_out_placeholder"))

      output$nparLD_rte_plot <- render_nparLD_plot(nparLD_out$value_1)
      output$nparLD_table_content <- render_nparLD_table(nparLD_out$value_1)
      render_nparLD_single_period(
        "nparLD_rte_plot",
        "nparLD_table_content"
      )
    }
  }
)
