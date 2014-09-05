jeopardy-sabermetrics
=====================

See the corresponding Shiny app: https://jeopardy-win-probability.shinyapps.io/jwp-app/

For scraping and processing games from J! Archive, run Scripts/Prepare_Data/data_preperation.R  
The model I ended up using was tested using Scripts/Models/fit_gbm_cv.R and the final model was found with Scripts/Models/fit_gbm.R  
Running Scripts/For_Shiny/save_workspace.R creates the workspace file that the shiny app loads.  
The shiny/ folder contains everything needed for the app  