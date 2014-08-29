# Load workspace
load("shiny_workspace.RData")

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

  # Add perc of money.left.adj needed for lock tie
  game$perc.for.lock <- with(game, setBounds((money.left.adj + middle.score - (top.score / 2)) / money.left.adj, min=0, max=1, set.na=0))
  game$perc.for.23 <- with(game, setBounds((money.left.adj + middle.score - (top.score * 2 / 3)) / money.left.adj, min=0, max=1, set.na=0))

  # Fit model
  preds <- predict(model, game, n.trees=n.trees, type="response")[, , 1]
  probs <- preds[ranks]

  # Return
  return(probs)
}

# Function to set both min and max of vector
setBounds <- function(vec, min, max, set.na=NULL){
  nothing.below.min <- pmax(0, vec)
  nothing.above.max <- pmin(max, nothing.below.min)
  if (!is.null(set.na)) nothing.above.max[is.na(nothing.above.max)] <- set.na
  return(nothing.above.max)
}

# Function to format as percent or dollar
formatAsPercent <- function(nums){
  return(sprintf("%.0f%%", nums))
}
formatAsDollar <- function(dollars){
  return(paste0("$", formatC(dollars, big.mark=",", format="d")))
}

# Function to prepare data to be visualized
prepareForVisualization <- function(id, l){
  index <- which(names(l) == id)
  game <- l[[index]]
  game$q <- paste(ifelse(game$round == "Jeopardy", "J!", "DJ!"), " #", game$num.q, sep="")
  game$q[1] <- "Start"
  game$q[nrow(game)] <- "Final"
  game$q_full <- paste(ifelse(game$round == "Jeopardy", "Jeopardy!", "Double Jeopardy!"), "Round, Question", game$num.q)
  game$q_full[1] <- 'Start of Game'
  game$q_full[nrow(game)] <- "Final Jeopardy!"

  # Format columns for mouseover
  game$left_prob <- formatAsPercent(game$left.prob)
  game$center_prob <- formatAsPercent(game$center.prob)
  game$right_prob <- formatAsPercent(game$right.prob)
  game$left_score <- formatAsDollar(game$left)
  game$center_score <- formatAsDollar(game$center)
  game$right_score <- formatAsDollar(game$right)

  players <- as.character(all.game.info[j.archive.id == id, list(as.character(left.contestant), as.character(center.contestant), as.character(right.contestant))])
  game$left_contestant <- players[1]
  game$center_contestant <- players[2]
  game$right_contestant <- players[3]
  return(game)
}

# Function for mouseover text
hoverFunction <- "#! function(index, options, content){
  var row = options.data[index]
  return '<b>' + row.q_full + '</b>' + '<br/>' +
     '<span style=\"color:#8DD3C7\">' + row.left_contestant + ': ' + row.left_score + ' / ' + row.left_prob + '</span><br/>' +
     '<span style=\"color:#FB8072\">' + row.center_contestant + ': ' + row.center_score + ' / ' + row.center_prob + '</span><br/>' +
     '<span style=\"color:#BC80BD\">' + row.right_contestant + ': ' + row.right_score + ' / ' + row.right_prob + '</span><br/>'
} !#"

# Function to visualize game
visualizeGame <- function(id, var){
  game <- prepareForVisualization(id, game.odds.split)
  players <- as.character(game[1, list(left_contestant, center_contestant, right_contestant)])

  if (var == "Score") m1 <- mPlot(x="q", y=c("left", "center", "right"), data=game, preUnits="$", ymin=round(min(game[, list(left, center, right)] - 50), -2), ymax=round(max(game[, list(left, center, right)]) + 50, -2), smooth=F)
  if (var == "Odds") m1 <- mPlot(x="q", y=c("left.prob", "center.prob", "right.prob"), data=game, postUnits="%", ymin=0, ymax=100)
  m1$set(type="Line", labels=players, pointSize=1, lineWidth=3, parseTime=F, hoverCallback=hoverFunction, lineColors=c("#8DD3C7", "#FB8072", "#BC80BD"), pointFillColors="black", xLabelAngle=60, height=450, hideHover="auto")
  return(m1)
}

# Function to visualize odds
visualizeOdds <- function(fitted){
  odds <- data.frame(podium=c("Left Contestant", "Center Contestant", "Right Contestant"), odds=fitted)
  n1 <- nPlot(x="podium", y="odds", data=odds, type="pieChart")
  n1$chart(color=c("#8DD3C7", "#FB8072", "#BC80BD"), showLegend=F, labelThreshold=0)
  return(n1)
}