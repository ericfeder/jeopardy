# Load package
library(data.table)
library(gbm)

# Fit model
gbm.model <- gbm(factor(winner.rank) ~ middle.diff.adj + middle.ratio + bottom.diff.adj + bottom.ratio + money.left.adj + dd.remaining + top.days + middle.days + bottom.days, data=modeling.points, distribution="multinomial", shrinkage=0.01, n.trees=1500, verbose=T)
# gbm.model <- gbm(factor(winner.rank) ~ middle.diff.adj + middle.ratio + bottom.diff.adj + bottom.ratio + money.left.adj + dd.remaining + left.rank + champ.days, data=modeling.points, distribution="multinomial", shrinkage=0.01, n.trees=1500, verbose=T)

# Predict
gbm.model <- list(model=gbm.model, preds=predict(gbm.model, modeling.points, n.trees=700, type="response")[, , 1])

# Save to workspace
save(gbm.model, file="Workspaces/gbm_model.RData")

# Evaluate calibration
source("Scripts/Models/evaluate_calibration.R")
with(modeling.points, evaluateModel(data.frame(top.score, middle.score, bottom.score), gbm.model$preds, winner.rank, j.archive.id, units=0.05))
