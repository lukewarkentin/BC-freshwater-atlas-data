#install.packages("devtools")
devtools::install_github("poissonconsulting/fwatlasbc")

require(fwatlasbc)
require(ggplot2)
require(purrr)
library(dplyr)
require(sf)
require(here)

streams <- fwa_find_stream_names("skeena")
streams
streams_nass <- fwa_find_stream_names("nass river")

blks <- fwa_add_blks_to_stream_name(streams)
blks
blks_nass <- fwa_add_blks_to_stream_name(streams_nass)


wshed <- fwa_add_watershed_to_blk(blks) # get watershed polygon for a blue line key/ stream name
wshed_nass <- fwa_add_watershed_to_blk(blks_nass)

# network_1 <- fwa_add_collection_to_polygon(wshed, "stream_network",  
#                                          filter=list(gnis_name = "Zymoetz River"))

rivers_nass <- as.list(c("Nass River", "Meziadin River", "Bell-Irving River"))
#network_nass <- fwa_add_collection_to_polygon(wshed_nass, "stream_network",
#                                              filter=list(gnis_name = "Nass River"))

rivers <- as.list(c( "Skeena River", "Kitsumkalum River", "Zymoetz River", 
                     "Ecstall River", "Bulkley River", 
                     "Cedar River", "Sweetin River", "Suskwa River", "Kitseguecla River",
                     "Kitwanga River", "Exchamsiks River", "Sustut River", "Otsi Creek",
                     "Slamgeesh River", 
                     "Lakelse River",
                     #"Thomas Creek", 
                     "Gitnadoix River",
                     "Nanika River",
                     "Kasiks River", "Kispiox River", "Squingula River", "Zymagotitz River",
                     "Sicintine River", "Exstew River", "Kluayaz Creek",
                     "Morice River", "Khyex River", "Bear River", "Babine River" 
))
str(rivers)

# Get Skeena river and tributary lines
network_list <- map2( .x= list(wshed), .y=rivers, function(x,y)
  fwa_add_collection_to_polygon(x=x,
                                collection="stream_network",
                                filter=list(gnis_name = y))
) 
# Get Nass River and tributary lines
network_list_nass <- map2( .x= list(wshed_nass), .y=rivers_nass, function(x,y)
  fwa_add_collection_to_polygon(x=x,
                                collection="stream_network",
                                filter=list(gnis_name = y))
) 

# combine skeena and nass river lines
network_list_combined <- c(network_list, network_list_nass)
# convert to sf object 
network <- st_sf(do.call(rbind, network_list_combined))
# Save as RDS object for mapping
saveRDS(network, here("data-in/freshwater-atlas-streams.RDS"))
labels <- network %>% group_by(gnis_name) %>% slice_head(n=1)

# Save figure
png(here("fig/skeena-nass-rivers-map.png"), width=8, height=7, units="in", res=600)
ggplot() +
  geom_sf(data = wshed) +
  geom_sf(data = wshed_nass) +
  geom_sf(data = network, color = "blue") +
  geom_sf_text(data=labels, aes(label=gnis_name), size=3) 
#  ggplot2::geom_sf(data = rms) 
dev.off()
