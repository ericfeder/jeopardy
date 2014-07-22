# Load package
library(XML)

# Download list of episodes
episodes.raw <- readHTMLTable("http://www.j-archive.com/showseason.php?season=30", stringsAsFactors=F, header=F)[[1]]

# Split into components
id.date.split <- strsplit(episodes.raw[, 1], ", aired.", fixed=F)
episode.id <- as.numeric(gsub("#", "", sapply(id.date.split, function(x) x[1])))
date <- as.Date(sapply(id.date.split, function(x) x[2]))
contestants <- strsplit(episodes.raw[, 2], " vs. ")
contestants.list <- lapply(1:3, function(x) sapply(contestants, function(y) y[x]))

# Save as single data frame
episodes <- data.frame(episode.id, date, left.contestant=contestants.list[[1]], center.contestant=contestants.list[[2]], right.contestant=contestants.list[[3]], notes=episodes.raw[, 3])