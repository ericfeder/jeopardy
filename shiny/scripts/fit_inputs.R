# Function to set both min and max of vector
source("scripts/set_bounds.R")

# Function to add variables and fit input
fitInputs <- function(game, model, n.trees){
  # Add ranks
  ranks <- rank(-game[, 1:3], ties.method="first")
  names(ranks) <- c("left.rank", "center.rank", "right.rank")
  game <- data.frame(game, t(ranks))

  # Add number of days of defending champion
  champ.days.adj <- ifelse(game$champ.days == "4+", 4, as.numeric(game$champ.days))
  days <- data.frame(top.days=0, middle.days=0, bottom.days=0)
  days[1, game$left.rank] <- champ.days.adj
  game <- data.frame(game, days)

  # Add ranked scores
  ranked.scores <- t(apply(game[, 1:3], 1, sort, decreasing=T))
  colnames(ranked.scores) <- c("top.score", "middle.score", "bottom.score")
  game <- data.frame(game, ranked.scores)

  # Add differences
  game$middle.diff.adj <- game$top.score - game$middle.score
  game$bottom.diff.adj <- game$top.score - game$bottom.score

  # Add ratios
  game$middle.ratio <- setBounds(game$middle.score / game$top.score, min=0, max=1, set.na=1)
  game$bottom.ratio <- setBounds(game$bottom.score / game$top.score, min=0, max=1, set.na=1)

  # Add lock/crush/lead metrics
  game$lock.perc <- with(game, setBounds((top.score / 2 - middle.score) / money.left.adj, min=0, max=1, set.na=1))
  game$crush.perc <- with(game, setBounds((top.score * 2 / 3 - middle.score) / money.left.adj, min=0, max=1, set.na=1))
  game$lead.perc <- with(game, setBounds((top.score - middle.score) / money.left.adj, min=0, max=1, set.na=0))

  # Fit model
  preds <- predict(model, game, n.trees=n.trees, type="response")[, , 1]
  probs <- preds[ranks]

  # Return
  return(probs)
}