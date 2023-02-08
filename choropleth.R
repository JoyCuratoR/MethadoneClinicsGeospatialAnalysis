# guide: 

library(sf)
library(dplyr)
library(giscoR)
library(ggplot2)

# geometry 
geometry <- gisco_get_nuts(year = 2016,
                           resolution = 20,
                           nuts_level = 2,
                           country = "Sweden") |>
select(NUTS_ID, NAME_LATN)

# base map 
ggplot(geometry) +
  geom_sf()

# changing crs and defining limits of map
chg_crs <- st_transform(geometry, 3035)

ggplot(chg_crs) +
  geom_sf() +
  xlim(c(2200000, 7150000)) +
  ylim(c(1380000, 5500000))

# join map and data

# first filter data from 2016
disp_income <- tgs00026 |>
  filter(time == 2016) |>
  select(-time)

merged_data <- chg_crs |>
  left_join(disp_income, by = c("NUTS_ID" = "geo"))

# basic choropleth map 
ggplot(merged_data) +
  geom_sf(aes(fill = values)) + # values are the country's region 
  labs(title = "Disposable Income of Private Households",
       subtitle = "Sweden, 2016") +
  xlim(c(2200000, 7150000)) +
  ylim(c(1380000, 5500000))

?labs
