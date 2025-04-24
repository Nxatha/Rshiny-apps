import("sf")
import("raster")
import("stringr")
import("dplyr")
import("sp")
import("readxl")
import("ggplot2")
import("RColorBrewer")
import("leaflet")

#app.r , the school's QA shiny app, depends on this file
#get all data required, clean, merge and prepare for app

schools_mapping <- st_read("data/Schools/Schools.shp")
enrolmentRate<-load("data/enrolmentRate.RData")
teacher_studentRatio<-load("data/teacherStudentRatio.RData")
sanitationRatio<-load("data/sanitationData.RData")
#import county shape file
county_mapping<-st_read("data/Counties/County.shp")


# -----------Data Cleaning -----------

# change county names to upper case (levels reduced to 51)
toupper(schools_mapping$County)

# Recode tharaka nithi to tharaka-nithi and  Nairobi S,N, W to one county
schools_mapping$County <- recode_factor(schools_mapping$County, "NAIROBI SOUTH" = "NAIROBI", "NAIROBI NORTH" = "NAIROBI", "NAIROBI WEST" = "NAIROBI", "THARAKA NITHI" = "THARAKA-NITHI")


#check for na / missing County values in schools
print("Location of missing COUNTY allocated school locations")
which(is.na(schools_mapping$County))



#recode Tharaka to Tharaka Nithi and Keiyo-Marakwet to Elgeyo Marakwet
county_mapping$COUNTY <- recode_factor(county_mapping$COUNTY, "Tharaka" = "Tharaka Nithi", "Keiyo-Marakwet"="Elgeyo Marakwet")


#load all inducator  data from excel
enrolmentRate<-read_excel("data/clean education data.xlsx", sheet=1)
teacher_studentRatio<-read_excel("data/clean education data.xlsx", sheet=3)
sanitationRatio<-read_excel("data/clean education data.xlsx", sheet=2)

#extract data for overall students
ERall<- enrolmentRate[enrolmentRate$Gender == "Overall", ]
SRall<-sanitationRatio[sanitationRatio$Gender== "Overall", ]



#join the county_mapping data frame with ER , SR  and TR attributes on column County

county_mapping_merged<-merge(county_mapping, ERall, by.x="COUNTY", by.y="County")

county_mapping_merged<-subset(county_mapping_merged, select= -Gender)

county_mapping_ERSR<-merge(county_mapping_merged, SRall, by.x=c("COUNTY","Level"), by.y=c("County", "Level"))

county_mapping_all<-merge(county_mapping_ERSR, teacher_studentRatio, by.x=c("COUNTY", "Level", "Type"), by.y=c("County","Level", "Type"))


county_mapping_all<-subset(county_mapping_all, select= -Gender)
county_mapping_all$`Toilet-Student Ratio`<-round(as.numeric(county_mapping_all$`Toilet-Student Ratio`),1)


#calculate the centroid of each polygon in county_mapping data
centroids<-st_centroid(county_mapping_all)

#extract coordinates of the centroids
coords<-st_coordinates(centroids)

# Add the coordinates as separate columns to the data frame
county_mapping_all$lat <- coords[,"Y"]
county_mapping_all$lon <- coords[,"X"]

county_mapping_primary<- county_mapping_all %>% filter( Level == "Primary") #filter data to primary level for map display

pal_fun <- colorQuantile("Greys", NULL, n=9) #define color palette function
leaflet(county_mapping_primary) %>%
  addPolygons(stroke=TRUE,
              fillColor = ~pal_fun(`NET ER`),
              fillOpacity = 0.8, smoothFactor =0.5,
              color="white",
              label= ~COUNTY
  ) %>% addTiles()

# Delete rows with schools that have the wrong geometry points for later verification
schools_mapping_clean <- schools_mapping[-c(14614,28353,15717,26174,10355,6380),]
#delete object Id and code columns
schools_mapping_clean <- schools_mapping_clean[-c(1,2)]


#rename coords to lon and lat
schools_mapping_clean <- schools_mapping_clean%>% 
  rename("lon" = "X_Coord")
schools_mapping_clean<- schools_mapping_clean %>% 
  rename("lat" = "Y_Coord")


