# Function to process game
processGame <- function(game.raw, id){
  if (length(game.raw$scores.raw) == 1) return(NULL)
  game <- combineValuesAndScores(game.raw$scores.raw, game.raw$game.html)
  game.with.variables <- addVariables(game)
  game.with.variables$id <- id
  cat("Processed game", id, "\n")
  return(game.with.variables)
}

# Function to combine running scores and question values
combineValuesAndScores <- function(scores.raw, game.html){
  scores <- formatScores(scores.raw)
  values <- returnValues(game.html)
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
  null.rows <- which(combined[, 2] %in% c("", "(lock game)", "(lock tournament)", "(lock-tie game)")
                     & combined[, 3] %in% c("", "(lock game)", "(lock tournament)", "(lock-tie game)")
                     & combined[, 4] %in% c("", "(lock game)", "(lock tournament)", "(lock-tie game)")
                     )
  if (length(null.rows) > 0) combined <- combined[-(null.rows), ]

  # Clean dollar amounts
  combined[, -1] <- apply(combined[, -1], 2, function(x) as.numeric(gsub(x, pattern="\\$|,", replacement="")))

  # Return
  return(combined)
}

# Function to convert value string to value
extractRoundAndValue <- function(string){
	value.string.split <- data.frame(strsplit(string, "_"), stringsAsFactors=F)
	round <- as.vector(ifelse(value.string.split[1, ] == "J", "Jeopardy", "DoubleJeopardy"))
	values <- as.vector(ifelse(round == "Jeopardy", 1, 2) * as.numeric(value.string.split[3, ]) * 200)
	return(list(value=values, round=round))
}

# Function to return data frame of question values
returnValues <- function(html){
  # Extract values
  value.inds <- gregexpr("id=\"clue_D*J_[0-9]_[0-9]_stuck", html)
  value.string <- substring(html, unlist(value.inds) + 9, unlist(value.inds)+attr(value.inds[[1]], "match.length") - 7)
  values.rounds <- extractRoundAndValue(value.string)

  dd.inds <- gregexpr("clue_value|clue_value_daily_double", html)
  dd.string <- substring(html, unlist(dd.inds), unlist(dd.inds) + attr(dd.inds[[1]], "match.length") - 1)
  daily.double <- dd.string == "clue_value_daily_double"

  # Extract order of questions
  order.inds <- gregexpr("nofollow\">[0-9]{1,2}<", html)
  order <- as.numeric(substring(html, unlist(order.inds)+10, unlist(order.inds)+attr(order.inds[[1]], "match.length")-2))

  # Combine to one data frame
  df <- data.frame(num.q=order, value=values.rounds$value, daily.double)

  # Split into separate rounds
  df$round <- values.rounds$round

  # Put in order
  df <- df[order(df$round, -df$num.q, decreasing=T), ]

  # Add row for Final Jeopardy
  df[nrow(df) + 1, ] <- rep(NA, 4)
  df$round[nrow(df)] <- "FinalJeopardy"

  # Return
  return(df)
}

# Function to add variables to game
addVariables <- function(game){
  # Calculate money left
  game$money.left <- 54000 - cumsum(game$value)
  game$money.left[game$round == "DoubleJeopardy"] <- 36000 - cumsum(game$value[game$round == "DoubleJeopardy"])

  # Calculate daily doubles left
  game$dd.remaining <- 3 - cumsum(game$daily.double)

  # Add ranks
  ranks <- t(apply(-game[, 2:4], 1, rank, ties.method="first"))
  ranks <- cbind(ranks, ranks[, which.max(game[nrow(game), 2:4])])
  colnames(ranks) <- c("left.rank", "center.rank", "right.rank", "winner.rank")
  game <- data.frame(game, ranks)

  # Add ranked scores
  ranked.scores <- t(apply(game[, 2:4], 1, sort, decreasing=T))
  colnames(ranked.scores) <- c("top.score", "middle.score", "bottom.score")
  game <- data.frame(game, ranked.scores)

  # Add differences and ratios
  game$middle.diff <- game$top.score - game$middle.score
  game$bottom.diff <- game$top.score - game$bottom.score
  game$middle.ratio <- pmax(0, game$middle.score / game$top.score)
  game$bottom.ratio <- pmax(0, game$bottom.score / game$top.score)
  game$middle.ratio[is.na(game$middle.ratio)] <- 1
  game$bottom.ratio[is.na(game$bottom.ratio)] <- 1

  # Return
  return(game)
}