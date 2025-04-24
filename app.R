library("modules")
import("shiny")
import("shiny.semantic")
import("semantic.dashboard")
import("classInt")



#load data that will be used in the app
getMyData<- use("Map school data.R")
county_mapping_primary<-getMyData$county_mapping_primary
county_mapping_all<-getMyData$county_mapping_all
schools_mapping_clean<-getMyData$schools_mapping_clean

# Here we define the grid_template that we will pass to our grid
myGrid <- grid_template(
  default = list(
   
     # define the data.frame describing our layout
    areas = rbind(
      c("header", "header", "header"),
      c("value", "value1", "value2"),
      c("space","space","space"),
      c("map",   "map",   "main"),
      c("space1","space1","space1"),
      c("download1","download2", "download2")
      

    ),
    #  define the dimensions of rows and columns of the layout
    rows_height = c("50px", "50px", "50px", "400px","50px","300px"),
    cols_width = c("1fr", "1fr", "1fr")
  )
)
# define another grid_template to use in one of the elements of the parent grid
subGrid <- grid_template(
  default = list(
    areas = rbind(
     "supertop", "top","middle", "bottom"
    ),
    rows_height = c("10", "30%", "30%","30%" )
  )
)

ui <- semanticPage(

  grid(myGrid,
       # define the css style of the grid using container_style
       container_style = "",
       # define the css style of each of the grid elements using area_styles
       area_styles = list(header = "",
                          value="",
                          value1="",
                          value2="",
                          space="",
                          map = "",
                          main = "",
                          space1="",
                          download1= "",
                          download2=""),
       # define the ui content we would like to have inside each element
       header = div(class = "ui inverted black segment",
                        img(src="kenyaflag.png", height = 20, width = 35, hspace= 5,
                            "Kenya Schools Data Mapping",style="float:left")),
       space = div(""),
       
       value =  box(
         title = "Select County", 
         ribbon= FALSE, 
         title_side = "top left",
         collapsible= TRUE, 
         color = "green",
         dropdown_input("county_dropdown",choices=unique(county_mapping_all$COUNTY), value = "Nairobi")),
       
       #define the dropdown input content to be displayed in the value boxes
       value1 =  box(
         
         title = "School Level", 
         ribbon= FALSE, 
         title_side = "top left", 
         collapsible= TRUE, 
         color = "green",
         dropdown_input("levels_dropdown",choices=unique(county_mapping_all$Level), value = "Primary")),
         

       value2 =  box(
         
         title = "School Type", 
         ribbon= FALSE, 
         title_side = "top left", 
         collapsible= TRUE, 
         color = "green",
         dropdown_input("type_dropdown", choices=unique(county_mapping_all$Type), value = "Public")),
      
       #define the UI content to be displayed in value boxes
        main = grid(subGrid,
                    area_styles = list(
                      supertop="",
                      top="",
                      middle="",
                      bottom=""
                    ),
                    supertop="",
                    top =  value_box(
                      subtitle = "ENROLMENT RATE",
                      value = textOutput("valueER"),
                      color = "green"
                      ),
                    middle = value_box(
                      subtitle = "STUDENT-TEACHER RATIO",
                      value = textOutput("valueTSR"),
                      color = "green"
                    ),
                    bottom = value_box(
                      subtitle = "TOILET-STUDENT RATIO",
                      value = textOutput("valueSR"),
                      color= "green"
                    )
                    ),

       
       map =  div(
                leafletOutput("plot")
              ),

       
       space1= div(""), #spacing row between layout elements
       
       download1= div(
         selectInput("dataset", "Choose a dataset:",
                     choices= c("Enrollment Rates 2020","Student-Teacher Ratios 2020", "Sanitation Ratios 2020", "Schools Data 2007-2016")),
         downloadButton("downloadData", "Download")),
       
       download2= div(
         semantic_DTOutput("table")
       )
         
  )
  
)


server <- function(input, output, session) {
  
  options(shiny.app_idle_timeout = 0)  # Disable app idle timeout
  
  #pal_fun <- colorQuantile("Greys", NULL, n=9) #define color palette function
  ERranges<-classIntervals(county_mapping_primary$`NET ER`,n=9,style="quantile") #define NET ER ranges to display on legend
  

  
  #plot leaflet map of counties in kenya
  output$plot <- renderLeaflet({
    
    leaflet(county_mapping_primary) %>%
      addPolygons(stroke=TRUE,
                  fillColor = ~pal_fun(`NET ER`),
                  fillOpacity = 0.8, smoothFactor =0.5,
                  color="white",
                  label= ~COUNTY
                  ) %>% 
      addLegend("bottomright",  # location
                colors= brewer.pal(9, "Greys"),    # palette function
                labels = paste0("up to ", format(ERranges$brks[-1], digits=2)),  # value to be passed to palette function
                title = 'Net Enrollment Rates - Primary School by County') %>% # legend title
      addTiles()
    
  })
  

  # A reactive expression for the coordinates of the selected county
  selected_coords <- reactive({
    county_mapping_primary[county_mapping_primary$COUNTY == input$county_dropdown, c("lon","lat")]
  })
  
  #Observe the dropdown input change and  highlight/fly to selected county , adding markers
  observeEvent(input$county_dropdown,{
    
    selected_schools<-schools_mapping_clean %>% filter( County == input$county_dropdown & LEVEL == input$levels_dropdown & Status == input$type_dropdown) 
    
    leafletProxy("plot", session)  %>% clearMarkers() %>%
      flyTo(lng=unique(selected_coords()$lon), lat=unique(selected_coords()$lat), zoom=6) %>% #fly to county
      addMarkers(lng=selected_schools$lon, lat=selected_schools$lat, data=selected_schools, label= ~SCHOOL_NAM, layerId = ~SCHOOL_NAM)
  
  })
  observeEvent(input$levels_dropdown,{
    
    selected_schools<-schools_mapping_clean %>% filter(County == input$county_dropdown & LEVEL == input$levels_dropdown & Status == input$type_dropdown) 
    
    leafletProxy("plot", session) %>% clearMarkers() %>%
      addMarkers(lng=selected_schools$lon, lat=selected_schools$lat,  data=selected_schools, label= ~SCHOOL_NAM, layerId = ~SCHOOL_NAM  )  
  })
  observeEvent(input$type_dropdown,{
    
    selected_schools<-schools_mapping_clean %>% filter(County == input$county_dropdown & LEVEL == input$levels_dropdown & Status == input$type_dropdown) 
    
    leafletProxy("plot", session) %>% clearMarkers() %>%
      addMarkers(lng=selected_schools$lon, lat=selected_schools$lat,  data=selected_schools,label= ~SCHOOL_NAM, layerId = ~SCHOOL_NAM, ) 
  })

  
  #update value boxes output on drop down Input select
  ER <- reactive({
    county_mapping_all %>% filter(COUNTY == input$county_dropdown & Level == input$levels_dropdown) %>% pull(`NET ER`)
  })
  TSR<- reactive({
    county_mapping_all %>% filter(COUNTY == input$county_dropdown & Level == input$levels_dropdown & Type ==input$type_dropdown) %>% pull(`Student-Teacher Ratio`)
  })
  SR<- reactive({
    county_mapping_all %>% filter(COUNTY == input$county_dropdown & Level == input$levels_dropdown & Type ==input$type_dropdown) %>% pull(`Toilet-Student Ratio`)
  })
  
  #render the values to be displayed in value boxes as text output
  output$valueER<-renderText({
    
    ifelse(is.null(input$county_dropdown), "78", ER())
    ifelse(is.null(input$county_dropdown) && input$levels_dropdown =="Secondary","54", ER())
    
  })
  output$valueTSR<-renderText({
    ifelse(is.null(input$county_dropdown), "40", TSR())
    ifelse(is.null(input$county_dropdown) && input$levels_dropdown =="Secondary","29", TSR())
  
  })
  output$valueSR<-renderText({
    ifelse(is.null(input$county_dropdown), "31", SR()) 
    ifelse(is.null(input$county_dropdown) && input$levels_dropdown =="Secondary","20", SR())
    
  })
  
  
  #Reactive values for selected datasets to be displayed for download
  datasetInput <- reactive({
    switch(input$dataset, 
           "Enrollment Rates 2020"=getMyData$enrolmentRate,
           "Student-Teacher Ratios 2020"=getMyData$teacher_studentRatio,
           "Sanitation Ratios 2020"=getMyData$sanitationRatio,
           "Schools Data 2007-2016"=schools_mapping_clean
           )
  })
  
  #display selected dataset
  output$table <- DT::renderDataTable({
    datasetInput()
  })
  
  #download data as.csv
  output$downloadData <- downloadHandler(
    filename = function(){
      paste(input$dataset, ".csv", sep="")
    },
    content = function (file){
      write.csv(datasetInput(), file, row.names=FALSE)
    }
  )
  
  
}

shinyApp(ui = ui, server = server)