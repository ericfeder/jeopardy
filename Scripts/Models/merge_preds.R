# Load package
library(data.table)

# Function to merge odds with data
mergePredsWithData <- function(preds, points){
  merged <- data.table(preds, points)
  merged$left.prob <- data.frame(preds)[cbind(1:nrow(merged), merged$left.rank)] * 100
  merged$center.prob <- data.frame(preds)[cbind(1:nrow(merged), merged$center.rank)] * 100
  merged$right.prob <- data.frame(preds)[cbind(1:nrow(merged), merged$right.rank)] * 100
  merged.select <- merged[, list(left, center, right, left.prob, center.prob, right.prob, round, num.q)]

  merged.split <- split(merged.select, merged$j.archive.id)
  return(merged.split)
}