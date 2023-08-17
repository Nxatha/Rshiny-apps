library(shiny)
library(DT)
library(shinythemes)
library(dplyr)
library(ggplot2)
library(data.table)
library(forecast)
library(ggpubr)


#load all birth data 1980-2022
load("fD_all.RData")


#load analysis data 2018-2022
load("trendData2.RData")

# create median births time series
attach(trendData2)

trend.ts<-ts(sumBirths, start=2018, end=2022, frequency=1)

# plot enrolment drop rate time series
trend.ts.enrolment<-ts(droprate, start=2018, end=2022, frequency=1)

#create new df with log of births and check correlation with droprates
newDF<-trendData2 %>% mutate(logBirths=round(log(sumBirths),2))

# Define UI for application with 4 tabs: 3 plot tabs and 1 data download tab, 
ui <- fluidPage(theme=shinytheme("sandstone"),
                
                titlePanel("Kenya Early Births Time Series"),
                # Sidebar with a slider input for Years 
                sidebarLayout(
                  sidebarPanel(
                    sliderInput("years",
                                "Select Years:",
                                min = 1980,
                                max = 2022,
                                value=2002
                    ),
                    sliderInput("ages",
                                "Select Age of Mother",
                                min = 15, 
                                max = 19,
                                value = 19
                    )
                  ),
                  
                  # Show a plot of the generated distribution
                  mainPanel(
                    tabsetPanel(
                      tabPanel("Median Early Births",
                               plotOutput("birthsPlot")
                      ),
                      tabPanel("Births vs Basic Education enrollment",
                               plotOutput("birth.edu.plot") #timeseries plots
                               
                      ),
                      tabPanel("Correlation plot",
                               plotOutput("correlationplot") #correlation plots
                      ),
                      tabPanel("Data",
                               dataTableOutput("tableDT"),
                               downloadButton(outputId ="mydownload", label="Download Data as CSV")
                               
                      )
                      
                    )
                  )
                  
                  
                )
                
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  attach(finalData_all)
  
  
  #generate output plot of births for tabpanel 1
  output$birthsPlot <- renderPlot({
    # generate data based on input$years and input$ages from ui.R
    x    <- finalData_all[, 1]
    a    <- finalData_all[, 2]
    years <- seq(min(x),input$years)
    moms <-seq(min(a),input$ages)
    selectyears<-subset(finalData_all, Year %in% years)
    selectyears2<-subset(selectyears, Age.of.Mother %in% moms)
    
    
    # draw the time series with the specified years
    ggplot(selectyears2, aes(x=Year, y=Births, group=Age.of.Mother))+
      geom_line(aes(colour=Age.of.Mother))+geom_text(size=3,aes(label=Age.of.Mother))+
      ggtitle("Median Births by Age of Mother") +
      theme(panel.grid.major = element_line(linetype = "blank"),
            panel.grid.minor = element_line(linetype = "blank"),
            axis.text.x = element_text(size = 7),
            plot.title = element_text(family = "mono"),
            legend.position = "bottom", legend.direction = "horizontal") + 
      theme(axis.text.y = element_text(size = 8)) + theme(plot.caption = element_text(family="mono", hjust = 0.5)) +labs(caption = "Median births by Age of Mother from UNPD database . 2022 data not aggregated into medians on website was aggregated here 
during the data cleaning process for the purpose of analysis")
  })
 
  
  
  #generate births and basic education plots for tabPanel 2
  output$birth.edu.plot <- renderPlot({
    attach(trendData2)
    
    trend.ts<-ts(sumBirths, start=2018, end=2022, frequency=1)
    
    g2<-autoplot(trend.ts, ylab="Median Early Births ")+
      geom_label(size=4, aes(label=sumBirths))+
      ggtitle("Median births per year for mothers aged 15-19") + theme(panel.grid.major = element_line(linetype = "blank"),
                                                                       panel.grid.minor = element_line(linetype = "blank"),
                                                                       plot.title = element_text(family = "mono")) + theme(plot.caption = element_text(family="mono",hjust=0.5))+labs(caption = "Calculated of Median of all early births per Year. 
Data populated from UNPD website years 2018-2022")
    
    
    
    g3<-autoplot(trend.ts.enrolment, ylab="drop rate", colour="red")+geom_label(size=4, aes(label=droprate))+
      ggtitle("Enrollment drop rate ") + theme(plot.subtitle = element_text(family = "mono"),
                                               plot.caption = element_text(family = "mono"),
                                               panel.grid.major = element_line(linetype = "blank"),
                                               panel.grid.minor = element_line(linetype = "blank"),
                                               plot.title = element_text(family = "mono")) + theme(plot.caption = element_text(hjust = 0.5)) +labs(caption = "Drop rate dr = (sec.enrolment-pri.enrolment)/pri.enrolment 
Data from KNBS Economic Survey for years 2018-2022")
    
    #plot side by side
    ggarrange(g2,g3, ncol=2,nrow=1)
  })
  
  attach(newDF)
  
  #generate scatterplot for tabPanel 3
  output$correlationplot<-renderPlot({
    
    ggscatter(newDF, x = "logBirths", y = "droprate",
              color = "red", cor.coef = TRUE,
              cor.coeff.args = list(method = "spearman", label.x.npc = "left", label.y.npc = "bottom"),
              xlab = "Log of Median early births", ylab = "Enrolment drop rate",
              title="Correlation method = Spearmans ranked correlation coefficient ")+
      geom_smooth(method=lm)+theme(plot.title=element_text(family = "mono"))+
      theme(plot.caption = element_text(family="mono", hjust = 0.5)) +labs(caption = "Scatterplot: Log of births versus drop rate.  R = -0.87
  This shows a clear negative relationship but p.value>0.05 indicates its not significant
      Next step should be examining a predictive relationship using a GARCH model
            since our time series data exhibits a non-constant variance and mean")
    
  })
  
  
  #create reactive data frame
  colnames(newDF)<-c("Year", "droprate", "medianBirths","logBirths")
  birth.edu.data<-reactive(data.frame(newDF))
  
  #generate new data table from birth * enrollment data for tab panel 4
  output$tableDT <- DT :: renderDataTable(DT::datatable(birth.edu.data()))
  
  #create download feature for selection data table
  output$mydownload <- downloadHandler(
    filename="dataextract.csv",
    content=function(file){
      write.csv(birth.edu.data(),file)
    })
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)
