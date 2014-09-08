# Load packages
library(dplyr)

# Prepare rows for dropdowns and game info
seasons <- all.game.info %>% group_by(season) %>% summarize(season.string=sprintf("Season %d (%d-%d)", season, year(min(date)), year(max(date))))
game.info <- all.game.info %>%
  mutate(game.strings=sprintf("%s%s vs. %s vs. %s (%s)", ifelse(tournament, "*", ""), left.contestant, center.contestant, right.contestant, date),
         contestant.strings=sprintf("%s vs. %s vs. %s", left.contestant, center.contestant, right.contestant),
         num.and.date=sprintf("Game #%d, aired %s", episode.id, gsub(" 0", " ", format(date, format="%B %d, %Y"))),
         tournament.game=ifelse(tournament, gsub("\\..*", "", as.character(notes)), ""),
         disclaimer=ifelse(tournament, "(Note: Odds estimates of tournament games are unreliable, see About tab for more)", "")) %>%
  select(season, j.archive.id, game.strings, contestant.strings, tournament.game, disclaimer, num.and.date, left.contestant, center.contestant, right.contestant)

# Merge odds with data
source("scripts/build_models/merge_preds.R")
game.odds <- mergePredsWithData(gbm.preds.all, all.game.points, game.results)