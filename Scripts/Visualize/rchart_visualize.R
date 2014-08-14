# Load package
library(rCharts)

# Merge odds with data
source("Scripts/Models/merge_preds.R")
game.odds.split <- mergePredsWithData(gbm.model$preds, modeling.points)

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
  game$q <- paste("Question", 1:nrow(game))

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
  return '<b>' + row.q + '</b>' + '<br/>' +
     row.left_contestant + ': ' + row.left_score + ' / ' + row.left_prob + '<br/>' +
     row.center_contestant + ': ' + row.center_score + ' / ' + row.center_prob + '<br/>' +
     row.right_contestant + ': ' + row.right_score + ' / ' + row.right_prob + '<br/>'
} !#"

# Function to visualize game
visualizeGame <- function(id, var){
  game <- prepareForVisualization(id, game.odds.split)
  players <- as.character(game[1, list(left_contestant, center_contestant, right_contestant)])
  if (var == "score") m1 <- mPlot(x="q", y=c("left", "center", "right"), type="Line", data=game, labels=players, pointSize=0, lineWidth=2, parseTime=F, preUnits="$", hoverCallback=hoverFunction, ymin=min(game[, list(left, center, right)]) - 200, ymax=max(game[, list(left, center, right)]) + 200, smooth=F)
  if (var == "prob") m1 <- mPlot(x="q", y=c("left.prob", "center.prob", "right.prob"), type="Line", data=game, labels=players, pointSize=0, lineWidth=2, parseTime=F, postUnits="%", hoverCallback=hoverFunction, ymin=0, ymax=100)
  return(m1)
}