# 1 Geo Coding Addresses
# 1 geocoding addresses of locations
# guide: https://geodacenter.github.io/opioid-environment-toolkit/geocodingAddress-tutorial.html

library(sf)
library(tmap)
library(tidygeocoder)
library(mapview)

# 1 read in csv
methadoneClinics <- read.csv("data/chicago_methadone_nogeometry.csv")
head(methadoneClinics)

# 2 geocode addresses

# keep in mind that some geocoder services have their pros and cons;
#if one doesn't work then try a different one

# test geocoding service
test <- geo("4545 North Broadway St. Chicago, IL",
            lat = latitude, long = longitude, method = 'cascade')
test

# 3 prepare the input parameters for geocoding multi addresses
str(methadoneClinics)

methadoneClinics$fullAdd <- paste(as.character(methadoneClinics$Address), 
                                  as.character(methadoneClinics$City),
                                  as.character(methadoneClinics$State), 
                                  as.character(methadoneClinics$Zip))
# turn all to character type to avoid issues with factors
head(methadoneClinics)

# 4 batch geocoding
geoCodedClinics <- methadoneClinics |>
  geocode(address = 'fullAdd', lat = latitude, long = longitude, method = 'cascade')

geoCodedClinics

# 5 convert to spatial data
methadoneSF <- st_as_sf(geoCodedClinics, coords = c("longitude", "latitude"),
                        crs = 4326)
head(data.frame(methadoneSF))

# 6 visualize points
tmap_mode("view") # switch to viewing mode

tm_shape(methadoneSF) +
  tm_dots() +
  tm_basemap("OpenStreetMap")

mapview(methadoneSF$geometry)

mapview(methadoneSF, xcol = "longitude", ycol = "latitude",
        crs = 4326, grid = F)

# save data
write_sf(methadoneSF, "data/methadone_clinics.shp")
