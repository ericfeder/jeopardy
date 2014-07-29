# Load packages
library(data.table)

# Download seasons
source("Scripts/Prepare_Data/game_info.R")
season.nums <- 1:30
game.info <- lapply(season.nums, downloadSeason)
game.info.rbind <- rbindlist(game.info)
game.info.rbind <- game.info.rbind[order(date), ]

# Download games
source("Scripts/Prepare_Data/download_games.r")
games.raw <- lapply(game.info.rbind$j.archive.id, downloadGame)

# Save to workspace
save(games.raw, file="Workspaces/raw_games.RData")

# Analyze games
source("Scripts/Prepare_Data/process_games.R")
games <- lapply(games.raw, processGame)
games.rbind <- rbindlist(games[sapply(games, is.data.frame)])
setnames(games.rbind, 2:4, c("left", "center", "right"))

# Add game info
all.game.info <- addInfo(game.info.rbind)
returning.champion <- checkReturningChampion(sapply(games.raw, function(x) x$scores.raw$contestants_table$V2))
all.game.info$num.champs <- returning.champion$num.champs
all.game.info$champ.days <- returning.champion$days

# Extract game results
game.results <- games.rbind[round == "FinalJeopardy", list(j.archive.id, left, center, right, left.rank, center.rank, right.rank)]

# Subset data for model building
usable.j.archive.ids <- all.game.info[values.doubled & !tournament, j.archive.id]
usable.points <- games.rbind[round != "FinalJeopardy" & j.archive.id %in% usable.j.archive.ids]

# Save to workspace
save(games.rbind, all.game.info, game.results, usable.points, file="Workspaces/prepared_data.RData")