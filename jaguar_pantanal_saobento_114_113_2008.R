
library (move)
library (moveVis)
library(magrittr)
library(ggplot2)

library (maptools) # utilizacao de shapefiles

setwd("C:/Users/User/Desktop/jaguar_tele/MoveVis")

#carrega a matriz com dados de telemetria
move_felid <-read.csv("jaguar_pantanal_saobento_114_113_2008.txt", sep=",")
head(move_felid)

#reconhece a formatação da data e hora
move_felid$dt <-as.POSIXct(strptime(move_felid$dt, "%m/%d/%Y %H:%M", tz ="GMT"),  proj=CRS("+proj=longlat +ellps=GRS80"))

#reconhece a projeção, define as colunas dos indivíduos, do tempo e das coordenadas
m <-df2move(move_felid,
         proj=CRS("+proj=longlat +ellps=GRS80"),
        x = "Long", y = "Lat", time = "dt", track_id = "Individual")

#define a resolução de tempo por frame em segundos (res=4320 significa que cada frame tem 12 horas de amostragem)
#quanto menor a resolução é mais detalhado a visualização do movimento, 
#mas aumenta muito o tempo para carregar o gif (as vezes é necessario utilizar outros formatos de vídeo para salvar o arquivo)e o aumenta o tamanho do arquivo
#para este banco de dados 1 frame = 12horas demora ~26minutos com um processador i7 2.10GHz, 8GB Ram, .
#resolution of 1 day (86400seconds) at digit 0 (:00 seconds) per timestamp:

am <- align_move(m, res = 43200, digit = 0, unit = "secs")
unique(unlist(timeLag(am, units = "secs")))

#opções de mapas. para imagens de satelite é necessário tem o token do mapbox. usar o map_service="osm"
get_maptypes()

#Imagem de satelite
frames <- frames_spatial(am, path_colours = c("green","purple"),map_service = "osm", map_type ="topographic", 
 tail_colour = "white", tail_size = 0.3,map_res=1) %>% 

#adiciona informações aos frames, como os eixos das coordenadas, títulos, subtitulos, escala, norte.
add_labels(x = "Longitude", y = "Latitude", title="Jaguar movement database: a GPS-based movement dataset" , subtitle=" doi.org/10.1002/ecy.2379") %>% 
  add_timestamps(am, type = "label") %>% 
  add_progress()

#informar um texto sobre os frames (nesse caso o nome de quem criou a animação). verificar as coordenadas para inserir corretamente a informação.
frames <- add_text(frames, "@fblpalmeira", x = -56.93, y = -19.56,
                   colour = "grey", size = 2.8)
#visualiza um frame para verificar se está certo antes de carregar o gif
frames[[10]]

#sugere formatos diferentes para salvar o arquivo
#suggest_formats()

#define, tamanho, resolução, nome do arquivo e local onde será salvo o gif 
#certifique-se do caminho do diretório, se errar a pasta vai  ter que carregar de novo)
animate_frames(frames, out_file = "/Jaguar/GIFs/saobento_114_113_6hrs_2008b(teste).gif", width = 800, height = 550, res = 95)