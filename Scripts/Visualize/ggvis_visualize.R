# Load package
library(ggvis)
library(dplyr)
library(data.table)
library(reshape2)

# Function to prepare data to be visualized
prepareForVisualization <- function(id){
  game <- data.table(gbm.model$preds, modeling.points[, list(left.rank, center.rank, right.rank, left, center, right, money.left, dd.remaining, j.archive.id)])[j.archive.id == id]
  game$left.prob <- data.frame(game)[cbind(1:nrow(game), game$left.rank)]
  game$center.prob <- data.frame(game)[cbind(1:nrow(game), game$center.rank)]
  game$right.prob <- data.frame(game)[cbind(1:nrow(game), game$right.rank)]
  game$q <- 1:nrow(game)
  probs.long <- melt(game, id.vars="q", measure.vars=c("left.prob", "center.prob", "right.prob"), variable.name="podium", value.name="prob")
  scores.long <- melt(game, id.vars="q", measure.vars=c("left", "center", "right"), variable.name="podium", value.name="score")
  game.long <- data.frame(scores.long, prob=probs.long$prob)
  return(game.long)
}

# Function to visualize game
visualizeGame <- function(game, var="prob"){
  if (var == "prob") vis <- game %>% ggvis(~q, ~prob, stroke=~podium) %>% layer_lines() %>% layer_points(fill=~podium, size=1) %>% add_tooltip(function(df) df$prob) %>% add_axis("x", title="Question Number") %>% add_axis("y", title="Odds of Winning")
  if (var == "score") vis <- game %>% ggvis(~q, ~score, stroke=~podium) %>% layer_lines() %>% layer_points(fill=~podium, size=1) %>% add_tooltip(function(df) df$score) %>% add_axis("x", title="Question Number") %>% add_axis("y", title="Score")
  return(vis)
}