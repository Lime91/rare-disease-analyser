
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



output$dataset <- DT::renderDataTable(
  { 
    data()
  }
)