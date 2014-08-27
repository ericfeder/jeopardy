# Function to evaluate model
evaluateModel <- function(points, pred.odds, units){
  # Track score changes
  score.diffs <- apply(points[, list(top.score, middle.score, bottom.score)], 2, diff)
  odds.diffs <- apply(pred.odds, 2, diff)
  new.game <- diff(points$j.archive.id) != 0

  # Flag rows where only one persons score changes
  just.one.change <- !new.game & apply(score.diffs, 1, function(x) sum(x == 0) == 2)
  which.col.changed <- apply(score.diffs[just.one.change, ], 1, function(x) which(x != 0))
  score.changed <- score.diffs[cbind(which(just.one.change), which.col.changed)]
  odds.changed <- odds.diffs[cbind(which(just.one.change), which.col.changed)]

  # Find likelihood of winner in each row
  actual <- points$winner.rank
  row.likelihoods <- pred.odds[cbind(1:nrow(pred.odds), actual)]

  # Fit model on game starts
  game.starts <- data.table(pred.odds, points)[round == "Start" & champ.days <= 5, c(1:3, "champ.days"), with=F]

  # Metrics
  perc.proper.direction <- mean(sign(score.changed) == sign(odds.changed))
  pred.ranges <- apply(pred.odds, 2, range)
  total.likelihood <- sum(log(row.likelihoods))
  starting.odds <- unique(game.starts)[order(champ.days)]

  # Plots
  par(mfrow=c(2, 2))
  plotCalibration(pred.odds[, 1], actual == 1, units, main="Top Score")
  plotCalibration(pred.odds[, 2], actual == 2, units, main="Middle Score")
  plotCalibration(pred.odds[, 2], actual == 2, units, main="Bottom Score")
  hist(pred.odds[, 1], main="Distribution of Top Player WP%")

  # Return
  return(list(perc.proper.direction=perc.proper.direction, leader.not.favored=leader.not.favored, pred.ranges=pred.ranges, likelihood=total.likelihood, starting.odds=starting.odds))
}

# Function to plot model calibration
plotCalibration <- function(pred.odds, actual, units, main){
  rounded <- round(pred.odds /units) * units
  num.games <- table(rounded)
  agg <- aggregate(actual ~ rounded, FUN=mean)
  plot(agg, xlab="Estimated", ylab="Actual WP", xlim=c(0, 1), ylim=c(0, 1), pch=19, main=main)
  abline(a=0, b=1)
  abline(h=1/3, lty=3)
  abline(v=1/3, lty=3)
}