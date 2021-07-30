           
           # import AQI from www.aqi.info api
           
           # initialise ----------------------------------------------------------------
           # from https://www.r-bloggers.com/accessing-apis-from-r-and-a-little-r-programming/ 
           
           setwd('/home/jay/R/aqi/data/raw')
           library('tidyverse')
           library('jsonlite')
           library('httr')
           library('lubridate')
           library('sys')                                                        # not sure if this is needed
           
           northExtent <- 61.0
           southExtent <- 49.5
           eastExtent <- 2.0
           westExtent <- -10.5
           
           aqiStationsDF0 <- data.frame('stationIDX', 'lat', 'lon', 'name', 'url', stringsAsFactors = FALSE)
           
           
           # loop through AQI stations -------------------------------------------------
           
           goTime <- Sys.time()                # fullRange <- seq(0, 12000, by = 3000)   # top of range is 13295 broken into batches of 3000 queries to keep aqicn happy
           sectionSize <- 1000
           fullRange <- seq(0, 14000, by = sectionSize)       # UK stations start below ~2800
           
           for (idStart in fullRange){
              idRange <- idStart:(idStart + (sectionSize -1))      # one less than the range jump
              print(paste('First station ID in range is', idStart))
              idRangeString <- lapply(idRange, function(x) toString(x, width = NULL))                  # single-column DF of strings with a strange [[x]] CRLF [1] "3211" appearance
              aqiStationAddresses <- lapply(idRangeString[[1]], function(x) paste0("http://api.waqi.info/feed/@", idRangeString[], "/?token=SeeREADME.mdForHowToGetToken"))
           
              for (thisRow in 1:length(idRangeString)) {
                 thisStation <- aqiStationAddresses[[1]][thisRow]
                 print(paste('AQI station', thisStation))
                 try(response <- fromJSON(txt = thisStation), silent = TRUE)
                 checkCoords <- NULL
  
                      
                 if (response$status == "ok") {
                    try(checkCoords <- list(response$data$idx, response$data$city$geo[1], response$data$city$geo[2], response$data$city$name, response$data$city$url))# was   , silent = TRUE)
                    if (!is.null(response$data$city$geo[1]) & !is.null(response$data$city$geo[2])) {
  
                       # if statement to swap eastings with northings if necessary, happening on four occasions for Great Britain & Eire    
                       if ((southExtent < checkCoords[2] & northExtent > checkCoords[2] & eastExtent > checkCoords[3] & westExtent < checkCoords[3]) | 
                           (southExtent < checkCoords[3] & northExtent > checkCoords[3] & eastExtent > checkCoords[2] & westExtent < checkCoords[2])) {   # some station co-ordinates were entered as lon, lat
                          print(paste0(checkCoords[4], ' is in the bounding box.'))
                          fixLat <- response$data$city$geo[1]
                          fixLon <- response$data$city$geo[2]
                          if (fixLat < fixLon) {
                            fixLat <- response$data$city$geo[2]
                            fixLon <- response$data$city$geo[1]
                            print('Swapped latitude and longitude co-ordinates')
                        }
                        # swap section finished
                         
                         try(aqiStationsDF0[nrow(aqiStationsDF0) + 1,] <- list(response$data$idx, fixLat, fixLon, response$data$city$name, response$data$city$url), silent = TRUE)
                       } 
                       
                      else {
                          print(paste0(checkCoords[4], ' is out of bounds.'))
                       }
                       return
                    }
                 response$status <- "reset"   
                 }   
                 Sys.sleep(0.1)          # capital Sys
              }
              Sys.sleep(16.0)
           }
           setwd('~/c3/citiesAQIforGit/data/raw')
           write.csv(aqiStationsDF0, file = "StationLocations.csv", na = 'NA')
           stopTime <- Sys.time()
           timeTaken <- stopTime - goTime
           print(timeTaken) 