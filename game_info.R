# Load package
library(XML)

# Function to download season
downloadSeason <- function(num){
  # Define URL
  url <- sprintf("http://www.j-archive.com/showseason.php?season=%d", num)

  # Download list of episodes
  episodes.raw <- readHTMLTable(url, stringsAsFactors=F, header=F)[[1]]

  # Split into components
  id.date.split <- strsplit(episodes.raw[, 1], ", aired.", fixed=F)
  episode.id <- as.numeric(gsub("#", "", sapply(id.date.split, function(x) x[1])))
  date <- as.Date(sapply(id.date.split, function(x) x[2]))
  contestants <- strsplit(episodes.raw[, 2], " vs. ")
  contestants.list <- lapply(1:3, function(x) sapply(contestants, function(y) y[x]))

  # Extract j-archive ids
  episodes.html <- htmlParse(url)
  links <- xpathSApply(episodes.html, "//a/@href")
  links.games <- grep("?game_id=[0-9]{1,4}", links, value=T)
  j.archive.id <- as.numeric(gsub("[^0-9]", "", links.games))
  if (num != 1) j.archive.id <- j.archive.id[j.archive.id != 173]

  # Save as single data frame
  episodes <- data.frame(season=num, episode.id, j.archive.id, date, left.contestant=contestants.list[[1]], center.contestant=contestants.list[[2]], right.contestant=contestants.list[[3]], notes=episodes.raw[, 3])
  cat("downloaded season", num, "\n")

  # Return
  return(episodes)
}

# Function to extract additional game information
addInfo <- function(info){
  info$values.doubled <- info$date >= as.Date("2001-11-26")
  info$tournament <- grepl("Battle of the Decades|Tournament|Championship|Kids Week|Power Players Week|The IBM Challenge|Celebrity|Million Dollar|Back to School Week", info$notes, ignore.case=T) & !grepl("announces|drawing", info$notes, ignore.case=T)
  return(info)
}