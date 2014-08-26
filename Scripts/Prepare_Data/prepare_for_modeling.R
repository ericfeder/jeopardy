# Function to set both min and max of vector
source("Scripts/Prepare_Data/set_bounds.R")

# Function to convert predoubled values and add info
prepareForModeling <- function(points, game.info){
  # Add differences
  points$middle.diff <- points$top.score - points$middle.score
  points$bottom.diff <- points$top.score - points$bottom.score

  # Add ratios
  points$middle.ratio <- setBounds(points$middle.score / points$top.score, min=0, max=1, na.to.1=T)
  points$bottom.ratio <- setBounds(points$bottom.score / points$top.score, min=0, max=1, na.to.1=T)

  # Double if necessary and merge
  merged <- merge(points, game.info, by="j.archive.id")
  adjusted <- ifelse(merged$values.doubled, 1, 2) * merged[, list(money.left, top.score, middle.score, bottom.score, middle.diff, bottom.diff)]
  setnames(adjusted, c("money.left.adj", "top.score.adj", "middle.score.adj", "bottom.score.adj", "middle.diff.adj", "bottom.diff.adj"))
  merged.back <- data.table(merged, adjusted)

  # Add lock game
  merged.back$lock.game <- with(merged.back, top.score/2 - middle.score > money.left & dd.remaining == 0)
  merged.back$lock.game.end <- merged.back$middle.ratio < 0.5 & merged.back$money.left == 0

  # Return
  return(merged.back)
}