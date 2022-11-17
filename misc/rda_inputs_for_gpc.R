# This script is a playground mimicking the backend of the Rare Disease 
# Analyserwebapp: https://github.com/Lime91/rare-disease-analyser
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
FILENAME <- "diacerein_study__harmonized_time.csv"  # cross over
# FILENAME <- "diacerein_study__period_1.csv"  # single period
DF <- read.delim(FILENAME, header=T, sep=",", dec=".")
data <- function() {DF}
data()  # mimic reactive value from shiny app


########################################
# user inputs, provided by shiny 
########################################
input <- list(
  
  # variable names
  outcome_var="Blister_count",
  group_var="Group",
  time_var="Time",
  subject_var="Id",
  period_var="period",  # only relevant for cross over design
  
  # single period trial or cross over trial
  study_design=1,  # 1: single period, 2: cross over
  
  # GPC options
  gpc_variant=1,  # 1: prioritized unmatched, 2: non-prioritized unmatched
  gpc_prio_order_values=c(3, 4, 2, 1),  # any permutation of unique time points is allowed
  gpc_side=1,  # 1: one-sided, 2: two-sided
  gpc_best=1  # 1: lower, 2: higher
)


########################################
# development zone below
########################################




