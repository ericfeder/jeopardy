# Load workspaces
load("Workspaces/prepared_data.RData")
load("Workspaces/gbm_model.RData")

# Load functions to visualize data
source("Scripts/Visualize/visualize_game.R")
source("Scripts/Visualize/visualize_odds.R")

# Prepare game info for shiny
source("shiny/prepare_game_info.R")