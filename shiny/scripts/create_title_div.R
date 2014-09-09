# Function to create title div
createTitleDiv <- function(game.info, var){
  text <- sprintf("%s for %s", var, game.info$num.and.date)
  items <- tags$strong(tags$span(style="font-size:14pt", text),
                       tags$br(),
                       tags$span(style="color:#8DD3C7", game.info$left.contestant),
                       "vs.",
                       tags$span(style="color:#FB8072", game.info$center.contestant),
                       "vs.",
                       tags$span(style="color:#BC80BD", game.info$right.contestant))
  if (game.info$tournament.game != "") items <- list(items,
                                                     tags$br(),
                                                     tags$strong(game.info$tournament.game),
                                                     tags$br(),
                                                     tags$span(style="color:red", "(Note: Odds estimates of tournament games are unreliable, see About tab for more)"))
  div <- div(items, style="text-align:center")
  return(div)
}
