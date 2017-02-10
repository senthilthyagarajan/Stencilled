# foursquareASD will create a map of ASD locations across the United States

library(RJSONIO)
library(RCurl)

options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl")))

# First, read in file with latitudes and longitudes of major cities
# Obtained from http://notebook.gaslampmedia.com/download-zip-code-latitude-longitude-city-state-county-csv/
ll = read.csv('C:/Users/senth/Downloads/zip_codes_states.csv',sep=",",head=TRUE)
clientid = "2CO1VJ24A5P0PK4UFN4J4AWDZIZEY24FYL0SUGM2DT2QZMNK"
clientsecret = "LU1PBJ51OKTVCJ3HO41QCUWRUHJ3OVIDJ3UATSSRBZAGEAHR"

venue_name = c()
venue_lat = c()
venue_long = c()
venue_city = c()
venue_state = c()
venue_country = c()
venue_checkins = c()
venue_users = c()
venue_hasMenu = c()
venue_rating = c()
venue_postalCode = c()
venue_usersCount = c()
venue_formattedAddress = c()


# hasMenu
# rating
# postalCode
# usersCount
# formattedAddress


for (i in 1:dim(ll)[1]) {
  lat = ll$latitude[i]
  long = ll$longitude[i]
  
  # Do query and parse results
   query = paste("https://api.foursquare.com/v2/venues/explore?client_id=",clientid,"&client_secret=",clientsecret,"&ll=",lat,",",long,"&query=food&v=20170131",sep="")
  result = getURL(query)
  data <- fromJSON(result)
  
  # For each result, save a bunch of fields, you can tweak this to your liking
  if (length(data$response$groups[[1]]$items) > 0) {
    for (r in 1:length(data$response$groups[[1]]$items)) {
      tmp = data$response$groups[[1]]$items[[r]]$venue
      venue_name = c(venue_name,tmp$name)
      venue_lat = c(venue_lat,tmp$location$lat)
      venue_long = c(venue_long,tmp$location$lng)
      venue_city = c(venue_city,tmp$location$city)
      venue_state = c(venue_state,tmp$location$state)
      venue_country = c(venue_country,tmp$location$country)
      venue_checkins = c(venue_checkins,tmp$stats[1])
      venue_hasMenu = c(venue_hasMenu,tmp$hasMenu)
      venue_rating = c(venue_rating,tmp$rating)
      # venue_shortName = c(venue_shortName,tmp$shortName)
      
    }
  }
}

# SAVE RESULT
save(venue_name,venue_lat,venue_long,venue_city,venue_state,venue_country,venue_checkins,venue_hasMenu ,venue_rating ,file='venuesResult.RData')

# Note - depending on your internet connection (and the API), the above loop can hit a snag every now and then.  I chose to let it hit, and then continue at the index where I left off.  For this reason, there could be duplicate results.

# # Put in nice data frame
# data = as.data.frame(cbind(venue_checkins,venue_name,venue_lat,venue_long,venue_hasMenu ,venue_rating ))
# #write.csv(data,file = "MyData.csv")
# 
# 
# # Find duplicate results
# dsub = subset(data,!duplicated(data))
# names(dsub) = c("latlong","checkins","name","latitude","longitude","rating")

data = as.data.frame(cbind(locationvar,venue_checkins,venue_name,venue_lat,venue_long,venue_checkins,venue_users))

# Find duplicate results
dsub = subset(data,!duplicated(data))
names(dsub) = c("latlong","checkins","name","latitude","longitude")

# Export to file so we can use in Google Fusion Table
tabley = dsub[,1:6]
write.table(tabley,file="import.csv",quote=TRUE,sep=",",row.names=FALSE)
write.csv(tabley,file = "Austin_Foursquare.csv")
