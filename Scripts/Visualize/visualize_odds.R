# Function to fit inputs
source("shiny/fit_inputs.R")

# Function to visualize odds
visualizeOdds <- function(fitted){
  odds <- data.frame(podium=c("Left Contestant", "Center Contestant", "Right Contestant"), odds=fitted)
  n1 <- nPlot(x="podium", y="odds", data=odds, type="pieChart")
  return(n1)
}