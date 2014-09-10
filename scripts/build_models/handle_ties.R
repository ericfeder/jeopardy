# Function to properly handle tie games when fitting gbm
points <- modeling.points[j.archive.id %in% test.ids]
model <- gbm.model
n.trees <- 700

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

# Fit models and switch odds back
third.run <- predict(model, points3, n.trees=n.trees, type="response")[, , 1]
fourth.run <- predict(model, points4, n.trees=n.trees, type="response")[, , 1]
third.run[tie.for.first & tie.for.second, 1:3] <- third.run[tie.for.first & tie.for.second, c(3, 1, 2)]
fourth.run[tie.for.first & tie.for.second, 1:3] <- third.run[tie.for.first & tie.for.second, c(2, 3, 1)]

avg <- (first.run + second.run) / 2
difs <- avg - first.run

avg3 <- (first.run + third.run + fourth.run) / 3
difs <- avg3 - first.run
