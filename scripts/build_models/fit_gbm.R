# Load function to fit model
source("scripts/build_models/unbiased_predict_gbm.R")

# Load workspace
load("data/workspaces/prepared_data.RData")

# Load package
library(data.table)
library(gbm)

# Fit model
gbm.model <- gbm(factor(winner.rank) ~ middle.diff.adj + middle.ratio + bottom.diff.adj + bottom.ratio + money.left.adj + dd.remaining + top.days + middle.days + bottom.days + lock.perc + crush.perc + lead.perc, data=modeling.points, distribution="multinomial", shrinkage=0.005, n.trees=4000, verbose=T, interaction.depth=2)

# Predict
gbm.model.preds <- unbiasedPredictGBM(gbm.model, modeling.points, n.trees=3200)

# Evaluate calibration
source("scripts/build_models/evaluate_model.R")
evaluateModel(modeling.points, gbm.model.preds, units=0.05)

# Predict on all games
gbm.preds.all <- unbiasedPredictGBM(gbm.model, all.game.points, n.trees=4000)

# Save to workspace
save(gbm.model, gbm.preds.all, file="data/workspaces/gbm_model.RData")