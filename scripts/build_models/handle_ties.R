# Function to properly handle tie games when fitting gbm
predictGBM <- function(points, model, n.trees){
  # Fit model once
  first.run <- predict(model, points, n.trees=n.trees, type="response")[, , 1]

  # Flags for ties
  tie.for.first <- points$top.score == points$middle.score
  tie.for.second <- points$middle.score == points$bottom.score

  # Add column so middle.days preserved
  points$middle.days.temp <- points$middle.days

  # Swap values when one tie
  points2 <- copy(points)
  points2[tie.for.first & !tie.for.second, `:=`(middle.days=top.days, top.days=middle.days.temp)]
  points2[!tie.for.first & tie.for.second, `:=`(middle.days=bottom.days, bottom.days=middle.days.temp)]

  # Fit model and switch odds back
  second.run <- predict(model, points2, n.trees=n.trees, type="response")[, , 1]
  second.run[tie.for.first & !tie.for.second, c(1, 2)] <- second.run[tie.for.first & !tie.for.second, c(2, 1)]
  second.run[!tie.for.first & tie.for.second, c(2, 3)] <- second.run[!tie.for.first & tie.for.second, c(3, 2)]

  # Swap values when all tied
  points3 <- copy(points)
  points3[tie.for.first & tie.for.second, `:=`(middle.days=bottom.days, bottom.days=top.days, top.days=middle.days.temp)]
  points4 <- copy(points)
  points4[tie.for.first & tie.for.second, `:=`(middle.days=top.days, top.days=bottom.days, bottom.days=middle.days.temp)]
  points5 <- copy(points)
  points5[tie.for.first & tie.for.second, `:=`(middle.days=bottom.days, bottom.days=middle.days.temp)]
  points6 <- copy(points)
  points6[tie.for.first & tie.for.second, `:=`(middle.days=top.days, top.days=middle.days.temp)]
  points7 <- copy(points)
  points7$top.days.temp <- points7$top.days
  points7[tie.for.first & tie.for.second, `:=`(bottom.days=top.days.temp, top.days=bottom.days)]

  # Fit models and switch odds back
  third.run <- predict(model, points3, n.trees=n.trees, type="response")[, , 1]
  fourth.run <- predict(model, points4, n.trees=n.trees, type="response")[, , 1]
  fifth.run <- predict(model, points5, n.trees=n.trees, type="response")[, , 1]
  sixth.run <- predict(model, points6, n.trees=n.trees, type="response")[, , 1]
  seventh.run <- predict(model, points7, n.trees=n.trees, type="response")[, , 1]
  third.run[tie.for.first & tie.for.second, ] <- third.run[tie.for.first & tie.for.second, c(3, 1, 2)]
  fourth.run[tie.for.first & tie.for.second, ] <- fourth.run[tie.for.first & tie.for.second, c(2, 3, 1)]
  fifth.run[tie.for.first & tie.for.second, c(2, 3)] <- fifth.run[tie.for.first & tie.for.second, c(3, 2)]
  sixth.run[tie.for.first & tie.for.second, c(1, 2)] <- sixth.run[tie.for.first & tie.for.second, c(2, 1)]
  seventh.run[tie.for.first & tie.for.second, c(1, 3)] <- seventh.run[tie.for.first & tie.for.second, c(3, 1)]

  # Average over different runs
  probs <- (first.run + second.run) / 2
  avg3 <- (first.run + third.run + fourth.run + fifth.run + sixth.run + seventh.run) / 6
  probs[tie.for.first & tie.for.second, ] <- avg3[tie.for.first & tie.for.second, ]

  # Return
  return(probs)
}
