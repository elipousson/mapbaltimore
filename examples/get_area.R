# Get the Harwood neighborhood by name
get_area(type = "neighborhood", area_name = "Harwood")

# Get City Council District 12 and 14 by id
get_area(type = "council district", area_id = c(12, 14))

# Get the east and southeast planning districts and combine them
get_area(type = "planning district", area_id = c("East", "Southeast"), union = TRUE, area_label = "East and Southeast Planning Districts")

# Get legislative district for Walters Art Museum (600 N Charles St)
get_area(type = "legislative district", location = "600 N Charles St, Baltimore, MD 21201")

# Get Census tracts for the Edmondson Village neighborhood
get_area(type = "tract", location = get_area("neighborhood", "Edmondson Village"))
