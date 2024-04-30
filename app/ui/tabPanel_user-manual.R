tabPanel(
  "Start",
  fluidRow(
    column(
      width=6,
      offset=3,
      tags$h2("Welcome to the Rare Disease Analyser"),
      tags$br(),
      tags$div(
        tags$h3("Getting Started"),
        "Download the ",
        tags$a("user manual", href="RDA User Manual.pdf", target="_blank"),
        " to learn how to use this webapp. You can also use an ",
        tags$a("example dataset", href="diacerein.csv", target="_blank"),
        "to get started.",
        tags$br(),
        "If you are ready, upload your dataset and choose an analysis method.",
        tags$br(),
        "Happy analysing 😀"
      ),
      tags$br(),
      tags$div(
        tags$h3("Disclaimer"),
        "This is an R-shiny webapp. It was developed in the EBStatMax research 
        project, funded by the European Joint Program on Rare Diseases.",
        tags$br(),
        "The app comes with absolutely no warranty. Please be careful when 
        uploading sensitive data.",
        tags$br(),
        "Feel free to host the app yourself. Source code is available ",
        tags$a(
          "here.",
          href="https://github.com/Lime91/rare-disease-analyser",
          target="_blank"
        ),
      ),
      tags$br(),
      tags$div(
        tags$h3("Contributors"),
        "Main developer: Konstantin Emil Thiel",
        tags$br(),
        "GPC Expert: Johan Verbeeck",
        tags$br(),
        tags$h4("EBStatMax Project Team"),
        "PMU Salzburg (Dermatology): Johan Bauer, Martin Laimer, 
        Verena Wally",
        tags$br(),
        "PMU Salzburg (Statistics): Martin Geroldinger, 
        Konstantin Emil Thiel, Georg Zimmermann",
        tags$br(),
        "Paris Lodron University Salzburg: Arne C. Bathke",
        tags$br(),
        "Hasselt University & KU Leuven​: Geert Molenberghs, Johan Verbeeck",
        tags$br(),
        "Uppsala University: Andrew C. Hooker, Mats Karlsson, 
        Joakim Nyberg, Sebastian Ueckert"
      )
    )
  )
)
