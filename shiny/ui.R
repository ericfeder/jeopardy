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
                      fluidRow(
                        column(3,
                               numericInput("left.score", label="Left Contestant Score:", value=0),
                               numericInput("center.score", label="Center Contestant Score:", value=0),
                               numericInput("right.score", label="Right Contestant Score:", value=0)),
                        column(3,
                               sliderInput("money.left", label="Money Remaining on Board", min=0, max=54000, value=54000, step=200, format="$#,##0"),
                               selectInput("dd.remaining", label="Daily Doubles Remaining", choices=0:3, selected=3),
                               selectInput("champ.days", label="How many games has the left contestant won before today?", choices=c(0:3, "4+"), selected=0))
                      ),

                      hr(),

                      showOutput("oddsviz", lib="nvd3")
             ),

             tabPanel("About")
  )
)