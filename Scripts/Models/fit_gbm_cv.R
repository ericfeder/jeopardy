# Load package
library(data.table)
library(gbm)

# Select random games
test.ids <- sample(unique(modeling.points$j.archive.id), 850)

# Fit model
gbm.model <- gbm(factor(winner.rank) ~ middle.diff.adj + middle.ratio + bottom.diff.adj + bottom.ratio + money.left.adj + dd.remaining + top.days + middle.days + bottom.days, data=modeling.points[!j.archive.id %in% test.ids], distribution="multinomial", shrinkage=0.01, n.trees=1500, verbose=T, interaction.depth=2)
gbm.model.new <- gbm(factor(winner.rank) ~ middle.diff.adj + middle.ratio + bottom.diff.adj + bottom.ratio + money.left.adj + dd.remaining + top.days + middle.days + bottom.days, data=modeling.points[!j.archive.id %in% test.ids], distribution="multinomial", shrinkage=0.01, n.trees=1500, verbose=T, interaction.depth=1, n.minobsinnode=4)

# Predict
preds <- predict(gbm.model, modeling.points[j.archive.id %in% test.ids], n.trees=1000, type="response")[, , 1]
preds.new <- predict(gbm.model.new, modeling.points[j.archive.id %in% test.ids], n.trees=1000, type="response")[, , 1]

# Evaluate calibration
source("Scripts/Models/evaluate_calibration.R")
with(modeling.points[j.archive.id %in% test.ids], evaluateModel(data.frame(top.score, middle.score, bottom.score), preds, winner.rank, j.archive.id, units=0.05))
with(modeling.points[j.archive.id %in% test.ids], evaluateModel(data.frame(top.score, middle.score, bottom.score), preds.new, winner.rank, j.archive.id, units=0.05))