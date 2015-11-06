Jeopardy Win Probability
=====================

See the corresponding Shiny app: https://jeopardy-win-probability.shinyapps.io/jwp-app/

### Scripts
* For scraping and processing games from J! Archive, run scripts/prepare_data/data_preparation.R. The output of this script is the workspace file needed for model fitting, stored at data/workspaces/prepared_data.RData
* The model I ended up using was tested using scripts/build_models/fit_gbm_cv.R and the final model was found with scripts/build_models/fit_gbm.R. The output of fit_gbm.R is stored at data/workspaces/gbm_model.RData
* Running scripts/prepare_for_shiny/save_workspace.R creates the workspace file that the shiny app loads, stored at shiny/shiny_workspace.RData.
* The shiny folder contains everything needed for the app

### Data
The data I scraped from the J! Archive can be found in the data/csv folder

### Modeling
To find each player's odds of winning at a given time, their scores are sorted, leaving us with a top score, a middle score, and a bottom score. The following variables are then calculated:

* How far behind is the middle score from the top score (`top.score - middle.score`)
* How far behind is the bottom score from the top score (`top.score - bottom.score`)
* What percent of the top score is the middle score (`middle.score / top.score`)
* What percent of the top score is the bottom score (`bottom.score / top.score`)
* How much money is left on the board (If during the Jeopardy! Round, this includes the money that will be on the board during Double Jeopardy!)
* How many daily doubles are left on the board (If during the Jeopardy! Round, this includes the daily doubles that will be on the board during Double Jeopardy!)
* How many consecutive games has the top player won coming into today? (This is capped at 4 and if he/she isn't the defending champion, this is just 0.)
* How many consecutive games has the middle player won coming into today? (This is capped at 4 and if he/she isn't the defending champion, this is just 0.)
* How many consecutive games has the bottom player won coming into today? (This is capped at 4 and if he/she isn't the defending champion, this is just 0.)
* A measure of how close the top player is to being guaranteed a [lock-tie](http://www.j-archive.com/help.php#locktie) headed into Final Jeopardy! (calculated as `(top.score/2 - middle.score) / money.left`)
* A measure of how close the top player is to being guaranteed a [crush](http://www.j-archive.com/help.php#crush) headed into Final Jeopardy! (calculated as `(top.score*2/3 - middle.score) / money.left`)
* A measure of how close the top player is to being guaranteed the lead headed into Final Jeopardy! (calculated as `(top.score - middle.score) / money.left`)

The final 3 variables are all bound between 0 and 1 and do not take daily doubles into account.

Once these 11 variables were calculated, I fit 5,000 generalized boosting trees using the [gbm package](http://cran.r-project.org/web/packages/gbm/index.html) on all non-tie, non-tournament games. See the about tab of the [shiny app](https://jeopardy-win-probability.shinyapps.io/jwp-app/) for more explanations.

**Handling Ties**  
Since the first step in the process is to sort the scores of the three players, we run into issues when two or three of the players have the same score. If we arbitrarily assign one of the players to the top spot and the other player to the middle spot, the model will be biased toward the player we have designated as being on top, even if it knows that they have the same score. As a result, when finding the win probabilties of a game with two players tied, we find the predicted values twice, switching which spot we assigned to each of the tied players, and then average the values together.

**Model evaluation**  
There are a few methods I used to compare models:

* How often did a player gain money yet their chances of winning went down? (should be as small as possible)
* How often did players who were estimated to have an N% chance of winning actually go on to win (should be as close as possible to N for all values of N)
* Assuming cross-validation was done properly, `prod(eventual-winners-odds)` should be as large as possible

### Acknowledgments
Thanks to Alan and Michelle for their help.