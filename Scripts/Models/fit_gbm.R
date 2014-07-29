# Load package
library(data.table)
library(gbm)

# Select random games
test.ids <- sample(unique(usable.points$j.archive.id), 500)

# Fit model
gbm.model <- gbm(factor(winner.rank) ~ middle.diff + middle.ratio + bottom.diff + bottom.ratio + money.left + dd.remaining, data=usable.points[!j.archive.id %in% test.ids], distribution="multinomial", shrinkage=0.2, n.trees=150, verbose=T)

# Predict
preds <- predict(gbm.model, usable.points[j.archive.id %in% test.ids], n.trees=50, type="response")[, , 1]
gbm.model <- list(model=gbm.model, preds=predict(gbm.model, usable.points, n.trees=80, type="response")[, , 1])

# Evaluate calibration
source("Scripts/Models/evaluate_calibration.R")
evaluateCalibration(preds[, 1], usable.points[j.archive.id %in% test.ids, winner.rank] == 1, units=0.05)
abline(h=1/3, lty=3)
abline(v=1/3, lty=3)