# Load packages
library(XML)
library(RCurl)

# Function to download game info
downloadGame <- function(j.archive.id){
  scores.raw <- readHTMLTable(sprintf("http://www.j-archive.com/showscores.php?game_id=%d", j.archive.id), stringsAsFactors=F, header=c(F, T, T, T, T))
  game.html <- getURL(sprintf("http://www.j-archive.com/showgame.php?game_id=%d", j.archive.id))
  game.raw <- list(j.archive.id=j.archive.id, scores.raw=scores.raw, game.html=game.html)
  cat("Downloaded game", j.archive.id, "\n")
  return(game.raw)
}