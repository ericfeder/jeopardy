# Function to add variables
addVariablesToInputs <- function(game){
  # Add number of days of defending champion
  champ.days.adj <- ifelse(champ.days == "4+", 4, as.numeric(champ.days))
  days <- data.frame(top.days=0, middle.days=0, bottom.days=0)
  if (champ.days > 0 & !is.na(champ.days)) days[1, game$left.rank] <- champ.days
  game <- data.frame(game, days)

  # Add ranked scores
  ranked.scores <- t(apply(game[, 2:4], 1, sort, decreasing=T))
  colnames(ranked.scores) <- c("top.score", "middle.score", "bottom.score")
  game <- data.frame(game, ranked.scores)

  # Add differences
  game$middle.diff.adj <- game$top.score - game$middle.score
  game$bottom.diff.adj <- game$top.score - game$bottom.score

  # Add ratios
  game$middle.ratio <- setBounds(game$middle.score / game$top.score, min=0, max=1, na.to.1=T)
  game$bottom.ratio <- setBounds(game$bottom.score / game$top.score, min=0, max=1, na.to.1=T)
}

fitModel <-