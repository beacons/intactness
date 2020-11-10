# Caribou range case studies data preparation (use BEAD projection)
# Clip range boundaries to the CIFL_GIFL intersection
# PV 2020-07-06

library(sf)
library(tidyverse)
library(rmapshaper)

# Loop over caribou ranges
iDir = "C:/Users/PIVER37/Documents/gisdata/intactness/"
oDir = "C:/Users/PIVER37/Documents/beacons/intactness/data/bead/"
rangeDir30 = 'C:/Users/PIVER37/Dropbox (BEACONs)/gisdata/intactness/BEAD/2015 Update/Anthro_Disturb_Perturb_30m_2015/_Caribou_51_Ranges_Aires_2012.gdb'
bead = st_read(rangeDir30, 'Caribou_51_Ranges_Aires_2012')
#st_write(bead, '../data/bead/_ranges.gpkg', delete_layer=TRUE)
vecDir = 'C:/Users/PIVER37/Documents/gisdata/intactness/boreal/'
boreal = st_read(paste0(vecDir, 'boreal.shp')) %>% st_transform(st_crs(bead))
#st_write(boreal, '../data/bead/_boreal.gpkg', delete_layer=TRUE)
ciflxgifl = st_read(paste0(vecDir, 'cifl_gifl.shp')) %>% st_transform(st_crs(bead))
#st_write(ciflxgifl, '../data/bead/_ciflxgifl.gpkg', delete_layer=TRUE)

ranges = sort(bead$Herd_OS)
for (cr in ranges) {
    cat("\nProcessing",cr,"...\n\n")
    
    # Rename three herds to match name of file geodatabase
    if (cr=="AtikakiBernes") {cr="Atikaki_Bernes"}
    if (cr=="OwlFlinstone") {cr="Owl_Flinstone"}
    if (cr=="SnakeSahtahneh") {cr="Snake_Sahtahneh"}

    # Projection and folder
    rangeDir15 = paste0("C:/Users/PIVER37/Dropbox (BEACONs)/gisdata/intactness/BEAD/2015 Update/Anthro_Disturb_Perturb_15m_2015/",cr,"_15m.gdb")
    rangeDir30 = paste0("C:/Users/PIVER37/Dropbox (BEACONs)/gisdata/intactness/BEAD/2015 Update/Anthro_Disturb_Perturb_30m_2015/",cr,"_30m.gdb")

    ################################################################################################
    # 1. Extract linear and polygonal disturbances and save as shapefiles

    lyr30 = st_layers(rangeDir30)
    lyr15 = st_layers(rangeDir15)

    # Read range files 2015
    bnd = st_read(rangeDir30, lyr30$name[1]) %>% st_transform(st_crs(bead))
    bndx = ms_clip(bnd, ciflxgifl)
    bndx_area = mutate(bndx, Area=round(st_area(bndx),1))
    st_write(bndx_area, paste0(oDir,cr,'.gpkg'), 'bnd', delete_layer=TRUE)
    
    # Line30
    line = st_read(rangeDir30, lyr30$name[2])
    linex = ms_clip(line, bndx)
    linex_area = mutate(linex, Length=round(st_length(linex),1))
    st_write(linex_area, paste0(oDir,cr,'.gpkg'), 'line30', append=TRUE, delete_layer=TRUE)
    
    # Poly30
    poly = st_read(rangeDir30, lyr30$name[3])
    if (as.character(st_geometry_type(poly, by_geometry=F)) == "GEOMETRY") {poly=st_cast(poly, 'MULTIPOLYGON')}
    polyx = ms_clip(poly, bndx)
    polyx_area = mutate(polyx, Area=round(st_area(polyx),1))
    st_write(polyx_area, paste0(oDir,cr,'.gpkg'), 'poly30', append=TRUE, delete_layer=TRUE)

    # Line15
    line = st_read(rangeDir15, lyr15$name[2])
    linex = ms_clip(line, bndx)
    linex_length = mutate(linex, Length=round(st_length(linex),1))
    st_write(linex_length, paste0(oDir,cr,'.gpkg'), 'line15', append=TRUE, delete_layer=TRUE)
    
    # Poly15
    poly = st_read(rangeDir15, lyr15$name[3])
    if (as.character(st_geometry_type(poly, by_geometry=F)) == "GEOMETRY") {poly=st_cast(poly, 'MULTIPOLYGON')}
    polyx = ms_clip(poly, bndx)
    polyx_area = mutate(polyx, Area=round(st_area(polyx),1))
    st_write(polyx_area, paste0(oDir,cr,'.gpkg'), 'poly15', append=TRUE, delete_layer=TRUE)

    ################################################################################################
    # 2. Clip intactness maps to herd boundaries after checking that they intersect

    # CANADA HUMAN ACCESS 2010
    shp = st_read(paste0(iDir, 'boreal/ha2010.shp')) %>% st_transform(st_crs(bnd))
    mat=st_intersects(shp, bndx, sparse=T)
    if (sum(mat[[1]]) > 0) {
        shp_bnd = ms_clip(shp, bndx) 
        shp_bnd = mutate(shp_bnd, Area=round(st_area(shp_bnd),1))
        st_write(shp_bnd, paste0(oDir,cr,'.gpkg'), 'ha2010', append=TRUE, delete_layer=TRUE)
    }

    # CANADA INTACT FOREST LANDSCAPES
    shp = st_read(paste0(iDir, 'boreal/cifl2013.shp')) %>% st_transform(st_crs(bnd))
    mat=st_intersects(shp, bndx, sparse=T)
    if (sum(mat[[1]]) > 0) {
        shp_bnd = ms_clip(shp, bndx)
        shp_bnd = mutate(shp_bnd, Area=round(st_area(shp_bnd),1))
        st_write(shp_bnd, paste0(oDir,cr,'.gpkg'), 'cifl2013', append=TRUE, delete_layer=TRUE)
    }

    # GLOBAL INTACT FOREST LANDSCAPES
    shp = st_read(paste0(iDir, 'boreal/gifl2016.shp')) %>% st_transform(st_crs(bnd))
    mat=st_intersects(shp, bndx, sparse=T)
    if (sum(mat[[1]]) > 0) {
        shp_bnd = ms_clip(shp, bndx)
        shp_bnd = mutate(shp_bnd, Area=round(st_area(shp_bnd),1))
        st_write(shp_bnd, paste0(oDir,cr,'.gpkg'), 'gifl2016', append=TRUE, delete_layer=TRUE)
    }

    # HUMAN FOOTPRINT MAPS
    shp = st_read(paste0(iDir, 'boreal/hfp2013.shp')) %>% st_transform(st_crs(bnd))
    mat=st_intersects(shp, bndx, sparse=T)
    if (sum(mat[[1]]) > 0) {
        shp_bnd = ms_clip(shp, bndx)
        shp_bnd = mutate(shp_bnd, Area=round(st_area(shp_bnd),1))
        st_write(shp_bnd, paste0(oDir,cr,'.gpkg'), 'hfp2013', append=TRUE, delete_layer=TRUE)
    }

    # ANTHROPOGENIC BIOMES
    shp = st_read(paste0(iDir, 'boreal/ab2015.shp')) %>% st_transform(st_crs(bnd))
    mat=st_intersects(shp, bndx, sparse=T)
    if (sum(mat[[1]]) > 0) {
        shp_bnd = ms_clip(shp, bndx)
        shp_bnd = mutate(shp_bnd, Area=round(st_area(shp_bnd),1))
        st_write(shp_bnd, paste0(oDir,cr,'.gpkg'), 'ab2015', append=TRUE, delete_layer=TRUE)
    }

    # GLOBAL HUMAN MODIFICATIONS
    shp = st_read(paste0(iDir, 'boreal/ghm2016.shp')) %>% st_transform(st_crs(bnd))
    mat=st_intersects(shp, bndx, sparse=T)
    if (sum(mat[[1]]) > 0) {
        shp_bnd = ms_clip(shp, bndx)
        shp_bnd = mutate(shp_bnd, Area=round(st_area(shp_bnd),1))
        st_write(shp_bnd, paste0(oDir,cr,'.gpkg'), 'ghm2016', append=TRUE, delete_layer=TRUE)
    }

    # VERY LOW IMPACT AREAS
    shp = st_read(paste0(iDir, 'boreal/vlia2015.shp')) %>% st_transform(st_crs(bnd))
    mat=st_intersects(shp, bndx, sparse=T)
    if (sum(mat[[1]]) > 0) {
        shp_bnd = ms_clip(shp, bndx)
        shp_bnd = mutate(shp_bnd, Area=round(st_area(shp_bnd),1))
        st_write(shp_bnd, paste0(oDir,cr,'.gpkg'), 'vlia2015', append=TRUE, delete_layer=TRUE)
    }
}
