# Load packages
library(dplyr)

# Prepare rows for dropdowns and game info
seasons <- all.game.info %>% group_by(season) %>% summarize(season.string=sprintf("Season %d (%d-%d)", season, year(min(date)), year(max(date))))
game.info <- all.game.info %>%
  mutate(game.strings=sprintf("%s%s vs. %s vs. %s (%s)", ifelse(tournament, "*", ""), left.contestant, center.contestant, right.contestant, date),
         tournament.game=ifelse(tournament, gsub("\\..*", "", as.character(notes)), ""),
         disclaimer=ifelse(tournament, "(Note: Odds Estimates of tournament games are less reliable, see About tab for more)", "")) %>%
  select(season, j.archive.id, game.strings, tournament.game, disclaimer, left.contestant, center.contestant, right.contestant)

# Merge odds with data
source("Scripts/Models/merge_preds.R")
game.odds <- mergePredsWithData(gbm.preds.all, all.game.points, game.results)