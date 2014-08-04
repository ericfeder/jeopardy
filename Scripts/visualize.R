# Load package
library(ggvis)
library(dplyr)
library(data.table)

# Function to prepare data to be visualized
prepareForVisualization <- function(id){
  game <- data.table(preds, usable.points[j.archive.id %in% test.ids, list(left.rank, center.rank, right.rank, left, center, right, money.left, dd.remaining, j.archive.id)])[j.archive.id == id]
  game$left.prob <- data.frame(game)[cbind(1:nrow(game), game$left.rank)]
  game$center.prob <- data.frame(game)[cbind(1:nrow(game), game$center.rank)]
  game$right.prob <- data.frame(game)[cbind(1:nrow(game), game$right.rank)]
  game$q <- 1:nrow(game)
  probs.long <- melt(game, id.vars="q", measure.vars=c("left.prob", "center.prob", "right.prob"), variable.name="podium", value.name="prob")
  scores.long <- melt(game, id.vars="q", measure.vars=c("left", "center", "right"), variable.name="podium", value.name="score")
  game.long <- data.frame(scores.long, prob=probs.long$prob)
  return(game.long)
}

# # Function to format tooltip
# formatTooltip <- function(data){
#   money.left <- formatC(game$money.left[data$q == game$q][1], big.mark=",", format="d")
#   score <- formatC(game.long$score[data$q == game.long$q & data$podium == game.long$podium], big.mark=",", format="d")
#   prob <- 100 * game.long$prob[data$q == game.long$q & data$podium == game.long$podium]
#   HTML(sprintf("Money Left: $%s<br>Score: $%s<br>Prob: %.0f%%", money.left, score, prob))
# }
all_values <- function(x) {
  if(is.null(x)) return(NULL)
  paste0(names(x), ": ", format(x), collapse = "<br />")
}

# Function to visualize game
visualizeGame <- function(game){
  game %>% ggvis(~q, ~prob, stroke=~podium) %>% layer_lines() %>% layer_points(fill=~podium, size=1) %>% add_tooltip(all_values) %>% add_axis("x", title="Question Number") %>% add_axis("y", title="Odds of Winning")
}