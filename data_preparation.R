# Load packages
library(data.table)

# Download seasons
season.nums <- 1:30
game.info <- lapply(season.nums, downloadSeason)
game.info.rbind <- rbindlist(game.info)

# Add game info
all.game.info <- game.info.rbind[order(date), ]
all.game.info <- addInfo(all.game.info)

# Download games
ids <- all.game.info[values.doubled & !tournament, j.archive.id]
games.raw <- lapply(ids, downloadGame)

# Analyze games
games <- mapply(FUN=processGame, games.raw, ids, SIMPLIFY=F)

# Combine games into one data frame
games.rbind <- rbindlist(games)