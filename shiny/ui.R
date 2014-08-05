# Define UI
shinyUI(fluidPage(

  #  Application title
  titlePanel("Jeopardy Win Probability"),


  sidebarLayout(
    # Input Panel
    sidebarPanel(
      numericInput("j.archive.id", label="J! Archive ID", value=4479),
      selectInput("var", choices=c("prob", "score"), selected="score", label="Metric"),
      submitButton("Submit"),
      width=2
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