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
    game.info <- game.info[game.strings == input$game.description]
    list(
      tags$h4(game.info$game.strings),
      tags$h5(game.info$tournament.game),
      tags$span(style="color:red", game.info$disclaimer)
    )
  })

  output$oddsviz <- renderChart2({
    df.inputs <- data.frame(left.score=input$left.score,
                            center.score=input$center.score,
                            right.score=input$right.score,
                            money.left.adj=input$money.left,
                            dd.remaining=input$dd.remaining,
                            champ.days=input$champ.days,
                            stringsAsFactor=F)
    fitted <- fitInputs(df.inputs, gbm.model$model, n.trees=2500)
    n1 <- visualizeOdds(fitted)
    n1$set(dom="oddsviz", height=400, width=400)
    return(n1)
  })
})