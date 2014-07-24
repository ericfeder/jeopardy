# Load packages
library(rpart)

# Fit random forest
library(randomForest)
rf <- randomForest(factor(winner.rank) ~ middle.diff + middle.ratio + bottom.diff + bottom.ratio + money.left + dd.remaining, data=games.rbind, subset=round != "FinalJeopardy", do.trace=2, ntree=100, na.action=na.omit)

# Predict
preds <- predict(rf, subset(games.rbind, round != "FinalJeopardy"), type="prob")
games.odds <- data.frame(subset(games.rbind, round != "FinalJeopardy"), preds)