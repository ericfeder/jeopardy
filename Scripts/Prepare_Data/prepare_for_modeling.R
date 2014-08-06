# Function to convert predoubled values and add game info
prepareForModeling <- function(points, game.info){
  merged <- merge(points, game.info, by="j.archive.id")
  adjusted <- ifelse(merged$values.doubled, 1, 2) * merged[, list(money.left, top.score, middle.score, bottom.score, middle.diff, bottom.diff)]
  setnames(adjusted, c("money.left.adj", "top.score.adj", "middle.score.adj", "bottom.score.adj", "middle.diff.adj", "bottom.diff.adj"))
  merged.back <- data.table(merged, adjusted)
  return(merged.back)
}