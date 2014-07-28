# Load packages
library(data.table)
library(FNN)

# Fit k-NN
model <- knn.cv(scale(usable.points[, list(middle.diff, middle.ratio, bottom.diff, bottom.ratio, money.left, dd.remaining)]),
                usable.points[, factor(winner.rank)],
                k=200,
                prob=T)
game.odds <- data.table(usable.points, pred.winner=model, odds=attr(model, "prob"))

# Evaluate
rounded <- round(game.odds$odds[game.odds$pred.winner == 1] / 0.05) * 0.05
plot(sort(unique(rounded)), tapply(game.odds$winner.rank[game.odds$pred.winner == 1], rounded / 100, FUN=function(x) table(x)[1]/sum(table(x))))
abline(a=0, b=1)