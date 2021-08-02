library(tidyverse)
library(maps)
library(ggplot2)
library(readr)
#library(rgdal)     # produces a recurring error message in RStudio that seems to make no difference
library(dplyr)
library(maptools)   # needs to be installed but is not called

options(stringsAsFactors = FALSE)

# map boundaries are determined by furthermost AQI stations in each compass direction:
# Inverness, N; Norwich, E; Plymouth, S; Claremorris, W
# first remove AQI stations in France included the bounding box used by the FindAQIstations... script

setwd('~/c3/citiesAQIforGit/data/raw')
#StationLocations <- read_csv('StationLocations202107.csv') # has fewer monitoring stations, was the list cleaned?
StationLocations <- read_csv('ukEireAqiStations202012.csv')
StationLocations <- StationLocations[ grep('france', StationLocations$url, invert = TRUE) , ]

# graphical work
CleanBase <- 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        panel.background = element_rect(fill = 'white', colour = 'white'), 
        axis.line = element_line(colour = 'white'), legend.position = 'none',
        axis.text.x = element_blank(), axis.ticks.x = element_blank(),
        axis.text.y = element_blank(), axis.ticks.y = element_blank())

GBIbase <- map_data('world', c('Ireland', 'UK', 'Isle of Man'), xlim = c(-9.2, 1.5), ylim = c(50.1, 57.7) )

ggplot() + 
  CleanBase +
  geom_polygon(data = GBIbase, aes(x = long, y = lat, group = group), color = 'darkturquoise', fill = 'khaki') +
  coord_map(projection = 'sinusoidal', xlim = c(-8.5, 0.8), ylim = c(50.3, 57.4)) +
  xlab(NULL) + ylab(NULL) +
  geom_point(data = StationLocations, aes(x = lon, y = lat), colour='#002200', fill='#002200', pch=16, size=2, alpha=I(0.4))
