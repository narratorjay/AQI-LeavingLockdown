        # get AQI data for UK stations from www.aqi.info api 

        library('tidyverse')
        library('jsonlite')
        library('httr')
        library('lubridate')
        library('sys')
        
        fnNULLtoNA <- function(pollutantValue)
          if (is.null(pollutantValue)) {
            score <- NA
          } else {
            score <- pollutantValue
          }
          return(score)
        
        setwd('~/c3/citiesAQIforGit/data/raw')
        boxStations <- read.csv('StationLocations.csv')
        boxID <- boxStations[,c('stationIDX')]
        
        for (islandRun in 1:80){
          stnReports <- data.frame('idx', 'humidity', 'pressure', 'temp', 'dominant', 'pm10', 'pm2-5', 'co', 'no2', 'o3', 'so2', 't-local', 't-zone', 't-univ', 't-iso', stringsAsFactors = FALSE)
          goTime <- Sys.time() 
          
          for (i in 1:length(boxID)) {
            waqiAccess <- paste0("http://api.waqi.info/feed/@", boxID[i], "/?token=SeeREADME.mdForHowToGetToken")
            try(APIreply <- fromJSON(txt = waqiAccess), silent = TRUE)
            if (APIreply$status == "ok") {
              print(paste(APIreply$data$city$name, "- station ID", APIreply$data$idx))   
              try(stnReports[nrow(stnReports) + 1,] <- list(APIreply$data$idx, APIreply$data$iaqi$h$v, APIreply$data$iaqi$p$v, APIreply$data$iaqi$t$v, APIreply$data$dominentpol, fnNULLtoNA(APIreply$data$iaqi$pm10$v), fnNULLtoNA(APIreply$data$iaqi$pm25$v), fnNULLtoNA(APIreply$data$iaqi$co$v), fnNULLtoNA(APIreply$data$iaqi$no2$v), fnNULLtoNA(APIreply$data$iaqi$o3$v), fnNULLtoNA(APIreply$data$iaqi$so2$v), APIreply$data$time$s, APIreply$data$time$tz, APIreply$data$time$v, APIreply$data$time$iso), silent = TRUE)
            }
            Sys.sleep(0.1)
          }
          
          csvName <- paste0(format(now(), "%Y%m%d_%H%M"), "aqiUKEire.csv")
          write.csv(stnReports, csvName, na = 'NA', col.names = FALSE)

          print(paste('Saved csv', islandRun))
          stopTime <- Sys.time()
          timeTaken <- stopTime - goTime
          ###print(paste('Run', islandRun, 'took', sprintf("%.1f", timeTaken), 'minutes'))
          
          Sys.sleep(750)  # wait twelve-and-a-half minutes, gives roughly half-hour intervals because it takes ~16 mins to get 308? stations data
        }