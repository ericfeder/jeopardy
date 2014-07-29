# Load package
library(data.table)
library(gbm)

# Select random games
test.ids <- sample(unique(usable.points$j.archive.id), 500)

# Fit model
gbm.model <- gbm(factor(winner.rank) ~ middle.diff + middle.ratio + bottom.diff + bottom.ratio + money.left + dd.remaining, data=usable.points[!j.archive.id %in% test.ids], distribution="multinomial", shrinkage=0.2, n.trees=150, verbose=T, n.minobsinnode=50)

# Predict
preds <- predict(gbm.model, usable.points[j.archive.id %in% test.ids], n.trees=100, type="response")[, , 1]
# gbm.model <- list(model=gbm.model, preds=predict(gbm.model, usable.points, n.trees=80, type="response")[, , 1])

# Evaluate calibration
source("Scripts/Models/evaluate_calibration.R")
evaluateCalibration(preds[, 1], usable.points[j.archive.id %in% test.ids, winner.rank] == 1, units=0.05)
hist(preds[, 1])
range(preds[, 1])
View(data.table(preds, usable.points[j.archive.id %in% test.ids, list(top.score, middle.score, bottom.score, money.left, dd.remaining, j.archive.id)])[j.archive.id == 4546])