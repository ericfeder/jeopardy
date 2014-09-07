# Function to process game
processGame <- function(game.raw, doubled, champ.days){
  # Skip games with no/unusual info
  if (game.raw$j.archive.id == 3575 | length(game.raw$scores.raw) < 5 | is.null(game.raw$scores.raw) | is.null(game.raw$game.html)) return("No game info")

  if (game.raw$j.archive.id == 3576) game <- combineValuesAndScoresWatson()
  else game <- combineValuesAndScores(game.raw$scores.raw, game.raw$game.html, doubled)
  game.with.variables <- addVariables(game, doubled, champ.days)
  game.with.variables$j.archive.id <- game.raw$j.archive.id
  cat("Processed game", game.raw$j.archive.id, "\n")
  return(game.with.variables)
}

# Function to combine running scores and question values
combineValuesAndScores <- function(scores.raw, game.html, doubled){
  scores <- formatScores(scores.raw)
  values <- returnValues(game.html, doubled)
  game <- data.frame(scores, values)

  # Check for errors
  if (any(game$round != game$round.1)) stop("Rounds don't line up")

  # Return
  return(game[, -which(colnames(game) == "round.1")])
}

# Function to combine running scores and question values for first Watson game
combineValuesAndScoresWatson <- function(){
  first.day <- which(sapply(games.raw, function(x) x$j.archive.id) == 3575)
  second.day <- which(sapply(games.raw, function(x) x$j.archive.id) == 3576)

  scores <- formatScores(games.raw[[second.day]]$scores.raw)
  values1 <- returnValues(games.raw[[first.day]]$game.html, doubled=T)
  values2 <- returnValues(games.raw[[second.day]]$game.html, doubled=T)
  values <- rbind(values1[-nrow(values1), ], values2[-1, ])
  game <- data.frame(scores, values)

  # Check for errors
  if (any(game$round != game$round.1)) stop("Rounds don't line up")

  # Return
  return(game[, -which(colnames(game) == "round.1")])
}

# Function to return data frame of running scores
formatScores <- function(scores){
  # Combine three rounds
  combined <- rbind(data.frame(round="Jeopardy", scores[[2]][, 2:4]),
                    data.frame(round="DoubleJeopardy", scores[[3]][, 2:4]),
                    data.frame(round="FinalJeopardy", scores[[4]][1, ]))

  # Add row for start of game
  start.row <- data.frame("Start", 0, 0, 0)
  colnames(start.row) <- colnames(combined)
  combined <- rbind(start.row, combined)

  # Exclude null rows
  null.rows <- which(combined[, 2] %in% c("", "(lock game)", "(lock tournament)", "(lock-tie game)", "(lock challenge)")
                     & combined[, 3] %in% c("", "(lock game)", "(lock tournament)", "(lock-tie game)", "(lock challenge)")
                     & combined[, 4] %in% c("", "(lock game)", "(lock tournament)", "(lock-tie game)", "(lock challenge)")
                     )
  if (length(null.rows) > 0) combined <- combined[-(null.rows), ]

  # Clean dollar amounts
  combined[, -1] <- apply(combined[, -1], 2, function(x) as.numeric(gsub(x, pattern="\\$|,", replacement="")))

  # Return
  return(combined)
}

# Function to convert value string to value
extractRoundAndValue <- function(string, doubled){
	value.string.split <- data.frame(strsplit(string, "_"), stringsAsFactors=F)
	round <- as.vector(ifelse(value.string.split[1, ] == "J", "Jeopardy", "DoubleJeopardy"))
  base <- ifelse(doubled, 200, 100)
	values <- as.vector(ifelse(round == "Jeopardy", 1, 2) * as.numeric(value.string.split[3, ]) * base)
	return(list(value=values, round=round))
}

# Function to return data frame of question values
returnValues <- function(html, doubled){
  # Extract values
  value.inds <- gregexpr("id=\"clue_D*J_[0-9]_[0-9]_stuck", html)
  value.string <- substring(html, unlist(value.inds) + 9, unlist(value.inds)+attr(value.inds[[1]], "match.length") - 7)
  values.rounds <- extractRoundAndValue(value.string, doubled)

  dd.inds <- gregexpr("clue_value|clue_value_daily_double", html)
  dd.string <- substring(html, unlist(dd.inds), unlist(dd.inds) + attr(dd.inds[[1]], "match.length") - 1)
  daily.double <- dd.string == "clue_value_daily_double"

  # Extract order of questions
  order.inds <- gregexpr("nofollow\">[0-9]{1,2}<", html)
  order <- as.numeric(substring(html, unlist(order.inds)+10, unlist(order.inds)+attr(order.inds[[1]], "match.length")-2))

  # Combine to one data frame
  df <- data.frame(num.q=order, value=values.rounds$value, daily.double)

  # Add indicator for separate rounds
  df$round <- values.rounds$round

  # Put in order
  df <- df[order(df$round, -df$num.q, decreasing=T), ]

  # Add row for start of game
  start.row <- rep(NA, 4)
  names(start.row) <- colnames(df)
  df <- rbind(start.row, df)
  df$round[1] <- "Start"

  # Add row for Final Jeopardy
  df[nrow(df) + 1, ] <- rep(NA, 4)
  df$round[nrow(df)] <- "FinalJeopardy"

  # Return
  return(df)
}

# Function to add variables to game
addVariables <- function(game, doubled, champ.days){
  # Calculate money left
  total.money <- ifelse(doubled, 54000, 27000)
  game$money.left <- total.money - cumsum(c(0, game$value[-1]))
  game$money.left[game$round == "DoubleJeopardy"] <- total.money * 2/3 - cumsum(game$value[game$round == "DoubleJeopardy"])
  game$money.left[nrow(game) - 1] <- 0

  # Calculate daily doubles left
  game$dd.remaining <- 3 - cumsum(c(F, game$daily.double[-1]))
  game$dd.remaining[game$round == "DoubleJeopardy"] <- 2 - cumsum(game$daily.double[game$round == "DoubleJeopardy"])
  game$dd.remaining[nrow(game) - 1] <- 0

  # Add ranks
  ranks <- t(apply(-game[, 2:4], 1, rank, ties.method="first"))
  final.scores <- as.numeric(game[nrow(game), 2:4])
  if (sum(final.scores == max(final.scores)) > 1) winner.rank <-  NA
  else winner.rank <- ranks[, which.max(final.scores)]
  ranks <- cbind(ranks, winner.rank)
  colnames(ranks) <- c("left.rank", "center.rank", "right.rank", "winner.rank")
  game <- data.frame(game, ranks)

  # Add number of days of defending champion
  days <- data.frame(top.days=rep(0, nrow(game)), middle.days=rep(0, nrow(game)), bottom.days=rep(0, nrow(game)))
  if (champ.days > 0 & !is.na(champ.days)) days[cbind(1:nrow(days), game$left.rank)] <- min(champ.days, 4)
  game <- data.frame(game, days)

  # Add ranked scores
  ranked.scores <- t(apply(game[, 2:4], 1, sort, decreasing=T))
  colnames(ranked.scores) <- c("top.score", "middle.score", "bottom.score")
  game <- data.frame(game, ranked.scores)

  # Return
  return(game)
}

# Function to find if game has one returning champion
checkReturningChampion <- function(contestants.vec){
  matches <- gregexpr("[0-9]{1,2}\\-day cash winnings total", contestants.vec)
  num.champs <- sapply(matches, function(x) sum(x != -1))
  days <- gsub("[^0-9]", "", substring(contestants.vec, sapply(matches, function(x) x[1]), sapply(matches, function(x) x[1]) + 1))
  days <- as.numeric(replace(days, days == "", 0))
  days[num.champs > 1] <- NA
  return(list(days=days, num.champs=num.champs))
}