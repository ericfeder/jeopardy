# Define UI
shinyUI(fluidPage(

  #  Application title
  titlePanel("Jeopardy Win Probability"),


  sidebarLayout(
    # Input Panel
    sidebarPanel(
      selectInput("season", label="Season: ", choices=1:30, selected=30),
      selectInput("game.description", label="Game: ", choices=game.info[season == 30, game.strings], selected=game.info[season == 30, game.strings][1]),
      selectInput("var", choices=c("prob", "score"), selected="score", label="Metric"),
      width=4
    ),
    # Show data
    mainPanel(
      uiOutput("game_info"),
      uiOutput("plot_ui"),
      ggvisOutput("plot")
      )
    )
  )
)