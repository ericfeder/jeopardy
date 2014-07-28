# Function to evaluate how well a model is calibrated
evaluateCalibration <- function(pred.odds, actual, units){
  rounded <- round(pred.odds /units) * units
  num.games <- table(rounded)
  agg <- aggregate(actual ~ rounded, FUN=mean)
  plot(agg, xlab="Estimated", ylab="Actual WP", xlim=c(0, 1), ylim=c(0, 1), pch=19)
  abline(a=0, b=1)
}