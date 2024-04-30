
################################
#### LIBRARY CODE
################################


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


render_selectize <- function(
  tag_id, label, choices, prioritzed_terms="") {
    choices <- sort_choices(choices, prioritzed_terms)
    selectizeInput(tag_id, label=label, choices=choices)
}


################################
#### SERVER LOGIC
################################


data <- reactive(
  {
    if (is.null(input$file)) {
      return(NULL)
    } else {
      return(
        read.delim(
          input$file$datapath,
          header=TRUE,
          sep=input$data_sep,
          dec=input$data_dec
        )
      )
    }
  }
)


inputs_disabled <- reactive(
  {
    is.null(data())
  }
)


output$outcome <- renderUI(
  { 
    tag_id <- "outcome_var"
    label <- "Outcome"
    if (inputs_disabled())
      shinyjs::disabled(render_selectize(
        tag_id, label, "upload dataset!")
      )
    else
      render_selectize(
        tag_id, label, colnames(data()), c("value", "count", "outcome")
      )
  }
)


output$group <- renderUI(
  {
    tag_id <- "group_var"
    label <- "Group Factor"
    if (inputs_disabled())
      shinyjs::disabled(render_selectize(tag_id, label, ""))
    else
      render_selectize(
        tag_id,
        label,
        setdiff(colnames(data()), input$nparLD_outcome_var),
        "group"
      )
  }
)


output$time <- renderUI(
  {
    tag_id <- "time_var"
    label <- "Time Factor"
    if (inputs_disabled())
      shinyjs::disabled(render_selectize(tag_id, label, ""))
    else
      render_selectize(
        tag_id,
        label,
        setdiff(
          colnames(data()),
          c(input$nparLD_outcome_var, input$nparLD_group_var)),
        "time"
      )
  }
)


output$subject <- renderUI(
  {
    tag_id <- "subject_var"
    label <- "Subject"
    if (inputs_disabled())
      shinyjs::disabled(render_selectize(tag_id, label, ""))
    else
      render_selectize(
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


output$dataset <- DT::renderDataTable(
  { 
    data()
  },
  options=list(
    pageLength=50
  )
)
