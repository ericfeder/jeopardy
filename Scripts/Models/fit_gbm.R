# Load package
library(data.table)
library(gbm)

# Fit model
gbm.model <- gbm(factor(winner.rank) ~ middle.diff + middle.ratio + bottom.diff + bottom.ratio + money.left + dd.remaining, data=usable.points, distribution="multinomial", shrinkage=0.01, n.trees=1500, verbose=T)

# Predict
gbm.model <- list(model=gbm.model, preds=predict(gbm.model, usable.points, n.trees=700, type="response")[, , 1])

# Evaluate calibration
source("Scripts/Models/evaluate_calibration.R")
with(usable.points, evaluateModel(data.frame(top.score, middle.score, bottom.score), gbm.model$preds, winner.rank, j.archive.id, units=0.05))