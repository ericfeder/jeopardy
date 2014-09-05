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

  game$left_contestant <- game.info[j.archive.id == id, left.contestant]
  game$center_contestant <- game.info[j.archive.id == id, center.contestant]
  game$right_contestant <- game.info[j.archive.id == id, right.contestant]
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