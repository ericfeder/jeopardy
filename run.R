# Load packages
library(data.table)
library(rpart)

# Download games
ids <- 4450:4459
games.raw <- lapply(ids, downloadGame)

# Analyze games
games <- mapply(FUN=processGame, games.raw, ids, SIMPLIFY=F)

# Combine games into one data frame
games.rbind <- rbindlist(games)

# Fit random forest
library(randomForest)
rf <- randomForest(factor(winner.rank) ~ middle.diff + middle.ratio + bottom.diff + bottom.ratio + money.left + dd.remaining, data=games.rbind, subset=round != "FinalJeopardy", do.trace=2, ntree=100, na.action=na.omit)

# Predict
preds <- predict(rf, subset(games.rbind, round != "FinalJeopardy"), type="prob")
games.odds <- data.frame(subset(games.rbind, round != "FinalJeopardy"), preds)