shinyServer(function(input, output, session) {
  output$viz <- renderChart({
    id <- game.info$j.archive.id[game.info$game.strings == input$game.description]
    m1 <- visualizeGame(id, input$var)
    m1$addParams(dom="viz")
    return(m1)
  })

  observe({
    season.num <- seasons[season.string == input$season, season]
    season.strings <- game.info[season == season.num, game.strings]
    updateSelectInput(session, "game.description", "Game: ", choices=season.strings, selected=season.strings[1])
  })

  output$game_info <- renderUI({
    tags$h4(input$game.description)
  })
})