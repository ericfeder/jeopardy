# Function to properly handle tie games when fitting gbm
unbiasedPredictGBM <- function(model, points, n.trees){
  # Cast to data.table
  points <- data.table(points)

  # Fit model once
  first.run <- predict(model, points, n.trees=n.trees, type="response")[, , 1]

  # Flags for ties
  tie.for.first <- points$top.score == points$middle.score
  tie.for.second <- points$middle.score == points$bottom.score

  # Add column so middle.days preserved
  points$middle.days.temp <- points$middle.days

  # Swap values when at least one tie
  if (sum(tie.for.first | tie.for.second) > 0){
    # Swap values when exactly one tie
    points2 <- copy(points)
    if (sum(tie.for.first & !tie.for.second) > 0) points2[tie.for.first & !tie.for.second, `:=`(middle.days=top.days, top.days=middle.days.temp)]
    if (sum(!tie.for.first & tie.for.second) > 0) points2[!tie.for.first & tie.for.second, `:=`(middle.days=bottom.days, bottom.days=middle.days.temp)]

    # Fit model and switch odds back
    second.run <- predict(model, points2, n.trees=n.trees, type="response")[, , 1]
    if (nrow(points) > 1){
      if (sum(tie.for.first & !tie.for.second) > 0) second.run[tie.for.first & !tie.for.second, c(1, 2)] <- second.run[tie.for.first & !tie.for.second, c(2, 1)]
      if (sum(!tie.for.first & tie.for.second) > 0) second.run[!tie.for.first & tie.for.second, c(2, 3)] <- second.run[!tie.for.first & tie.for.second, c(3, 2)]
    }
    else{
      if (tie.for.first & !tie.for.second) second.run[c(1, 2)] <- second.run[c(2, 1)]
      if (!tie.for.first & tie.for.second) second.run[c(2, 3)] <- second.run[c(3, 2)]
    }


    # Swap values when all tied
    if(sum(tie.for.first & tie.for.second) > 0){
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

      # Fit models
      third.run <- predict(model, points3, n.trees=n.trees, type="response")[, , 1]
      fourth.run <- predict(model, points4, n.trees=n.trees, type="response")[, , 1]
      fifth.run <- predict(model, points5, n.trees=n.trees, type="response")[, , 1]
      sixth.run <- predict(model, points6, n.trees=n.trees, type="response")[, , 1]
      seventh.run <- predict(model, points7, n.trees=n.trees, type="response")[, , 1]

      # Switch odds back
      if (nrow(points) > 1){
        third.run[tie.for.first & tie.for.second, ] <- third.run[tie.for.first & tie.for.second, c(3, 1, 2)]
        fourth.run[tie.for.first & tie.for.second, ] <- fourth.run[tie.for.first & tie.for.second, c(2, 3, 1)]
        fifth.run[tie.for.first & tie.for.second, c(2, 3)] <- fifth.run[tie.for.first & tie.for.second, c(3, 2)]
        sixth.run[tie.for.first & tie.for.second, c(1, 2)] <- sixth.run[tie.for.first & tie.for.second, c(2, 1)]
        seventh.run[tie.for.first & tie.for.second, c(1, 3)] <- seventh.run[tie.for.first & tie.for.second, c(3, 1)]
      }
      else{
        third.run <- third.run[c(3, 1, 2)]
        fourth.run <- fourth.run[c(2, 3, 1)]
        fifth.run[c(2, 3)] <- fifth.run[c(3, 2)]
        sixth.run[c(1, 2)] <- sixth.run[c(2, 1)]
        seventh.run[c(1, 3)] <- seventh.run[c(3, 1)]
      }
    }
  }

  # Average over different runs
  if (sum(tie.for.first | tie.for.second) > 0) probs <- (first.run + second.run) / 2
  else probs <- first.run
  if (sum(tie.for.first & tie.for.second) > 0){
    all.tied.avg <- (first.run + third.run + fourth.run + fifth.run + sixth.run + seventh.run) / 6
    if (nrow(points) > 1) probs[tie.for.first & tie.for.second, ] <- all.tied.avg[tie.for.first & tie.for.second, ]
    else probs <- all.tied.avg
  }

  # Return
  return(probs)
}
