# Load packages
library(data.table)

# Download seasons
source("game_info.R")
season.nums <- 1:30
game.info <- lapply(season.nums, downloadSeason)
game.info.rbind <- rbindlist(game.info)
game.info.rbind <- game.info.rbind[order(date), ]

# Add game info
all.game.info <- addInfo(game.info.rbind)

# Download games
source("download_games.r")
ids <- all.game.info$j.archive.id
games.raw <- lapply(ids, downloadGame)

# Analyze games
source("process_games.R")
games <- mapply(FUN=processGame, games.raw, ids, SIMPLIFY=F)
games.rbind <- rbindlist(games[sapply(games, is.data.frame)])

# Check if returning champion
returning.champion <- checkReturningChampion(sapply(games.raw, function(x) x$scores.raw$contestants_table$V2))