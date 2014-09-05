# Load workspaces
load("Workspaces/prepared_data.RData")
load("Workspaces/gbm_model.RData")

# Shrink size of gbm.model
gbm.model[c("fit", "train.error", "valid.error", "oobag.improve", "estimator", "data")] <- NULL

# Prepare game info for shiny
source("Scripts/For_Shiny/prepare_game_info.R")

# Save workspace for shiny
save(game.info, seasons, gbm.model, game.odds, file="shiny/shiny_workspace.RData")