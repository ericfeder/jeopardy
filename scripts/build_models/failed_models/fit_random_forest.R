# Load packages
library(data.table)
library(randomForest)

# Fit random forest
rf.model <- randomForest(factor(winner.rank) ~ middle.diff.adj + middle.ratio + bottom.diff.adj + bottom.ratio + money.left.adj + dd.remaining, data=modeling.points, do.trace=2, ntree=200, sampsize=10)

# Predict
rf.model <- list(model=rf.model, preds=predict(rf.model, type="prob"))

# Evaluate calibration
source("Scripts/Models/evaluate_calibration.R")
with(modeling.points, evaluateModel(data.frame(top.score, middle.score, bottom.score), rf.model$preds, winner.rank, j.archive.id, units=0.05))
