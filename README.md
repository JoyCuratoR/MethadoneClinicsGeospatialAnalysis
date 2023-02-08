# About the Guided Project
To learn geospatial analysis using a project-based approach, I used tutorials from [Opioid Environment Toolkit](https://geodacenter.github.io/opioid-environment-toolkit/index.html) which is created by Marynia Kolak, Moksha Menghaney, Qinyun Lin, and Angela Li for the JCOIN netowrk - part of the NIH HEAL Initiative.

The purpose of the Opioid Environment Toolkit tutorial project is to teach students how to perform resource location and access analysis, buffer analysis, and identify neighborhoods that are most vulnerable due to the impact of COVID-19.

The goal throughout all tutorials is: "A common goal in opioid environment research is to calculate and compare access metrics to different providers of Medications for Opioid Overuse Disorder (MOUDs)".

The data I'm using comes from [GeoDaCenter's opioid environment toolkit GitHub repository](https://github.com/GeoDaCenter/opioid-environment-toolkit).


# 1 Geocoding and Transforming Coordinates into Spatial Data Points

The first tutorial taught how to transform addresses into geographic coordinates (latitude, longitude). To do this, I used R libraries: sf, tmap, and tidygeocoder.

Before transforming the addresses into spatial points, it's important to do a quality check on the data to make sure the data is uniformed - separate columns for street address, city, zip code, and everything is spelled consistently. Normally, processing and cleaning the data is done before loading it into a data warehouse or writing it out as a csv file.

Additionally, it's important to specify which coordinate reference system (CRS) to use because not every CRS is built for geocoding international addresses or processing large files.

Thus, it's always good to test a geocoding service on a small sample of your data before processing the entire set.

After turning addresses into latitude and longitude coordinates, it's time to convert them into spatial data. To do this, I learned to use the correct spatial reference system which is a set of four numbers that specifies a model to define accurate scale and orientation of the coordinates.

# 2 Conducting Buffer Analysis
Now that the resource locations can be plotted, it's time to identify which neighborhoods in Chicago have better or worse access to these resources.

To do this, I learned how to plot a 1-mile buffer service area around each resource location point and create polygons to represent Chicago's neighborhoods.

The key is to overlay the polygons and the spatial points before layering the buffer.

The first layer consist of Chicago neighborhood zip codes and the boundary lines.

The second layer consist of the resource providers and an aesthetic application of each point sizing and color.

An important step is to check if the coordinate systems and metadata for the spatial points and polygons (providers and neighborhood zip codes) are the same, otherwise R will not measure both layers correctly (if one layer is encoded to meters and the other feet).

The solution is to transform the CRS which is done in R by specifying the new CRS and using the function st_transform() to apply the new system to existing points and polygons.

Generally in large cities like Chicago, stores for city-dwellers' necessities are within a 1-mile walking distance. Also, methadone providers can be found in grocery stores too, which is the reason to use a 1-mile buffer over, say, a 5-mile buffer.

# 3 Merging Methadone Provider Spatial Data with Chicago's COVID-19 Data to Identify Vulnerable Areas
What happens when a pandemic occurs, you can't go outside, most of everything is shut down, and medical facilities are backed up, and you can't get access to your medication?

The purpose of using COVID-19 data is to identify areas where medical providers can concentrate their efforts and resources the most on. Neighborhoods with the highest cases of COVID-19 can prevent patients from being able to access and receive their medication if they are quarantined and cannot travel. 

Because not all the data that comes with Chicago's COVID-19 data, I subset the data and include the column I want to join on which is the zip codes.


# 4 Nearest Resource Analysis
Here, I learned how to calculate the centroid of each zip code area to then calculate the average distance it takes for a resident of each zip code to travel to a library.

By determining the average distance traveled by residents in each area, methadone providers can pinpoint areas lacking in resources and, through a review of patient records, determine if these resource-deprived regions have a high volume of patients.


# How I will apply my new geospatial analysis skills
The main takeaway from this tutorial is the process of transforming string data (addresses) into spatial data (points, polygons, etc.) and how to layer each spatial data to create custom maps.

After learning these skills, I've taken to applying them to an original project to determine accessibility, via public transportation, of Los Angeles county's libraries by using buffer analysis to identify the number of public transportation stops are within a mile of a library and to calculate the minimum distance to the nearest library for each Los Angeles zip code area.

The geospatial analysis of LA's libraries is part of a bigger project that analyzes [Los Angeles County's Library System Resource Allocation](https://github.com/JoyCuratoR/LA-County-Library-System-Resource-Allocation).
