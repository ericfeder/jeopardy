shinyServer(function(input, output, session) {
  game <- reactive({prepareForVisualization(game.info$j.archive.id[game.info$game.strings == input$game.description])})
  vis <- reactive({visualizeGame(game, input$var)})
  vis %>% bind_shiny("plot", "plot_ui")

  observe({
    season.strings <- game.info[season == input$season, game.strings]
    updateSelectInput(session, "game.description", "Game: ", choices=season.strings, selected=season.strings[1])
  })

  output$game_info <- renderUI({
    contestants <- all.game.info[j.archive.id == input$j.archive.id, list(left.contestant, center.contestant, right.contestant)]
    contestants.string <- apply(contestants, 1, paste, collapse=" vs. ")
    date <- all.game.info[j.archive.id == input$j.archive.id, date]
    tags$h4(sprintf("%s (%s)", contestants.string, date))
  })
})