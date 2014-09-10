jeopardy-sabermetrics
=====================

See the corresponding Shiny app: https://jeopardy-win-probability.shinyapps.io/jwp-app/

### Scripts
* For scraping and processing games from J! Archive, run scripts/prepare_data/data_preparation.R. The output of this script is the workspace file needed for model fitting, stored at data/workspaces/prepared_data.RData
* The model I ended up using was tested using scripts/build_models/fit_gbm_cv.R and the final model was found with scripts/build_models/fit_gbm.R. The output of fit_gbm.R is stored at data/workspaces/gbm_model.RData
* Running scripts/prepare_for_shiny/save_workspace.R creates the workspace file that the shiny app loads, stored at shiny/shiny_workspace.RData.
* The shiny folder contains everything needed for the app

### Data
The data I scraped from the J! Archive can be found in the data/csv folder
