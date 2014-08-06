# Load packages
library(data.table)

# Download seasons
source("Scripts/Prepare_Data/game_info.R")
season.nums <- 1:30
game.info <- lapply(season.nums, downloadSeason)
game.info.rbind <- rbindlist(game.info)
game.info.rbind <- game.info.rbind[order(date), ]

# Download games
source("Scripts/Prepare_Data/download_games.R")
games.raw <- lapply(game.info.rbind$j.archive.id, downloadGame)

# Save to workspace
save(games.raw, game.info.rbind, file="Workspaces/raw_games.RData")

# Add game info
source("Scripts/Prepare_Data/process_games.R")
source("Scripts/Prepare_Data/additional_game_info.R")
all.game.info <- addInfo(game.info.rbind)
returning.champion <- checkReturningChampion(sapply(games.raw, function(x) x$scores.raw$contestants_table$V2))
all.game.info$num.champs <- returning.champion$num.champs
all.game.info$champ.days <- returning.champion$days

# Analyze games
games <- mapply(FUN=processGame, games.raw, all.game.info$values.doubled, SIMPLIFY=F)
games.rbind <- rbindlist(games[sapply(games, is.data.frame)])
setnames(games.rbind, 2:4, c("left", "center", "right"))

# Extract game results
game.results <- games.rbind[round == "FinalJeopardy", list(j.archive.id, left, center, right)]
game.results <- data.table(game.results, t(apply(-game.results[, -1, with=F], 1, rank, ties.method="min")))
setnames(game.results, 5:7, c("left.rank", "center.rank", "right.rank"))

# Subset data for model building
usable.j.archive.ids <- all.game.info[tournament == F, j.archive.id]
usable.points <- games.rbind[round != "FinalJeopardy" & j.archive.id %in% usable.j.archive.ids & !is.na(winner.rank)]

# Save to workspace
save(games.rbind, all.game.info, game.results, usable.points, file="Workspaces/prepared_data.RData")