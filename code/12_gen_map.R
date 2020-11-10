# Created simple coverage maps for supp_info
# PV 2020-04-22

library(sf)
library(dplyr)
library(tmap)
library(tmaptools)
library(rmapshaper)
library(lwgeom)

cr = 'CaribouMountains'
borealDir = paste0('C:/Users/PIVER37/Documents/gisdata/intactness/ranges/',cr,'/')
b = st_read(paste0(borealDir,'bnd.shp')) %>% st_make_valid()

line = st_read(paste0(borealDir,'line30.shp')) %>% st_make_valid() %>% mutate(Disturbance="Linear")
poly = st_read(paste0(borealDir,'poly30.shp')) %>% st_make_valid() %>% mutate(Disturbance="Polygonal")

bc_map = tm_shape(b) + tm_fill() + 
    tm_shape(line) + tm_lines(col="Disturbance", palette="black", title.col="", title.lwd="") + 
    tm_shape(poly) + tm_polygons(col="Disturbance", palette="#e41a1c", title="", border.col="#e41a1c") + 
    #tm_layout(title = "CaribouMountains Range", title.position = c("left", "top"), legend.position = c("right", "bottom"), legend.text.size=1) +
    tm_layout(legend.position = c("left", "top"), legend.text.size=1) +
    tm_compass(position = c("left", "bottom")) + tm_scale_bar(position=c("right","bottom"))
tmap_save(bc_map, filename=paste0('8_sensitivity/output/cm_study_region.png'), height=1260, width=2100)