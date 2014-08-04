# Define UI
shinyUI(fluidPage(

  #  Application title
  titlePanel("Jeopardy Sabermetrics"),


  sidebarLayout(
    # Input Panel
    sidebarPanel(
      numericInput("j.archive.id", label="J! Archive ID", value=4101),
      selectInput("var", label="Type of Plot", choices=c("prob", "score")),
      submitButton("Submit"),
      width=2
    ),
    # Show data
    mainPanel(
      uiOutput("plot_ui"),
      ggvisOutput("plot"),
      dataTableOutput("odds.dt")
      )
    )
  )
)