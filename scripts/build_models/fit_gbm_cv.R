# Load package
library(data.table)
library(gbm)

# Select random games
test.ids <- sample(unique(modeling.points$j.archive.id), 850)

# Fit model
gbm.model <- gbm(factor(winner.rank) ~ middle.diff.adj + middle.ratio + bottom.diff.adj + bottom.ratio + money.left.adj + dd.remaining + top.days + middle.days + bottom.days + lock.perc + crush.perc + lead.perc, data=modeling.points[!j.archive.id %in% test.ids], distribution="multinomial", shrinkage=0.01, n.trees=2000, verbose=T, interaction.depth=2)

# Predict
preds <- predict(gbm.model, modeling.points[j.archive.id %in% test.ids], n.trees=4000, type="response")[, , 1]
preds.new <- predictGBM(gbm.model, modeling.points.new[j.archive.id %in% test.ids], n.trees=1500)

# Evaluate calibration
source("scripts/build_models/evaluate_model.R")
evaluateModel(modeling.points[j.archive.id %in% test.ids], preds, units=0.05)
evaluateModel(modeling.points.new[j.archive.id %in% test.ids], preds.new, units=0.05)

# Show largest positive example
row <- which.max(preds[, 1] - preds.new[, 1])
# row <- which(preds[, 1] - preds.new[, 1] > 0.035)
modeling.points[j.archive.id %in% test.ids][row, ]
preds[row, ]
preds.new[row, ]

# Show largest negative example
row <- which.min(preds[, 1] - preds.new[, 1])
# row <- which(preds[, 1] - preds.new[, 1] < -0.1)
modeling.points[j.archive.id %in% test.ids][row, ]
preds[row, ]
preds.new[row, ]
