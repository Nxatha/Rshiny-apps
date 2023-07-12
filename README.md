# Rshiny-apps
Creating apps in R shiny with different functionality

## The Trashketball App 
My first shiny app: Collects user scores, calculates points and stores data in google sheets. A children's game to learn terms used in Data Science: Data Collection, Data Sets and Tables as part of a Data Curiosity program for children aged 12-16

Link to published app: https://nxatha.shinyapps.io/TrashketballChallenge/

### Functionality
User Interface - User enters their name, number of shots they made into trash can within a 1 meter( 3 feet range) and number of shots they made at approx 2m (5 -6 feet range)

On Submit - Server calculates the points earned by user as (2 * shots made at 1 meter) + (3 * shots made at 2m)

Output - Number of points earned and a link to the collected dataset of all users on google sheets.

## The Mining Stock Data app
This is a UDEMY course project app which displays and calculates the valuation of a mining company based on the calculated score of its stocks (plots of land owned : Graded 1 to 3 based on level of minerals found in plot).
This score is weighted differently by different companies.

Link to published app: https://nxatha.shinyapps.io/course_project/

### Functionality
Input:

🎯 Using sliders, you can adjust weights and produce different calculated scores/valuations for each company visualized in the scatter chart.

🎯 You can select points on the chart to view a table selection of interesting points (companies of interest).

🎯 You can then download the selected data to csv.

🎯 You can view the original data in a separate tab



