# Rshiny-apps
Creating apps in R shiny with different functionality

## [The Trashketball App](https://nxatha.shinyapps.io/TrashketballChallenge/) 
My first shiny app: Collects user scores, calculates points and stores data in google sheets. A children's game to learn terms used in Data Science: Data Collection, Data Sets and Tables as part of a Data Curiosity program for children aged 12-16

### Functionality
User Interface - User enters their name, number of shots they made into trash can within a 1 meter( 3 feet range) and number of shots they made at approx 2m (5 -6 feet range)

On Submit - Server calculates the points earned by user as (2 * shots made at 1 meter) + (3 * shots made at 2m)

Output - Number of points earned and a link to the collected dataset of all users on google sheets.


## The Mining Stock Data app
This is a UDEMY guided course project app which displays and calculates the valuation of a mining company based on the calculated score of its stocks (plots of land owned : Graded 1 to 3 based on level of minerals found in plot).
This score is weighted differently by different companies.

![mining stock](https://github.com/Nxatha/Rshiny-apps/assets/105219482/4895a0b5-8e86-4927-a90f-c33683184350)

### Functionality
Input:

🎯 Using sliders, you can adjust weights and produce different calculated scores/valuations for each company visualized in the scatter chart.

🎯  Using a brush tool: You can select points on the chart to view a table selection of interesting points (companies of interest).

🎯 You can then download the selected data to csv.

🎯 You can view the original data in a separate tab


## [The Early birth and Education shiny app](https://nxatha.shinyapps.io/birthedu/)

This app looks at 1980-2022 time series data on early births (Births by Age of Mother 15-19) and enrollment drop rates.

![shinyapp](https://github.com/Nxatha/Rshiny-apps/assets/105219482/78973f03-5014-46a0-b24e-431cc8fc88a3)

### Functionality

🎯 Using sliders you can slect the age of mother and the years of interest for all existing data on mothers aged 15-19 from 1980 -2022

🎯 The second tab contains plots (ggplot2) that look at a comparison between time series of early births 2018-2022 and enrollment drop rates 2018-2022

🎯 The third tab plots (ggplot2) the static correlation between the two variables

🎯 The 4th tab provides aggregated data from 2018-2022 to view and download as csv.





