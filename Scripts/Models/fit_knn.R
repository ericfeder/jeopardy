# Load packages
library(data.table)
library(kknn)

# Fit k-NN
knnOneGame <- function(id){
  model <- kknn(factor(winner.rank) ~ middle.diff + middle.ratio +  bottom.diff + bottom.ratio + money.left + dd.remaining,
                test=usable.points[j.archive.id == id],
                train=usable.points[j.archive.id != id],
                k=200,
                kernel="triangular")
  cat("kknn for game", id, "\n")
  return(model$prob)
}
kknn.model <- lapply(unique(usable.points$j.archive.id), knnOneGame)