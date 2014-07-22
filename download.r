# Load packages
library(XML)
library(RCurl)

# Function to download game info
downloadGame <- function(id){
  scores.raw <- readHTMLTable(sprintf("http://www.j-archive.com/showscores.php?game_id=%d", id), stringsAsFactors=F, header=c(F, T, T, T, T))
  game.html <- getURL(sprintf("http://www.j-archive.com/showgame.php?game_id=%d", id))
  game.raw <- list(scores.raw=scores.raw, game.html=game.html)
  cat("Downloaded game", id, "\n")
  return(game.raw)
}