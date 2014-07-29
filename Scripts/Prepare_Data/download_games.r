# Load packages
library(XML)
library(RCurl)

# Function to download game info
downloadGame <- function(j.archive.id){
  scores.raw <- tryCatch({
    readHTMLTable(sprintf("http://www.j-archive.com/showscores.php?game_id=%d", j.archive.id), stringsAsFactors=F, header=c(F, T, T, T, T))},
    error=function(err){
      warning("scraping scores page for game ", j.archive.id, " failed")
      return(NULL)}
  )
  game.html <- tryCatch({
    getURL(sprintf("http://www.j-archive.com/showgame.php?game_id=%d", j.archive.id))},
    error=function(err){
      warning("scraping game page for game ", j.archive.id, " failed")
      return(NULL)}
  )
  game.raw <- list(j.archive.id=j.archive.id, scores.raw=scores.raw, game.html=game.html)
  cat("Downloaded game", j.archive.id, "\n")
  return(game.raw)
}