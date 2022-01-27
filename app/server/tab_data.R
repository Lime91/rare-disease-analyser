
output$dataset <- DT::renderDataTable(
  {
    req(input$file)
    read.delim(
      input$file$datapath,
      header=T,
      sep=input$data_sep,
      dec=input$data_dec
    )
  }
)