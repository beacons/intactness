# Create simple coverage maps for supp_info
# PV 2020-11-19

library(sf)
library(dplyr)
library(tmap)
library(tmaptools)
library(rmapshaper)
library(lwgeom)

prj = "+proj=aea +lat_1=55 +lat_2=65 +lat_0=50 +lon_0=-154 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs" # Alaska
maps = c('gifl2016','hfp2013','ab2015','ghm2016','vlia2015','ff1996')
ak1 = readRDS("data/gadm/gadm36_USA_1_sf.rds") %>% filter(NAME_1=="Alaska")
ak = st_transform(ak1, prj) %>% ms_simplify() %>% st_make_valid()

borealDir = 'data/boreal_ak/'
b = st_read(paste0(borealDir,'boreal.shp')) %>% ms_simplify() %>% st_make_valid()
b2 = st_read(paste0(borealDir,'gifl.shp')) %>% ms_simplify() %>% st_make_valid()

for (i in maps) {
    v = st_read(paste0(borealDir,i,'.shp')) %>% ms_simplify() %>% st_make_valid()
    map = tm_shape(b) + tm_fill() + tm_shape(v) + tm_fill(col='#7fc97f') + tm_shape(ak) + tm_borders() +
        tm_layout(title = toupper(i), title.position = c("left", "top"))
    tmap_save(map, filename=paste0('maps/ak_',i,'.png'), height=1260, width=2100)
}
