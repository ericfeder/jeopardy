# Load packages
library(randomForest)
library(data.table)

# Fit random forest
rf <- randomForest(factor(winner.rank) ~ middle.diff + middle.ratio + bottom.diff + bottom.ratio + money.left + dd.remaining, data=usable.points, do.trace=2, ntree=100)

# Predict
preds <- predict(rf, usable.points, type="prob")
games.odds <- data.frame(usable.points, preds)