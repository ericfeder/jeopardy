# Function to create title div
createTitleDiv <- function(game.info, var){
  text <- sprintf("%s for %s", var, game.info$num.and.date)
  items <- list(tags$span(style="font-size:14pt", text),
                tags$br(),
                tags$span(style="color:#8DD3C7", game.info$left.contestant),
                "vs.",
                tags$span(style="color:#FB8072", game.info$center.contestant),
                "vs.",
                tags$span(style="color:#BC80BD", game.info$right.contestant))
  if (game.info$tournament.game != "") items <- list(items, tags$br(), game.info$tournament.game)
  items <- tags$strong(items)
  div <- div(items, style="text-align:center")
  return(div)
}

# Function to create footer div
createFooterDiv <- function(tournament){
  if (tournament) text <- tags$span(style="font-size:8pt", "Note: Odds estimates of tournament games are unreliable, see About tab for more")
  else text <- ""
  div <- div(text, style="text-align:center")
  return(div)
}