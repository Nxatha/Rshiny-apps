#
# This is a Shiny web application that creates a Trashketball stats sheet

library(shiny)
library(DT)
library(ggplot2)
library(data.table)
library(shinythemes)
library(googlesheets4)
library(googledrive)
library(gargle)

options(gargle_oauth_cache = ".secrets",
        gargle_oauth_email = TRUE, email="youremail@id")


#set up a google sheet
#googlesheets4::gs4_create(name="PlayerScores")

# Authenticate and authorize using OAuth
drive_auth()

# Find the file using the sheet name
file <- drive_find(pattern = "PlayerScores")

# Extract the sheet ID
sheet_id <- file$id


# Define UI for application that collects player data, creates a data table 
#with points for each player and writes to google sheets data table
ui <- fluidPage(theme=shinytheme("united"),

    # Application title
    titlePanel("Trashketball Player Stats"),

    # Sidebar with input for name of child and stats
    sidebarLayout(
        sidebarPanel(
            textInput("fname", "First Name:"),
            numericInput("one_metre", "Number of shots from 1m (3ft):", 0, min=0, max=10 ),
            numericInput("two_metres","Number of shots from 2m(5-6ft):",0, min=0, max=10),
            actionButton("submitbutton", "Submit")
        ),

       
        
        mainPanel(
           # Show a table of  total points scored
           textOutput("score"),
           uiOutput("thankyoutext")
           # Download stats for players shots
           #downloadButton(outputId ="mydownload", label="Download player stats as CSV")
           
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
     
   #output data table with player stats
    output$score <- renderText({ 
    paste("Your Total Trashketball Score:", 2* input$one_metre + 3 * input$two_metres)
     })
    
    to_be_done_at_submit <- eventReactive(input$submitbutton, {
      #Collect data
      dtData <- data.table(cbind(name = input$fname, points = as.numeric(2* input$one_metre + 3 * input$two_metres)))
      print(dtData)
      #Put data on drive
      sheet_append(ss = sheet_id, 
                   data = dtData,
                   sheet = "Sheet1")
      
      #Say thankyou and direct to google sheets to view all data
      h5("Thanks for entering data. View all player scores", a("here",  href = "https://docs.google.com/spreadsheets/d/1aTSSx3il3DQHQTjlYV0u0G35cJ0lt1IVj_gr46lGZjQ/edit?usp=sharing"))
      
    
      
    })
    
    output$thankyoutext <- renderUI({
      to_be_done_at_submit()
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
