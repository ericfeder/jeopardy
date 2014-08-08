# Load package
library(data.table)
library(gbm)

# Select random games
test.ids <- sample(unique(modeling.points$j.archive.id), 800)

# Fit model
gbm.model <- gbm(factor(winner.rank) ~ middle.diff.adj + middle.ratio + bottom.diff.adj + bottom.ratio + money.left.adj + dd.remaining, data=modeling.points[!j.archive.id %in% test.ids], distribution="multinomial", shrinkage=0.005, n.trees=5000, verbose=T, interaction.depth=2)

# Predict
preds <- predict(gbm.model, modeling.points[j.archive.id %in% test.ids], n.trees=500, type="response")[, , 1]

# Evaluate calibration
source("Scripts/Models/evaluate_calibration.R")
with(modeling.points[j.archive.id %in% test.ids], evaluateModel(data.frame(top.score, middle.score, bottom.score), preds, winner.rank, j.archive.id, units=0.05))

# Check sample game
rand.game <- data.table(preds, modeling.points[j.archive.id %in% test.ids, list(top.score, middle.score, bottom.score, money.left, dd.remaining, j.archive.id)])[j.archive.id == sample(test.ids, 1)]
rand.game$prob1.change <- round(c(NA, diff(rand.game$"1")), 2)
rand.game$score1.change <- c(NA, diff(rand.game$top.score))
rand.game$score2.change <- c(NA, diff(rand.game$middle.score))
rand.game$score3.change <- c(NA, diff(rand.game$bottom.score))