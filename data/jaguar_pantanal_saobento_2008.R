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

# Satellite images
frames <- frames_spatial(am, path_colours = c("blue","deepskyblue","yellow","orange","magenta","darkgreen",
                                              "green","purple","red"),
                         path_legend_title = c("Jaguar ID"),
                         map_service = "osm", map_type ="topographic", map_res=1) %>% 
  
  add_labels(x = "Longitude", y = "Latitude", title="Jaguar movement database: a GPS-based movement dataset" , subtitle="(https://doi.org/10.1002/ecy.2379)") %>% # add some customizations, such as axis labels
  add_northarrow(x = -56.76, y = -19.64) %>% 
  add_scalebar(x = -57.1, y = -19.64) %>% 
  add_timestamps(am, type = "label") %>% 
  add_progress()

frames <- add_text(frames, "@fblpalmeira @cttrinca", x = -56.82, y = -19.65,
                   colour = "grey", size = 2.8)

frames[[30]] # preview one of the frames, e.g. the 10th frame

#suggest_formats()

animate_frames(frames, out_file = "jaguar_pantanal_saobento_2008.gif", width = 800, height = 550, res = 95)

library(magick)
library(magrittr) 

# Call back the plot
plot <- image_read("jaguar_pantanal_saobento_2008.gif")
plot2<-image_annotate(plot, "
                      Image credit: P. onca (Palmeira, FBL and Trinca, CT)", 
                      color = "gray", size = 12, 
                      location = "10+50", gravity = "southeast")
# And bring in a logo
jaguar <- image_read("https://raw.githubusercontent.com/fblpalmeira/movevis/main/onca_colar.png") 
out<-image_composite(plot2,image_scale(jaguar,"x50"), gravity="north", offset = "+280+110")

image_browse(out)

# And overwrite the plot without a logo
image_write(out, "jaguar_pantanal_saobento3.gif")

