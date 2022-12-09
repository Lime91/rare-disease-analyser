# This script is a playground mimicking the backend of the Rare Disease 
# Analyser webapp: https://github.com/Lime91/rare-disease-analyser
# 
# The script provides two main variables to work with:
#   - data
#   - input
# In the real shiny webapp, data is a read-only reactive value, which is called
# with brackets as follows: data(). The present implementation solely mimics 
# this behavior.
#
# Goal: implement the two relevant GPC versions such that they work with all 
# possible user parameters specified in the 'inputs' variable.


########################################
# dataset
########################################
FILENAME <- "diacerein_study__period_1.csv"  # single period
# FILENAME <- "diacerein_study__harmonized_time.csv"  # cross over
DF <- read.delim(FILENAME, header=T, sep=",", dec=".")
data <- function() {DF}
data()  # mimic reactive value from shiny app


########################################
# user inputs, provided by shiny app
########################################
input <- list(
  
  # variable names
  outcome_var="Pruritus",
  group_var="Group",
  time_var="Time",
  subject_var="Id",
  period_var="period",  # only relevant for cross over design
  
  # single period trial or cross over trial
  study_design=1,  # 1: single period, 2: cross over
  
  # GPC options
  gpc_variant=2,  # 1: prioritized unmatched, 2: non-prioritized unmatched
  gpc_prio_order_values=c(4, 7, 2, 0),  # any permutation of unique time points is allowed
  gpc_side=2,  # 1: one-sided, 2: two-sided
  gpc_best=1  # 1: lower, 2: higher
)


########################################
# development zone below
########################################


create_buyse_args <- function(input) {
  
  # create vector of endpoint names in prioritization order
  endpoints=character()
  for (i in input$gpc_prio_order_values) {
    e <- paste(input$outcome_var, i, sep=".")  # tailored to R's reshape()
    endpoints <- c(endpoints, e)
  }
  
  # create lower/higher operator
  n_ep <- length(input$gpc_prio_order_values)
  if (input$gpc_best == 1)  # lower values preferred
    operator <- rep("<0", n_ep)
  else # higher values preferred
    operator <- rep(">0", n_ep)
  
  # create alternative hypothesis
  if (input$gpc_side == 1)  # one-sided test
    if (input$gpc_best == 1)
      alternative <- "less"
    else
      alternative <- "greater"
  else  # two-sided test
    alternative <- "two.sided"
  
  # currently, only continuous types are supported
  type <- rep("c", n_ep) 
  
  # prioritized vs. non-prioritized gpc
  if (input$gpc_variant == 1)  # prioritized unmatched gpc
    hierarchical <- TRUE
  else  # non-prioritized unmatched gpc
    hierarchical <- FALSE
  
  list(
    "endpoints"=endpoints,
    "operator"=operator,
    "alternative"=alternative,
    "type"=type,
    "hierarchical"=hierarchical
  )
}

# what the above function produces
args <- create_buyse_args(input)
print(args)


# reshape data
df <- subset(
  data(),
  select=c(input$outcome_var, input$group_var, input$time_var, input$subject_var)
)
wide <- reshape(
  df,
  timevar=input$time_var,
  idvar=c(input$subject_var, input$group_var),
  direction="wide"
)


# start GPC computations
# require(BuyseTest)

rep.m <- length(unique(data()[[input$time_var]]))
set.seed(1)
gpc_p <- BuyseTest::BuyseTest(
  data=wide,
  treatment=input$group_var,
  endpoint=args$endpoint,
  operator=args$operator,
  type=args$type,
  hierarchical=args$hierarchical,
  method.inference="permutation",
  n.resampling = 1e5
)
gpc_summary <- summary(
  gpc_p,
  percentage=FALSE
)
gpc_est <- gpc_summary$table.print

set.seed(1)
gpc_b <- BuyseTest::BuyseTest(
  data=wide,
  treatment=input$group_var,
  endpoint=args$endpoint,
  operator=args$operator,
  type=args$type,
  hierarchical=args$hierarchical,
  method.inference="bootstrap",
  n.resampling = 1e5
)
gpc_ci <- BuyseTest::confint(
  gpc_b,
  alternative=args$alternative
)

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
      round(gpc_ci$lower.ci[rep.m], 4),
      ";", 
      round(gpc_ci$upper.ci[rep.m], 4),
      ")"
    ),
    gpc_est$p.value[rep.m]
  )
)
gpc_final$p.value <- ifelse(
  gpc_final$endpoint == "Total", gpc_final$p.value, "")
print(gpc_final)
