# Define UI
shinyUI(
  navbarPage("Jeopardy Win Probability",
             tabPanel("Games",
                      sidebarLayout(
                        # Input Panel
                        sidebarPanel(
                          selectInput("season", label="Season: ", choices=seasons$season.string, selected=seasons$season.string[30]),
                          selectInput("game.description", label="Game: ", choices=game.info[season == 30, game.strings], selected=game.info[season == 30, game.strings][1]),
                          selectInput("var", choices=c("Odds", "Score"), label="Metric"),
                          width=4
                          ),

                        # Show data
                        mainPanel(
                          uiOutput("game_info"),
                          showOutput("viz", lib="morris")
                          )
                        )
                      ),

             tabPanel("Test Game State",
                      numericInput("left.score", label="Left Contestant Score:", value=0)
                      )
             )
  )