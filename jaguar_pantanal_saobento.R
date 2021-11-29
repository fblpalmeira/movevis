library (move)
library (moveVis)
library (maptools) # shapefiles

move_felid <-read.csv("jaguar_pantanal_saobento_2008.txt", sep=",")
head(move_felid)

move_felid$dt <-as.POSIXct(strptime(move_felid$dt, "%m/%d/%Y %H:%M", tz ="GMT"),  proj=CRS("+proj=longlat +ellps=GRS80"))

m <-df2move(move_felid,
         proj=CRS("+proj=longlat +ellps=GRS80"),
        x = "Long", y = "Lat", time = "dt", track_id = "Individual")

# resolution of 1 day (86400seconds) at digit 0 (:00 seconds) per timestamp:
am <- align_move(m, res = 43200, digit = 0, unit = "secs")
unique(unlist(timeLag(am, units = "secs")))

# satellite images
frames <- frames_spatial(am, path_colours = c("blue","lightblue","yellow","orange","pink","grey",
"green","purple","red"),
                        map_service = "osm", map_type ="topographic", map_res=1) %>% 
  
add_labels(x = "Longitude", y = "Latitude", title="Jaguar movement database: a GPS-based movement dataset" , subtitle=" doi.org/10.1002/ecy.2379") %>% # add some customizations, such as axis labels
  add_northarrow(x = -56.76, y = -19.64) %>% 
  add_scalebar(x = -57.1, y = -19.64) %>% 
  add_timestamps(am, type = "label") %>% 
  add_progress()

frames <- add_text(frames, "@fblpalmeira", x = -56.82, y = -19.65,
                   colour = "grey", size = 2.8)

frames[[30]] # preview one of the frames, e.g. the 10th frame

#suggest_formats()

animate_frames(frames, out_file = "/Jaguar/GIFs/saobento_2008b.gif", width = 800, height = 550, res = 95)
