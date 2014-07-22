episodes <- readHTMLTable("http://www.j-archive.com/showseason.php?season=30", stringsAsFactors=F, header=F)[[1]]
id.date.split <- strsplit(episodes[, 1], ", aired..", fixed=F)
episode.id <- as.numeric(gsub("#", "", sapply(id.date.split, function(x) x[1])))
date <- as.Date(sapply(id.date.split, function(x) x[2]))
contestants <- strsplit(episodes[, 2], " vs. ")