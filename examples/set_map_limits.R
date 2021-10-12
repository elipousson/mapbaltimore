# Show detailed city boundary with map focused on area of Fell's Point (with 50m buffer)
library(ggplot2)

ggplot() +
   geom_sf(data = baltimore_city_detailed) +
   set_map_limits(area = get_area("neighborhood", "Fells Point"), dist = 50)
