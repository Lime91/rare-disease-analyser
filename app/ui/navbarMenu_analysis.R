
navbarMenu(
  "Statistical Analysis",
  source(file.path("analysis", "tabPanel_nparLD.R"), local=T, chdir=T)$value,
  source(file.path("analysis", "tabPanel_gpc.R"), local=T, chdir=T)$value
)