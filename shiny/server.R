# Load data and packages
library(shiny)
library(data.table)
library(rCharts)
library(dplyr)
library(gbm)
library(mailR)

# Send email when app is opened
send.mail("<shiny@jwp-app.com>", "<federer490@gmail.com>", "[JWP-shiny-app] Site opened", as.character(Sys.time()), smtp=list(host.name="aspmx.l.google.com", port=25))

# Server function
shinyServer(function(input, output, session) {
  output$gameviz <- renderChart({
    id <- game.info$j.archive.id[game.info$game.strings == input$game.description]
    m1 <- visualizeGame(id, input$var, game.odds)
    m1$addParams(dom="gameviz")
    return(m1)
  })

  output$gameviztitle <- renderUI({
    game.info <- game.info[game.strings == input$game.description]
    createTitleDiv(game.info, input$var)
  })

  output$gamevizfooter <- renderUI({
    tournament <- game.info[game.strings == input$game.description, tournament.game != ""]
    createFooterDiv(tournament)
  })

  observe({
    season.num <- seasons[season.string == input$season, season]
    season.strings <- game.info[season == season.num, game.strings]
    updateSelectInput(session, "game.description", "Game: ", choices=season.strings, selected=season.strings[1])
  })

  output$oddsviz <- renderChart({
    if (!is.numeric(input$left.score) | !is.numeric(input$center.score) | !is.numeric(input$right.score)) stop("Please set numeric values for all 3 players")
    df.inputs <- data.frame(left.score=input$left.score,
                            center.score=input$center.score,
                            right.score=input$right.score,
                            money.left.adj=input$money.left,
                            dd.remaining=input$dd.remaining,
                            champ.days=input$champ.days,
                            stringsAsFactors=F)
    fitted <- fitInputs(df.inputs, gbm.model, n.trees=4000)
    n1 <- visualizeOdds(fitted)
    n1$set(dom="oddsviz")
    return(n1)
  })
})