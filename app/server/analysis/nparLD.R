
output$nparLD_outcome <- renderUI(
  {
    if (is.null(input$file))
      choices="please upload dataset!"
    else
      choices=colnames(dataset())
    
    selectizeInput(
      "nparLD_outcome",
      label="Select Outcome Variable",
      choices=choices
    )
  }
)