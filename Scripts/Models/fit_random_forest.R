# Load packages
library(data.table)
library(randomForest)

# Fit random forest
rf.model <- randomForest(factor(winner.rank) ~ middle.diff + middle.ratio + bottom.diff + bottom.ratio + money.left + dd.remaining, data=usable.points, do.trace=2, ntree=100, sampsize=1000)

# Predict
rf.model <- list(model=rf.model, preds=predict(rf.model, type="prob"))

# Evaluate calibration
source("Scripts/Models/evaluate_calibration.R")
evaluateCalibration(rf.model$preds[, 1], usable.points$winner.rank == 1, units=0.1)