# Load package
library(data.table)

# Function to merge odds with data
mergePredsWithData <- function(preds, points){
  merged <- data.table(preds, points)
  merged$left.prob <- data.frame(preds)[cbind(1:nrow(merged), merged$left.rank)] * 100
  merged$center.prob <- data.frame(preds)[cbind(1:nrow(merged), merged$center.rank)] * 100
  merged$right.prob <- data.frame(preds)[cbind(1:nrow(merged), merged$right.rank)] * 100
  merged.select <- merged[, list(left, center, right, left.prob, center.prob, right.prob, round, num.q)]

  results <- game.results[j.archive.id %in% merged$j.archive.id, list(left, center, right, left.prob=ifelse(left.rank == 1, 100, 0), center.prob=ifelse(center.rank == 1, 100, 0), right.prob=ifelse(right.rank == 1, 100, 0), round="Final", q=NA, j.archive.id)]
  merged.with.results <- rbindlist(list(merged.select, results[, which(!grepl("j.archive.id", colnames(results))), with=FALSE]))

  merged.split <- split(merged.with.results, c(merged$j.archive.id, results$j.archive.id))
  return(merged.split)
}