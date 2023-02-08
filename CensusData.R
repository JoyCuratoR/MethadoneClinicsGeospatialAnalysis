# 4 Census Data Wrangling
# guide: https://geodacenter.github.io/opioid-environment-toolkit/getACSData-tutorial.html#CD-get-geometry

library(sf)
library(tidycensus)
library(tidyverse)
library(tigris)

# 1 enable census API key
census_api_key("243fc8635fafa1e6900a49096b1fa3557dabd968", install = T)
Sys.getenv("CENSUS_API_KEY")

# each data or table has a variable ID
#see guide's appendix for more info

# 2 retrieving state level data
stateDf <- get_acs(geography = 'state', variables = c(totPop18 = "B01001_001", 
                                                      hispanic ="B03003_003", 
                                                      notHispanic = "B03003_002",
                                                      white = "B02001_002", 
                                                      afrAm = "B02001_003", 
                                                      asian = "B02001_005"),
                   year = 2018, state = 'California', geometry = FALSE) 
head(stateDf)

# 3 cleaning data
stateDf <- stateDf |>
  select(GEOID, NAME, variable, estimate) |>
  pivot_wider(names_from = variable, values_from = estimate) |>
  mutate(hispPr18  = hispanic/totPop18, whitePr18 = white/totPop18,
         afrAmPr18 = afrAm/totPop18, asianPr18 = asian/totPop18) |>
  select(GEOID,totPop18,hispPr18,whitePr18,afrAmPr18, asianPr18)

head(stateDf)

# 4 county level
# I'm specifying one state but all counties

countyDf <- get_acs(geography = 'county', variables = c(totPop18 = "B01001_001", 
                                                        hispanic ="B03003_003", 
                                                        notHispanic = "B03003_002",
                                                        white = "B02001_002", 
                                                        afrAm = "B02001_003", 
                                                        asian = "B02001_005"), 
                    year = 2018, state = 'CA', geometry = FALSE) |> 
  select(GEOID, NAME, variable, estimate) |>
  pivot_wider(names_from = variable, values_from = estimate) |> 
  mutate(hispPr18  = hispanic/totPop18, whitePr18 = white/totPop18,
         afrAmPr18 = afrAm/totPop18, asianPr18 = asian/totPop18) |>
  select(GEOID,totPop18,hispPr18,whitePr18,afrAmPr18, asianPr18)

head(countyDf)

# 5 tract/neighborhood level
tractDf <- get_acs(geography = 'tract',variables = c(totPop18 = "B01001_001", 
                                                     hispanic ="B03003_003", 
                                                     notHispanic = "B03003_002",
                                                     white = "B02001_002", 
                                                     afrAm = "B02001_003", 
                                                     asian = "B02001_005"), 
                   year = 2018, state = 'CA', geometry = FALSE) %>% 
  select(GEOID, NAME, variable, estimate) %>% 
  pivot_wider(names_from = variable,values_from = estimate) %>% 
  mutate(hispPr18  = hispanic/totPop18, whitePr18 = white/totPop18, 
         afrAmPr18 = afrAm/totPop18, asianPr18 = asian/totPop18) %>%
  select(GEOID,totPop18,hispPr18,whitePr18,afrAmPr18, asianPr18)

head(tractDf)

# 6 zipcode level
# only availabe for the entire usa
zctaDf <- get_acs(geography = 'zcta',variables = c(totPop18 = "B01001_001", 
                                                   hispanic ="B03003_003", 
                                                   notHispanic = "B03003_002",
                                                   white = "B02001_002", 
                                                   afrAm = "B02001_003", 
                                                   asian = "B02001_005"), 
                  year = 2018, geometry = FALSE) %>% 
  select(GEOID, NAME, variable, estimate) %>% 
  pivot_wider(names_from = variable, values_from = estimate) %>% 
  mutate(hispPr18  = hispanic/totPop18, whitePr18 = white/totPop18, 
         afrAmPr18 = afrAm/totPop18, asianPr18 = asian/totPop18) %>%
  select(GEOID,totPop18,hispPr18,whitePr18,afrAmPr18, asianPr18)

head(zctaDf)
dim(zctaDf)

# filtering by specific zipcode regions
zipChicagoDf <- get_acs(geography = 'zcta', variables = c(perCapInc = "DP03_0088"),year = 2018, geometry = FALSE) %>%
  select(GEOID, NAME, variable, estimate) %>% 
  filter(str_detect( GEOID,"^606")) %>%  ## add a str filter
  pivot_wider(names_from = variable, values_from = estimate) %>% 
  select(GEOID, perCapInc)

# 7 getting geometry boundaries using either tigris or tidycensus
# tigris
yearToFetch <- 2018

stateShp <- states(year = yearToFetch, cb = T)
countyShp <- counties(year = yearToFetch, state = 'CA', cb = T)
tractShp <- tracts(year = yearToFetch, state = 'CA', cb = T)
zctaShp <- zctas(year = yearToFetch, cb = T)

# merge shape files with ethnicity data
stateShp <- merge(stateShp, stateDf, by.x = 'STATEFP', by.y = 'GEOID', all.x = T)

countyShp <- merge(countyShp, countyDf, by.x  = 'GEOID', by.y = 'GEOID', all.x = TRUE) %>%
  select(GEOID,totPop18,hispPr18,whitePr18,afrAmPr18, asianPr18)

tractShp <- merge(tractShp, tractDf, by.x  = 'GEOID', by.y = 'GEOID', all.x = TRUE) %>%
  select(GEOID,totPop18,hispPr18,whitePr18,afrAmPr18, asianPr18)

zctaShp <- merge(zctaShp, zctaDf, by.x  = 'GEOID10', by.y = 'GEOID', all.x = TRUE)%>%
  select(GEOID10,totPop18,hispPr18,whitePr18,afrAmPr18, asianPr18)

# tidycensus
tractDf <- get_acs(geography = 'tract', variables = c(totPop18 = "B01001_001", 
                                                      hispanic ="B03003_003", 
                                                      notHispanic = "B03003_002",
                                                      white = "B02001_002", 
                                                      afrAm = "B02001_003", 
                                                      asian = "B02001_005"), 
                   year = 2018, state  = 'CA', geometry = FALSE) %>%
  select(GEOID, NAME, variable, estimate) %>% 
  spread(variable, estimate) %>% 
  mutate(hispPr18  = hispanic/totPop18, whitePr18 = white/totPop18,
         afrAmPr18 = afrAm/totPop18, asianPr18 = asian/totPop18) %>%
  select(GEOID,totPop18,hispPr18,whitePr18,afrAmPr18, asianPr18)

tractShp <- get_acs(geography = 'tract', variables = c(perCapitaIncome = "DP03_0088"),
                    year = 2018, state  = 'CA', geometry = TRUE) %>% 
  select(GEOID, NAME, variable, estimate) %>% 
  spread(variable, estimate)


tractsShp <- merge(tractShp, tractDf, by.x = 'GEOID', by.y = 'GEOID', all.x = TRUE)
head(tractShp)

zctaShp <- get_acs(geography = 'zcta', variables = c(totPop18 = "B01001_001",
                                                     perCapInc = "DP03_0088"), 
                   year = 2018, geometry = TRUE) %>%
  select(GEOID, NAME, variable, estimate) %>% 
  spread(variable, estimate) %>% 
  rename(totPop18 = B01001_001, perCapitaInc = DP03_0088) %>%
  select(GEOID,totPop18,perCapitaInc)

# read in city boundary 
chiCityBoundary <- st_read("data/boundaries_chicago.geojson") 

chiCityBoundary <- st_transform(chiCityBoundary, 4326) 
zctaShp <- st_transform(zctaShp, 4326)

#only keep those zipcodes that intersect the Chicago city boundary
zipChicagoShp <- st_intersection(zctaShp,chiCityBoundary)