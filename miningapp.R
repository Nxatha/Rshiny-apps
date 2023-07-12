# R shiny UDEMY course project:: Mining data

library(shiny)
library(shinythemes)
library(DT)
library(ggplot2)


# get mining data
data<-read.csv("course_proj_data.csv", header=TRUE,sep=";" )
               
# Define UI for application with sliders, plot with brush feature and data table
ui <- fluidPage(theme=shinytheme("sandstone"),
    
    # Application title
    titlePanel("The Mining Stock Scale"),

        # Create 3 tabs one for app, documentation, downloadable data table
        mainPanel(
          tabsetPanel(
            tabPanel("ADJUST YOUR MINING STOCKS",
                     sliderInput("Weight1", "Weight on Grade 1",
                                 min = 0, max = 20,
                                 value = 7),
                     sliderInput("Weight2", "Weight on Grade 2",
                                 min = 0, max = 20,
                                 value = 6),
                     sliderInput("Weight3", "Weight on Grade 3",
                                 min = 0, max = 6,
                                 value = 0.8),
             plotOutput("scat", brush= "myBrush"),
             dataTableOutput("selectionDT"),
             downloadButton(outputId ="mydownload", label="Download Selected Data as CSV")        
            ),
            tabPanel("DATA TABLE WITH UNDERLYING DATA",
            dataTableOutput("tableDT"))
        )
    )
)

attach(data)
# Define server logic required to plot calculated score and market capital
server <- function(input, output) {

  #Formatted data table for table tab 
  output$tableDT <- DT:: renderDataTable(DT::datatable(data) %>% 
                                            formatCurrency("MarketCap.in.M", "$",digits=0))
                                          
  #calculate scores (x axis of plot) = weight * Grade value and add as new column to data
  weight.data =reactive(cbind(data, points= input$Weight1 * G1 + input$Weight2 * G2 + input$Weight3 * G3))
                                         
   
  #create scatter plot with x axis = score, y axis = Market Capital in Millions
  output$scat = renderPlot({
    ggplot(weight.data(), aes(points, MarketCap.in.M))+geom_point()+geom_smooth(method="lm")+ xlab("Your Calculated Score")+ ylab("Market Capitalization in Million USD")
  })  
  
  #use brush feature for selecting observations on plot
  newdata =reactive({
  myBrush <- input$myBrush
  selection<- brushedPoints(weight.data(),myBrush)
  return(selection)
  })
  
  #create new data table with brush selection
  output$selectionDT <- DT :: renderDataTable(DT::datatable(newdata()))
  
  #create download feature for selection data table
  output$mydownload <- downloadHandler(
    filename="plotextract.csv",
    content=function(file){
      write.csv(newdata(),file)
    })
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)
