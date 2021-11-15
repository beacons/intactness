# Caribou range case studies data preparation (use BEAD projection)
# Clip range boundaries to the CIFL_GIFL intersection
# PV 2021-10-27

library(sf)
library(tidyverse)
library(rmapshaper)

# Loop over caribou ranges
iDir = "data/boreal/"
oDir = "data/bead/"
# Uncomment to create _ranges.gpkg
#rangeDir30 = 'C:/Users/PIVER37/Dropbox (BEACONs)/gisdata/intactness/BEAD/2015 Update/Anthro_Disturb_Perturb_30m_2015/_Caribou_51_Ranges_Aires_2012.gdb'
#bead = st_read(rangeDir30, 'Caribou_51_Ranges_Aires_2012')
#st_write(bead, '../data/bead/_ranges.gpkg', delete_layer=TRUE)
bead = st_read('data/bead/_ranges.gpkg')
#vecDir = 'C:/Users/PIVER37/Documents/gisdata/intactness/boreal/'
boreal = st_read('data/boreal/boreal.shp') %>% st_transform(st_crs(bead))
#st_write(boreal, '../data/bead/_boreal.gpkg', delete_layer=TRUE)
ciflxgifl = st_read('data/boreal/cifl_gifl.shp') %>% st_transform(st_crs(bead))
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
    if (cr=="Atikaki_Bernes") { # 2021-10-27 Intactness shapefile only needs to be read in first loop
        shp1 = st_read(paste0(iDir, 'ha2010.shp')) %>% 
            st_transform(st_crs(bnd)) %>%
            st_make_valid()
    }
    mat=st_intersects(shp1, bndx, sparse=T)
    if (sum(mat[[1]]) > 0) {
        shp_bnd = ms_clip(shp1, bndx) 
        shp_bnd = mutate(shp_bnd, Area=round(st_area(shp_bnd),1))
        st_write(shp_bnd, paste0(oDir,cr,'.gpkg'), 'ha2010', append=TRUE, delete_layer=TRUE)
    }

    # CANADA INTACT FOREST LANDSCAPES
    if (cr=="Atikaki_Bernes") { # 2021-10-27 Intactness shapefile only needs to be read in first loop
        shp2 = st_read(paste0(iDir, 'cifl2013.shp')) %>% 
            st_transform(st_crs(bnd)) %>%
            st_make_valid()
    }
    mat=st_intersects(shp2, bndx, sparse=T)
    if (sum(mat[[1]]) > 0) {
        shp_bnd = ms_clip(shp2, bndx)
        shp_bnd = mutate(shp_bnd, Area=round(st_area(shp_bnd),1))
        st_write(shp_bnd, paste0(oDir,cr,'.gpkg'), 'cifl2013', append=TRUE, delete_layer=TRUE)
    }

    # GLOBAL INTACT FOREST LANDSCAPES
    if (cr=="Atikaki_Bernes") { # 2021-10-27 Intactness shapefile only needs to be read in first loop
        shp3 = st_read(paste0(iDir, 'gifl2016.shp')) %>% 
            st_transform(st_crs(bnd)) %>%
            st_make_valid()
    }
    mat=st_intersects(shp3, bndx, sparse=T)
    if (sum(mat[[1]]) > 0) {
        shp_bnd = ms_clip(shp3, bndx)
        shp_bnd = mutate(shp_bnd, Area=round(st_area(shp_bnd),1))
        st_write(shp_bnd, paste0(oDir,cr,'.gpkg'), 'gifl2016', append=TRUE, delete_layer=TRUE)
    }

    # HUMAN FOOTPRINT MAPS
    if (cr=="Atikaki_Bernes") { # 2021-10-27 Intactness shapefile only needs to be read in first loop
        shp4 = st_read(paste0(iDir, 'hfp2013.shp')) %>% 
            st_transform(st_crs(bnd)) %>%
            st_make_valid()
    }
    mat=st_intersects(shp4, bndx, sparse=T)
    if (sum(mat[[1]]) > 0) {
        shp_bnd = ms_clip(shp4, bndx)
        shp_bnd = mutate(shp_bnd, Area=round(st_area(shp_bnd),1))
        st_write(shp_bnd, paste0(oDir,cr,'.gpkg'), 'hfp2013', append=TRUE, delete_layer=TRUE)
    }

    # ANTHROPOGENIC BIOMES
    if (cr=="Atikaki_Bernes") { # 2021-10-27 Intactness shapefile only needs to be read in first loop
        shp5 = st_read(paste0(iDir, 'ab2015.shp')) %>% 
            st_transform(st_crs(bnd)) %>%
            st_make_valid()
    }
    mat=st_intersects(shp5, bndx, sparse=T)
    if (sum(mat[[1]]) > 0) {
        shp_bnd = ms_clip(shp5, bndx)
        shp_bnd = mutate(shp_bnd, Area=round(st_area(shp_bnd),1))
        st_write(shp_bnd, paste0(oDir,cr,'.gpkg'), 'ab2015', append=TRUE, delete_layer=TRUE)
    }

    # GLOBAL HUMAN MODIFICATIONS
    if (cr=="Atikaki_Bernes") { # 2021-10-27 Intactness shapefile only needs to be read in first loop
        shp6 = st_read(paste0(iDir, 'ghm2016.shp')) %>% 
            st_transform(st_crs(bnd)) %>%
            st_make_valid()
    }
    mat=st_intersects(shp6, bndx, sparse=T)
    if (sum(mat[[1]]) > 0) {
        shp_bnd = ms_clip(shp6, bndx)
        shp_bnd = mutate(shp_bnd, Area=round(st_area(shp_bnd),1))
        st_write(shp_bnd, paste0(oDir,cr,'.gpkg'), 'ghm2016', append=TRUE, delete_layer=TRUE)
    }

    # VERY LOW IMPACT AREAS
    if (cr=="Atikaki_Bernes") { # 2021-10-27 Intactness shapefile only needs to be read in first loop
        shp7 = st_read(paste0(iDir, 'vlia2015.shp')) %>% 
            st_transform(st_crs(bnd)) %>%
            st_make_valid()
    }
    mat=st_intersects(shp7, bndx, sparse=T)
    if (sum(mat[[1]]) > 0) {
        shp_bnd = ms_clip(shp7, bndx)
        shp_bnd = mutate(shp_bnd, Area=round(st_area(shp_bnd),1))
        st_write(shp_bnd, paste0(oDir,cr,'.gpkg'), 'vlia2015', append=TRUE, delete_layer=TRUE)
    }

    # HUMAN FOOTPRINT MAPS (CANADA)
    if (cr=="Atikaki_Bernes") { # 2021-10-27 Intactness shapefile only needs to be read in first loop
        shp8 = st_read(paste0(iDir, 'hfp2019.shp')) %>% 
            st_transform(st_crs(bnd)) %>%
            st_make_valid()
    }
    mat=st_intersects(shp8, bndx, sparse=T)
    if (sum(mat[[1]]) > 0) {
        shp_bnd = ms_clip(shp8, bndx)
        shp_bnd = mutate(shp_bnd, Area=round(st_area(shp_bnd),1))
        st_write(shp_bnd, paste0(oDir,cr,'.gpkg'), 'hfp2019', append=TRUE, delete_layer=TRUE)
        #st_write(shp_bnd, paste0('data/bead_shp/',cr,'_hfp2019.shp'), append=TRUE, delete_layer=TRUE)
    }

}
