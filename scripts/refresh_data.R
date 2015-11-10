## Additional necessary steps for adding new season:
## 1. Update season.nums object in scripts/prepate_data/data_preparation.R
## 2. Update values in shiny/ui.R

# Run all scripts needed to refresh data
source("scripts/prepare_data/data_preparation.R")
source("scripts/build_models/fit_gbm.R")
source("scripts/prepare_for_shiny/save_workspace.R")

# Redeploy to ShinyApps (for help: http://shiny.rstudio.com/articles/shinyapps.html)
setwd("shiny/")
shinyapps::deployApp(appName="jwp-app")
