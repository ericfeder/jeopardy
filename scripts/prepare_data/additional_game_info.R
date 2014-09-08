# Function to extract additional game information
addInfo <- function(info){
  info$values.doubled <- info$date >= as.Date("2001-11-26")
  info$tournament <- grepl("Battle of the Decades|Tournament|Championship|Kids Week|Power Players Week|The IBM Challenge|Celebrity|Million Dollar|Back to School Week", info$notes, ignore.case=T) & !grepl("announces|drawing", info$notes, ignore.case=T)
  return(info)
}