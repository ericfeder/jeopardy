# Load package
library(gbm)

# Fit model
gbm.model <- gbm(factor(winner.rank) ~ middle.diff + middle.ratio + bottom.diff + bottom.ratio + money.left + dd.remaining, data=usable.points, distribution="multinomial", shrinkage=0.2)

# Predict
preds <- predict(gbm.model, usable.points, n.trees=80, type="response")
games.odds <- data.frame(usable.points, preds[, , 1])