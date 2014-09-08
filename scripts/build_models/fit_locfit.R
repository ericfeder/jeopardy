# Load packages
library(data.table)
library(locfit)

# Fit random forest
locfit.model <- locfit(factor(winner.rank) == 1 ~ lp(middle.diff.adj, middle.ratio, bottom.diff.adj, bottom.ratio, money.left.adj, nn=0.2), data=modeling.points)

# Predict
preds <- fitted(locfit.model)

# Evaluate calibration
source("Scripts/Models/evaluate_calibration.R")
plotCalibration(preds, modeling.points$winner.rank == 1, units=0.05, main="Top Player")

# Check sample game
rand.game <- data.table(preds, modeling.points[, list(top.score, middle.score, bottom.score, money.left, dd.remaining, j.archive.id)])[j.archive.id == 4479]
