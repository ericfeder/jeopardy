shinyServer(function(input, output) {
  game <- reactive({prepareForVisualization(input$j.archive.id)})
  vis <- reactive({visualizeGame(game, input$var)})
  vis %>% bind_shiny("plot", "plot_ui")

  output$game_info <- renderUI({
    contestants <- all.game.info[j.archive.id == input$j.archive.id, list(left.contestant, center.contestant, right.contestant)]
    contestants.string <- apply(contestants, 1, paste, collapse=" vs. ")
    date <- all.game.info[j.archive.id == input$j.archive.id, date]
    tags$h4(sprintf("%s (%s)", contestants.string, date))
  })
})