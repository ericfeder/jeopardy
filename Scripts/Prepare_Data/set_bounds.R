# Function to set both min and max of vector
setBounds <- function(vec, min, max, na.to.1){
  if (na.to.1) vec[is.na(vec)] <- 1
  nothing.below.min <- pmax(0, vec)
  nothing.above.max <- pmin(max, nothing.below.min)
  return(nothing.above.max)
}