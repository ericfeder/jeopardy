shinyServer(function(input, output) {
  game <- reactive({prepareForVisualization(input$j.archive.id)})
  vis <- visualizeGame(game)
  vis %>% bind_shiny("plot", "plot_ui")

  output$odds.dt <- renderDataTable({
    rand.game <- data.table(preds, usable.points[j.archive.id %in% test.ids, list(left.rank, center.rank, right.rank, left, center, right, money.left, dd.remaining, j.archive.id)])[j.archive.id == input$j.archive.id]
    rand.game$left.prob <- data.frame(rand.game)[cbind(1:nrow(rand.game), rand.game$left.rank)]
    rand.game$center.prob <- data.frame(rand.game)[cbind(1:nrow(rand.game), rand.game$center.rank)]
    rand.game$right.prob <- data.frame(rand.game)[cbind(1:nrow(rand.game), rand.game$right.rank)]
    rand.game$q <- 1:nrow(rand.game)
    rand.game[, list(q, left.prob, center.prob, right.prob)]
    },
    options=list(bFilter=F, bSort=0, bPaginate=F))
})