# Load packages
library(dplyr)
library(data.table)

# Prepare rows for dropdowns and game info
seasons <- all.game.info %>% group_by(season) %>% summarize(season.string=sprintf("Season %d (%d-%d)", season, year(min(date)), year(max(date))))
game.info <- all.game.info %>%
  mutate(game.strings=sprintf("%s%s vs. %s vs. %s (%s)", ifelse(tournament, "*", ""), left.contestant, center.contestant, right.contestant, date),
         num.and.date=sprintf("Game #%d, aired %s", episode.id, gsub(" 0", " ", format(date, format="%B %d, %Y"))),
         tournament.game=ifelse(tournament, gsub("\\..*", "", as.character(notes)), "")) %>%
  select(season, j.archive.id, game.strings, tournament.game, num.and.date, left.contestant, center.contestant, right.contestant)

# Merge odds with data
source("scripts/build_models/merge_preds.R")
game.odds <- mergePredsWithData(gbm.preds.all, all.game.points, game.results)