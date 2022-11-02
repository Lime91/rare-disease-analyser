
tabPanel(
  "Upload Data",
  fluidRow(
    column(
      width=6,  # outer column to fit wellPanel and inner row/cols
      offset=3,
      wellPanel(
        fluidRow(column(width=12, tags$h3("Data Upload"), tags$br())),
        fluidRow(
          column(
            width=4,
            fileInput(
              "file",
              "Choose a File",
              multiple=F,
              accept=c("text/plain", "text/csv")
            )
          ),
          column(
            width=4,
            radioButtons(
              "data_sep",
              "Data Separator",
              choices=list(
                Comma=",",
                Semicolon=";",
                Tab="\t"
              ),
              selected=","
            )
          ),
          column(
            width=4,
            radioButtons(
              "data_dec",
              "Decimal Separator",
              choices=list(
                Dot=".",
                Comma=","
              ),
              selected="."
            )
          )
        ),
        tags$hr(),
        fluidRow(column(width=12, tags$h3("Variable Selection"), tags$br())),
        fluidRow(
          column(
            width=3,
            uiOutput("outcome")
          ),
          column(
            width=3,
            uiOutput("group")
          ),
          column(
            width=3,
            uiOutput("time")
          ),
          column(
            width=3,
            uiOutput("subject")
          )
        )
      )
    )
  ),
  fluidRow(
    column(
      width=8,
      offset=2,
      DT::dataTableOutput(
        "dataset"
      )
    )
  )
)
