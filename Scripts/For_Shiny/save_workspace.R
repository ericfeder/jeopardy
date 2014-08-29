# Load workspaces
load("Workspaces/prepared_data.RData")
load("Workspaces/gbm_model.RData")

# Load functions to visualize data
source("Scripts/Visualize/visualize_game.R")
source("Scripts/Visualize/visualize_odds.R")

# Prepare game info for shiny
source("Scripts/For_Shiny/prepare_game_info.R")

# Save workspace for shiny
save(all.game.info, game.info, seasons, gbm.model, game.odds.split, file="shiny/shiny_workspace.RData")