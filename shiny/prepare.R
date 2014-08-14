# Load packages
library(dplyr)

# Load workspaces
load("Workspaces/prepared_data.RData")
load("Workspaces/gbm_model.RData")

# Load function to visualize data
source("Scripts/Visualize/rchart_visualize.R")

# Prepare rows for dropdowns
game.info <- all.game.info %>% mutate(game.strings=sprintf("%s vs. %s vs. %s (%s)", left.contestant, center.contestant, right.contestant, date)) %>% filter(tournament == F) %>% select(season, j.archive.id, game.strings)