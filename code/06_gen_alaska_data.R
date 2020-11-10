# Prepare datasets for coverage estimation within Brandt's boreal region in Alaska
# Projection: Alaska Albers Equal Area (epsg: 102006)
# PV 2020-06-10

library(sf)
library(rgdal)
library(stars)
library(raster)
library(gdalUtils)
library(fasterize)
library(rmapshaper)

# Set workspace & parameters
cellsize = 1000
prj = "+proj=aea +lat_1=55 +lat_2=65 +lat_0=50 +lon_0=-154 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs" # Alaska
#prj = "+proj=aea +lat_1=50 +lat_2=70 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs" # Canada
dropDir = 'C:/Users/PIVER37/Dropbox (BEACONs)/gisdata/intactness/'
vecDir = 'C:/Users/PIVER37/Documents/gisdata/intactness/boreal_ak/'
tmpDir = 'C:/Users/PIVER37/Documents/gisdata/intactness/tmp/'
rasDir = paste0('C:/Users/PIVER37/Documents/gisdata/intactness/boreal_ak/raster',cellsize,'/')
if (!dir.exists(vecDir)) dir.create(vecDir, recursive=T)
if (!dir.exists(rasDir)) dir.create(rasDir, recursive=T)

# Create boreal boundary minus water (vector & raster)
# Create analysis mask i.e., boreal minus large lakes that are excluded from CIFL & GIFL
# lakes = st_read(paste0(dropDir, 'Lakes/boreal_lakes.shp'))
if (!file.exists(paste0(vecDir, 'boreal.shp'))) {
    bnd = st_read(paste0(dropDir, 'BrandtsBoreal/NABoreal.shp'), stringsAsFactors=TRUE, 
        query="select * FROM \"NABoreal\" WHERE (TYPE = 'BOREAL' OR TYPE = 'B_ALPINE') AND COUNTRY = 'USA'") %>%
        ms_dissolve() %>% st_transform(prj)
    st_write(bnd, paste0(vecDir, 'boreal.shp'), delete_layer=T)
    rbnd = fasterize(bnd, raster(bnd, res=cellsize), fun="sum")
    crs(rbnd) = prj
    writeRaster(rbnd, paste0(rasDir, 'boreal.tif'), overwrite=T)
} else {
    bnd = st_read(paste0(vecDir, 'boreal.shp'))
    rbnd = raster(paste0(rasDir, 'boreal.tif'))
}

# Anthromes (ab2000, ab2005, ab2010, ab2015)
for (i in c(2000, 2005, 2010, 2015)) {
    if (!file.exists(paste0(vecDir,"ab",i,".shp"))) {
        cat('Anthropogenic biomes ',i,'...\n'); flush.console()
        x = raster(paste0(dropDir, paste0('Anthromes/anthromes',i,'AD.asc')), crs="+proj=longlat +datum=WGS84")
        bnd_xy = st_transform(bnd, crs='+proj=longlat +datum=WGS84 +no_defs')
        x2 = crop(x, bnd_xy)
        x3 = projectRaster(from=x2, to=rbnd, crs=prj, method='ngb', res=1000)
        x4 = mask(x3, rbnd)    
        r = reclassify(x4, c(-1,60,NA, 60,63,1)) # keep values 61-63
        #writeRaster(r, paste0(rasDir,"ab",i,".tif"), overwrite=TRUE)
        # Vectorize...
        v <- st_as_stars(r) %>% 
            st_as_sf(merge = TRUE) %>% # this is the raster to polygons part
            st_cast("MULTIPOLYGON") %>% # cast the polygons to polylines
            ms_dissolve()
        st_write(v, paste0(vecDir,"ab",i,".shp"), delete_layer=T)
    }
}

# Frontier forests 1996 (ff1996)
if (!file.exists(paste0(vecDir,"ff1996.shp"))) {
    cat('Frontier forests...\n'); flush.console()
    v = st_read(paste0(dropDir, 'FrontierForests/frontier_ighp.shp')) %>%
        st_transform(prj) %>% ms_clip(bnd) %>% ms_dissolve()
    st_write(v, paste0(vecDir, 'ff1996.shp'), delete_layer=T)
    #v_raster = raster(v, res=cellsize)
    #rv = fasterize(v, v_raster, fun="sum")
    #writeRaster(rv, paste0(rasDir, 'ff1996.tif'), overwrite=T)
}

# Global human modification gradient (ghm2016)
if (!file.exists(paste0(vecDir,"ghm2016.shp"))) {
    cat('Global human modification gradient 2016...\n'); flush.console()
    x = raster(paste0(dropDir,'GlobalHumanModification/gHM.tif'))
    bnd_moll = st_transform(bnd, crs=crs(x))
    x2 = crop(x, bnd_moll)
    x3 = projectRaster(from=x2, to=rbnd, crs=prj, method='ngb', res=1000)
    x4 = mask(x3, rbnd)    
    r = reclassify(x4, c(-1,0.01,1, 0,1,NA)) # keep 0-0.01 values
    #writeRaster(r, paste0(rasDir,"ghm2016.tif"), overwrite=TRUE)
    # Vectorize...
    v <- st_as_stars(r) %>% 
        st_as_sf(merge = TRUE) %>% # this is the raster to polygons part
        st_cast("MULTIPOLYGON") %>% # cast the polygons to polylines
        ms_dissolve()
    st_write(v, paste0(vecDir,"ghm2016.shp"), delete_layer=T)
}

# Very low impact areas 2015 (vlia2015)
if (!file.exists(paste0(rasDir,"vlia2015.tif"))) {
    cat('Very low impact areas 2015...\n'); flush.console()
    x = raster(paste0(dropDir,'LowImpactAreas/Very_Low_impact.tif'))
    bnd_eck = st_transform(bnd, crs=crs(x))
    x2 = crop(x, bnd_eck)
    x3 = projectRaster(from=x2, to=rbnd, crs=prj, method='ngb', res=1000)
    x4 = mask(x3, rbnd)    
    r = reclassify(x4, c(-1,0,1, 0,128,NA)) # keep only 0 values
    #writeRaster(r, paste0(rasDir,"vlia2015.tif"), overwrite=TRUE)
    # Vectorize...
    v <- st_as_stars(r) %>% 
        st_as_sf(merge = TRUE) %>% # this is the raster to polygons part
        st_cast("MULTIPOLYGON") %>% # cast the polygons to polylines
        ms_dissolve()
    st_write(v, paste0(vecDir,"vlia2015.shp"), delete_layer=T)
}

# Global IFL (gifl, gifl2000, gifl2013, gifl2016)
for (i in c('', '2000', '2013', '2016')) {
    if (!file.exists(paste0(vecDir, 'gifl',i,'.shp'))) {
        cat('Global IFL',i,'...\n'); flush.console()
        if (i=='') {
        v = st_read(paste0(dropDir, 'GFW/forest_zone.shp')) %>%
            st_transform(prj) %>% ms_clip(bnd, sys=T) %>% ms_dissolve()
        } else {
        v = st_read(paste0(dropDir, 'GFW/ifl_',i,'.shp')) %>%
            st_transform(prj) %>% ms_clip(bnd, sys=T) %>% ms_dissolve()
        }
        st_write(v, paste0(vecDir, 'gifl',i,'.shp'), delete_layer=T)
        #v_raster = raster(v, res=cellsize)
        #rv = fasterize(v, v_raster, fun="sum")
        #writeRaster(rv, paste0(rasDir, 'gifl',i,'.tif'), overwrite=T)
    }
}

# Human footprint index (hfp2000, hfp2005, hfp2010, hfp2013)
for (i in c(2000, 2005, 2010, 2013)) {
    if (!file.exists(paste0(vecDir,"hfp",i,".shp"))) {
        cat('Human footprint ',i,'...\n'); flush.console()
        x = raster(paste0(dropDir, paste0('HumanFootprint/hfp',i,'_merisINT.tif')))
        bnd_moll = st_transform(bnd, crs=crs(x))
        x2 = crop(x, bnd_moll)
        x3 = projectRaster(from=x2, to=rbnd, crs=prj, method='ngb', res=1000)
        x4 = mask(x3, rbnd)    
        r = reclassify(x4, c(-Inf,0,1, 0,+Inf,NA)) # keep 0 values
        #writeRaster(r, paste0(rasDir,"hfp",i,".tif"), overwrite=TRUE)
        # Vectorize...
        v <- st_as_stars(r) %>% 
            st_as_sf(merge = TRUE) %>% # this is the raster to polygons part
            st_cast("MULTIPOLYGON") %>% # cast the polygons to polylines
            ms_dissolve()
        st_write(v, paste0(vecDir,"hfp",i,".shp"), delete_layer=T)
    }
}
