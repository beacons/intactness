# Created simple coverage maps for supp_info
# PV 2020-06-10

library(sf)
library(dplyr)
library(tmap)
library(tmaptools)
library(rmapshaper)
library(lwgeom)

prj = "+proj=aea +lat_1=50 +lat_2=70 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
maps = c('ha2010','cifl2000','cifl2013','gifl2000','gifl2013','gifl2016','hfp2000','hfp2013','ab2000','ab2015','ghm2016','vlia2015')

can1 = readRDS("2_cover/gadm/gadm36_CAN_1_sf.rds")
can = st_transform(can1, prj) %>% ms_simplify() %>% st_make_valid()
#write_sf(can, "2_cover/gadm/canada.shp")

borealDir = 'C:/Users/PIVER37/Documents/gisdata/intactness/boreal/'
b = st_read(paste0(borealDir,'boreal.shp')) %>% ms_simplify() %>% st_make_valid()
b1 = st_read(paste0(borealDir,'cifl.shp')) %>% ms_simplify() %>% st_make_valid()
b2 = st_read(paste0(borealDir,'gifl.shp')) %>% ms_simplify() %>% st_make_valid()

for (i in maps) {
    v = st_read(paste0(borealDir,i,'.shp')) %>% ms_simplify() %>% st_make_valid()
    map = tm_shape(b) + tm_fill() + tm_shape(v) + tm_fill(col='#7fc97f') + tm_shape(can) + tm_borders() +
        tm_layout(title = toupper(i), title.position = c("right", "top"))
    tmap_save(map, filename=paste0('../supp_info/maps/ca_',i,'.png'), height=1260, width=2100)
}
