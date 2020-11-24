# Clip disturbance datasets to intactness maps for 39 herds that are within cifl x gifl boundary
# PV 2020-11-24

library(sf)
library(tidyverse)
library(rmapshaper)

dist = c('poly30','line30','poly15','line15')
maps = c('ha2010','cifl2013','gifl2016','hfp2013','ghm2016','ab2015','vlia2015')
iDir = "data/bead/"
bead = st_read('data/bead/_ranges.gpkg', quiet=TRUE)
ranges = sort(bead$Herd_OS)
for (cr in ranges) {
    cat("\nProcessing",cr,"...\n\n")
    if (cr=="AtikakiBernes") {cr="Atikaki_Bernes"}
    if (cr=="OwlFlinstone") {cr="Owl_Flinstone"}
    if (cr=="SnakeSahtahneh") {cr="Snake_Sahtahneh"}
    bnd = st_read(paste0(iDir,cr,'.gpkg'), layer='bnd', quiet=TRUE)
    line15 = st_read(paste0(iDir,cr,'.gpkg'), layer='line15', quiet=TRUE)
    poly15 = st_read(paste0(iDir,cr,'.gpkg'), layer='poly15', quiet=TRUE)
    if (as.character(st_geometry_type(poly15, by_geometry=F)) == "GEOMETRY") {poly15=st_cast(poly15, 'MULTIPOLYGON')}
    line30 = st_read(paste0(iDir,cr,'.gpkg'), layer='line30', quiet=TRUE)
    poly30 = st_read(paste0(iDir,cr,'.gpkg'), layer='poly30', quiet=TRUE)
    if (as.character(st_geometry_type(poly30, by_geometry=F)) == "GEOMETRY") {poly30=st_cast(poly30, 'MULTIPOLYGON')}
    for (i in maps) {
        lyrs = st_layers(paste0(iDir,cr,'.gpkg'))$name
        if (i %in% lyrs) { # check if layer exists
            cat(i,':\n'); flush.console()
            intact_map = st_read(paste0(iDir,cr,'.gpkg'), layer=i, quiet=TRUE)
            for (j in dist) {
                cat('    ...',j,'\n'); flush.console()
                poly30_clip = ms_clip(poly30, intact_map)
                poly30_clip_area = mutate(poly30_clip, Area=round(st_area(poly30_clip),1))
                st_write(poly30_clip_area, paste0(iDir,cr,'.gpkg'), layer=paste0(i,'_poly30'), append = TRUE, delete_layer=TRUE)
                line30_clip = ms_clip(line30, intact_map)
                line30_clip_length = mutate(line30_clip, Length=round(st_length(line30_clip),1))
                st_write(line30_clip_length, paste0(iDir,cr,'.gpkg'), layer=paste0(i,'_line30'), append = TRUE, delete_layer=TRUE)
                poly15_clip = ms_clip(poly15, intact_map)
                poly15_clip_area = mutate(poly15_clip, Area=round(st_area(poly15_clip),1))
                st_write(poly15_clip_area, paste0(iDir,cr,'.gpkg'), layer=paste0(i,'_poly15'), append = TRUE, delete_layer=TRUE)
                line15_clip = ms_clip(line15, intact_map)
                line15_clip_length = mutate(line15_clip, Length=round(st_length(line15_clip),1))
                st_write(line15_clip_length, paste0(iDir,cr,'.gpkg'), layer=paste0(i,'_line15'), append = TRUE, delete_layer=TRUE)
            }
        }
    }
}
