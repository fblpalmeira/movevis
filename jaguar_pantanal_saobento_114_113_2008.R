
library (move)
library (moveVis)
library(magrittr)
library(ggplot2)
library (maptools) 

move_felid <-read.csv("jaguar_pantanal_saobento_114_113_2008.txt", sep=",")
head(move_felid)

move_felid$dt <-as.POSIXct(strptime(move_felid$dt, "%m/%d/%Y %H:%M", tz ="GMT"),  proj=CRS("+proj=longlat +ellps=GRS80"))

m <-df2move(move_felid,
         proj=CRS("+proj=longlat +ellps=GRS80"),
        x = "Long", y = "Lat", time = "dt", track_id = "Individual")

am <- align_move(m, res = 43200, digit = 0, unit = "secs")
unique(unlist(timeLag(am, units = "secs")))

get_maptypes()

frames <- frames_spatial(am, path_colours = c("green","purple"),map_service = "osm", map_type ="topographic", 
 tail_colour = "white", tail_size = 0.3,map_res=1) %>% 

add_labels(x = "Longitude", y = "Latitude", title="Jaguar movement database: a GPS-based movement dataset", subtitle=" doi.org/10.1002/ecy.2379") %>% 
  add_timestamps(am, type = "label") %>% 
  add_progress()

frames <- add_text(frames, "@fblpalmeira", x = -56.93, y = -19.56,
                   colour = "grey", size = 2.8)
frames[[10]]

animate_frames(frames, out_file = "/Jaguar/GIFs/saobento_114_113_6hrs_2008.gif", width = 800, height = 550, res = 95)
