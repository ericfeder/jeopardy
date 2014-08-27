# Function to set both min and max of vector
source("Scripts/Prepare_Data/set_bounds.R")

# Function to convert predoubled values and add info
prepareForModeling <- function(points, game.info){
  # Add differences
  points$middle.diff <- points$top.score - points$middle.score
  points$bottom.diff <- points$top.score - points$bottom.score

  # Add ratios
  points$middle.ratio <- setBounds(points$middle.score / points$top.score, min=0, max=1, set.na=1)
  points$bottom.ratio <- setBounds(points$bottom.score / points$top.score, min=0, max=1, set.na=1)

  # Double if necessary and merge
  merged <- merge(points, game.info, by="j.archive.id")
  adjusted <- ifelse(merged$values.doubled, 1, 2) * merged[, list(money.left, top.score, middle.score, bottom.score, middle.diff, bottom.diff)]
  setnames(adjusted, c("money.left.adj", "top.score.adj", "middle.score.adj", "bottom.score.adj", "middle.diff.adj", "bottom.diff.adj"))
  merged.back <- data.table(merged, adjusted)

  # Add perc of money.left.adj needed for lock tie
  merged.back$perc.for.lock <- with(merged.back, setBounds((money.left.adj + middle.score.adj - (top.score.adj / 2)) / money.left.adj, min=0, max=1, set.na=0))
  merged.back$perc.for.23 <- with(merged.back, setBounds((money.left.adj + middle.score.adj - (top.score.adj * 2 / 3)) / money.left.adj, min=0, max=1, set.na=0))

  # Return
  return(merged.back)
}