# Function to set both min and max of vector
setBounds <- function(vec, min, max, set.na=NULL){
  nothing.below.min <- pmax(0, vec)
  nothing.above.max <- pmin(max, nothing.below.min)
  if (!is.null(set.na)) nothing.above.max[is.na(nothing.above.max)] <- set.na
  return(nothing.above.max)
}