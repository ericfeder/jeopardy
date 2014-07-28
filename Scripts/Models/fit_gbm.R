# Load package
library(data.table)
library(gbm)

# Fit model
gbm.model <- gbm(factor(winner.rank) ~ middle.diff + middle.ratio + bottom.diff + bottom.ratio + money.left + dd.remaining, data=usable.points, distribution="multinomial", shrinkage=0.2)

# Predict
gbm.model <- list(model=gbm.model, preds= predict(gbm.model, usable.points, n.trees=80, type="response")[, , 1])

# Evaluate calibration
source("Scripts/Models/evaluate_calibration.R")
evaluateCalibration(gbm.model$preds[, 1], usable.points$winner.rank == 1, units=0.025)