# Load packages
library(data.table)
library(FNN)

# # Fit k-NN
# knnOneGame <- function(id){
#   model <- kknn(factor(winner.rank) ~ middle.diff + middle.ratio +  bottom.diff + bottom.ratio + money.left + dd.remaining,
#                 test=usable.points[j.archive.id == id],
#                 train=usable.points[j.archive.id != id],
#                 k=200,
#                 kernel="triangular")
#   cat("kknn for game", id, "\n")
#   return(model$prob)
# }
# kknn.model <- lapply(unique(usable.points$j.archive.id), knnOneGame)

# Fit kNN
kknn.model <- knn.cv(scale(modeling.points[, list(middle.diff.adj, middle.ratio, bottom.diff.adj, bottom.ratio, money.left.adj)]),
                     factor(modeling.points[, winner.rank]),
                     k=200,
                     prob=T)
preds <- attr(kknn.model, "prob")

# Evaluate calibration
source("Scripts/Models/evaluate_calibration.R")
plotCalibration(preds, modeling.points$winner.rank == 1, units=0.05, main="Top Player")

# Check sample game
rand.game <- data.table(preds, modeling.points[values.doubled == T, list(top.score, middle.score, bottom.score, money.left, dd.remaining, j.archive.id)])[j.archive.id == 4479]
View(rand.game)
