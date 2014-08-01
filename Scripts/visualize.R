# Load package
library(ggvis)

# Prepare
rand.game <- data.table(preds, usable.points[j.archive.id %in% test.ids, list(left.rank, center.rank, right.rank, top.score, middle.score, bottom.score, money.left, dd.remaining, j.archive.id)])[j.archive.id == sample(test.ids, 1)]
rand.game$left.prob <- data.frame(rand.game)[matrix(1:nrow(rand.game), rand.game$left.rank)]
rand.game$center.prob <- data.frame(rand.game)[matrix(1:nrow(rand.game), rand.game$center.rank)]
rand.game$right.prob <- data.frame(rand.game)[matrix(1:nrow(rand.game), rand.game$right.rank)]
rand.game$q <- 1:nrow(rand.game)

# Plot
rand.game %>% ggvis(~q, ~left.prob) %>% layer_paths()