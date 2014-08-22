# Load packages
library(dplyr)

# Load workspaces
load("Workspaces/prepared_data.RData")
load("Workspaces/gbm_model.RData")

# Load function to visualize data
source("Scripts/Visualize/rchart_visualize.R")

# Prepare game info for shiny
source("Scripts/Prepare_Data/prepare_games_for_shiny.R")