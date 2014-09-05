# Load package
library(data.table)

# Function to merge odds with data
mergePredsWithData <- function(preds, points, results){
  merged <- data.table(preds, points)
  merged$left.prob <- data.frame(preds)[cbind(1:nrow(merged), merged$left.rank)] * 100
  merged$center.prob <- data.frame(preds)[cbind(1:nrow(merged), merged$center.rank)] * 100
  merged$right.prob <- data.frame(preds)[cbind(1:nrow(merged), merged$right.rank)] * 100
  merged.select <- merged[, list(j.archive.id, left, center, right, left.prob, center.prob, right.prob, round, num.q)]

  results <- results[j.archive.id %in% merged$j.archive.id, list(j.archive.id, left, center, right, left.prob=ifelse(left.rank == 1, 100, 0), center.prob=ifelse(center.rank == 1, 100, 0), right.prob=ifelse(right.rank == 1, 100, 0), round="Final", q=NA)]
  merged.with.results <- rbindlist(list(merged.select, results))

  return(merged.with.results)
}