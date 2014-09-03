# Load model package
library(gbm)

# Function to visualize odds
visualizeOdds <- function(fitted){
  odds <- data.frame(podium=c("Left Contestant", "Center Contestant", "Right Contestant"), odds=fitted)
  n1 <- nPlot(x="podium", y="odds", data=odds, type="pieChart")
  n1$chart(color=c("#8DD3C7", "#FB8072", "#BC80BD"), showLegend=F, labelThreshold=0)
  return(n1)
}