# 2 Buffer Analysis
# https://geodacenter.github.io/opioid-environment-toolkit/buffer_analysis.html

# 1 read in data
metClinics <- st_read("data/methadone_clinics.shp")
areas <- st_read("data/chicago_zips.shp")
# You can often find shapefiles (or spatial data formats like geojson) on
#city data portals for direct download.
cityBoundary <- st_read("data/boundaries_chicago.geojson")

head(areas)

# 2 create an overlay map
tmap_mode("plot") # view data in static format

tm_shape(areas) + tm_borders(alpha = 0.4) + # 1st layer
  tm_shape(metClinics) + tm_dots(size = 0.4, col = "darkgreen") # 2nd layer

# 3 spatial transformation
# metadata has to be the same for both points and areas
st_crs(metClinics)
st_crs(areas)
# result: they aren't encoded the same way 

# 4 transform crs with a crs that preserves distance
CRS.new <- st_crs("EPSG: 3435")

metClinics.3435 <- st_transform(metClinics, CRS.new)
areas.3435 <- st_transform(areas, CRS.new)

head(metClinics.3435)
head(areas.3435)
# both crs are the same

# 5 generate buffers
metClinicBuffers <- st_buffer(metClinics.3435, 5280) # 5280 ft = 1 mile

tmap_mode("plot")

tm_shape(areas) + tm_borders(alpha = 0.6) +
  tm_shape(metClinicBuffers) + tm_fill(col = "pink2", alpha = .4) + 
  (col = "pink2") + tm_shape(metClinics.3435) + 
  tm_dots(col = "purple",  size = 0.2) 

# 6 buffer union
unionBuffers <- st_union(metClinicBuffers) # flattens all buffers into one

tm_shape(areas) + tm_borders(alpha = 0.6) +
  tm_shape(unionBuffers) + tm_fill(col = "blue", alpha = .2) + 
  (col = "blue") + tm_shape(metClinics.3435) + 
  tm_dots(col = "purple") 

# 7 two mile
metClinic_2mbuffers <- st_buffer(metClinics.3435, 10560)

tm_shape(areas, bbox=cityBoundary) + tm_borders(alpha = 0.2) +
  tm_shape(cityBoundary) + tm_borders(lwd = 1.5) +
  tm_shape(metClinic_2mbuffers) + tm_fill(col = "gray10", alpha = .4) + tm_borders(col = "dimgray", alpha = .4) +
  tm_shape(metClinicBuffers) + tm_fill(col = "gray90", alpha = .4) + tm_borders(col = "darkslategray") +
  tm_shape(metClinics.3435) + tm_dots(col = "purple",  size = 0.2) +   
  tm_layout(main.title = "Methadone Clinic Service Areas in Chicago",
            main.title.position = "center",
            main.title.size = 1,
            frame = FALSE)

# 8 interactive map
tmap_mode("view")

tm_shape(areas) +  tm_borders(alpha = 0.5, col="gray")+ tm_text("GEOID10", size = 0.7) +
  tm_shape(cityBoundary) + tm_borders() +
  tm_shape(unionBuffers) + tm_fill(col = "pink", alpha = .2) + tm_borders(col = "pink") +
  tm_shape(metClinics.3435) + tm_dots(col = "purple") 
