# Prepare datasets for coverage estimation within Brandt's boreal region
# Projection: Canada Albers Equal Area (epsg: 102001)
# PV 2021-10-19

# NOTE: This script won't work unless you change lines 20-23 to point to directories on your computer
#       You will also need to download all the required datasets (see s1_datasets.md for links)

library(sf)
library(rgdal)
library(stars)
library(raster)
library(lwgeom)
library(gdalUtils)
library(fasterize)
library(rmapshaper)


# Set workspace & parameters
cellsize = 1000
prj = "+proj=aea +lat_1=50 +lat_2=70 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
dropDir = 'C:/Users/PIVER37/Dropbox (BEACONs)/gisdata/intactness/'
vecDir = 'C:/Users/PIVER37/Documents/github/intactness/data/boreal/'
rasDir = paste0('C:/Users/PIVER37/Documents/github/intactness/data/boreal/raster',cellsize,'/')
if (!dir.exists(vecDir)) dir.create(vecDir, recursive=T)
if (!dir.exists(rasDir)) dir.create(rasDir, recursive=T)


# Create boreal boundary minus water (vector & raster)
# Create analysis mask i.e., boreal minus large lakes that are excluded from CIFL & GIFL
    #lakes = st_read(paste0(dropDir, 'Lakes/boreal_lakes.shp'))
if (!file.exists(paste0(vecDir, 'boreal.shp'))) {
    bnd = st_read(paste0(dropDir, 'BrandtsBoreal/NABoreal.shp'), stringsAsFactors=TRUE, 
        query="select * FROM \"NABoreal\" WHERE (TYPE = 'BOREAL' OR TYPE = 'B_ALPINE') AND COUNTRY = 'CANADA'") %>%
        ms_dissolve() %>% st_transform(prj)
    st_write(bnd, paste0(vecDir, 'boreal.shp'), delete_layer=T)
    rbnd = fasterize(bnd, raster(bnd, res=cellsize), fun="sum")
    writeRaster(rbnd, paste0(rasDir, 'boreal.tif'), overwrite=T)
} else {
    bnd = st_read(paste0(vecDir, 'boreal.shp'))
    rbnd = raster(paste0(rasDir, 'boreal.tif'), crs=crs(bnd))
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
        writeRaster(r, paste0(rasDir,"ab",i,".tif"), overwrite=TRUE)
        # Vectorize...
        v <- st_as_stars(r) %>% 
            st_as_sf(merge = TRUE) %>% # this is the raster to polygons part
            st_cast("MULTIPOLYGON") %>% # cast the polygons to polylines
            ms_dissolve()
        st_write(v, paste0(vecDir,"ab",i,".shp"), delete_layer=T)
    }
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
    writeRaster(r, paste0(rasDir,"ghm2016.tif"), overwrite=TRUE)
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
    writeRaster(r, paste0(rasDir,"vlia2015.tif"), overwrite=TRUE)
    # Vectorize...
    v <- st_as_stars(r) %>% 
        st_as_sf(merge = TRUE) %>% # this is the raster to polygons part
        st_cast("MULTIPOLYGON") %>% # cast the polygons to polylines
        ms_dissolve()
    st_write(v, paste0(vecDir,"vlia2015.shp"), delete_layer=T)
}


# Human access 2010 (ha2010)
if (!file.exists(paste0(vecDir, 'ha2010.shp'))) {
    cat('Human access...\n'); flush.console()
    v = st_read(paste0(dropDir, 'GFWC/HumanAccess_2010/Canada_Access_2010.shp')) %>%
        st_transform(prj) %>% ms_clip(bnd, sys=T) %>% ms_dissolve()
    
    ##################################
    # CURRENTLY ONLY WORKS WITH ARCGIS
    st_write(v, paste0(vecDir, 'ha2010_disturbances.shp'), delete_layer=T)
    #v_erase = ms_erase(bnd, v, sys=T)
    #st_write(v_erase, paste0(vecDir, 'ha2010.shp'), delete_layer=T)
    ##################################
    
    v_erase = st_read(paste0(vecDir, 'ha2010.shp'))
    v_raster = raster(v_erase, res=cellsize)
    rv = fasterize(v_erase, v_raster, fun="sum")
    writeRaster(rv, paste0(rasDir, 'ha2010.tif'), overwrite=T)
}


# Canada IFL (cifl, cifl2000, cifl2013)
for (i in c('', '2000', '2013')) {
    if (!file.exists(paste0(vecDir, 'cifl',i,'.shp'))) {
        cat('Canada IFL',i,'...\n'); flush.console()
        if (i=='') {
        v = st_read(paste0(dropDir, 'GFWC/GFWC_Study_Area_StatsCan_BND2006.shp')) %>%
            st_transform(prj) %>% ms_clip(bnd, sys=T) %>% ms_dissolve()
        } else if (i=='2000') {
        v = st_read(paste0(dropDir, 'GFWC/Canada_IFL_circa2000_Revised.shp')) %>%
            st_transform(prj) %>% ms_clip(bnd, sys=T) %>% ms_dissolve()
        } else {
        v = st_read(paste0(dropDir, 'GFWC/GFWC_Canada_IFL_2013_Final.shp')) %>%
            st_transform(prj) %>% ms_clip(bnd, sys=T) %>% ms_dissolve()
        }
        st_write(v, paste0(vecDir, 'cifl',i,'.shp'), delete_layer=T)
        v_raster = raster(v, res=cellsize)
        rv = fasterize(v, v_raster, fun="sum")
        writeRaster(rv, paste0(rasDir, 'cifl',i,'.tif'), overwrite=T)
    }
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
        v_raster = raster(v, res=cellsize)
        rv = fasterize(v, v_raster, fun="sum")
        writeRaster(rv, paste0(rasDir, 'gifl',i,'.tif'), overwrite=T)
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
        #writeRaster(x4, paste0(rasDir,"hfp",i,"_0-50.tif"), overwrite=TRUE)
        r = reclassify(x4, c(-Inf,0,1, 0,+Inf,NA)) # keep 0 values
        writeRaster(r, paste0(rasDir,"hfp",i,".tif"), overwrite=TRUE)
        # Vectorize...
        v <- st_as_stars(r) %>% 
            st_as_sf(merge = TRUE) %>% # this is the raster to polygons part
            st_cast("MULTIPOLYGON") %>% # cast the polygons to polylines
            ms_dissolve()
        st_write(v, paste0(vecDir,"hfp",i,".shp"), delete_layer=T)
    }
}


################################################################################
# ADDED 2021-10-17
################################################################################

can300dir = 'C:/Users/PIVER37/Documents/gisdata/canada/raster300/'
bnd = st_read(paste0(vecDir, 'boreal.shp')) %>% mutate(one=1)
rbnd300 = fasterize(bnd, raster(bnd, res=300), field='one')
writeRaster(rbnd300, paste0(vecDir, 'raster300/boreal300.tif'), overwrite=T)
rbnd1000 = raster(paste0(vecDir, 'raster1000/boreal.tif'))

# Human footprint for Canada
r = raster(paste0(can300dir, 'hfp.tif'))
rc = crop(r, rbnd300)
rcr = resample(rc, rbnd300)
rcrm = mask(rcr, rbnd300)
writeRaster(rcrm, paste0(vecDir,'raster300/hfp.tif'), overwrite=TRUE)
# A 0.11 threshold seems best; 0.1 or less results in squared off sections
rcrmr0 = reclassify(rcrm, c(-Inf,0.11,1, 0.11,+Inf,NA)) # keep 0 values
writeRaster(rcrmr0, paste0(vecDir,'raster300/hfp2019.tif'), overwrite=TRUE)
r1000 = resample(rcrmr0, rbnd1000, method='bilinear')
writeRaster(r1000, paste0(vecDir,'raster1000/hfp2019.tif'), overwrite=TRUE)
# Vectorize...
r = rast(rcrmr0)
v <- as.polygons(r)
writeVector(v, 'data/boreal/hfp2019.shp', overwrite=TRUE)
#v <- rasterToPolygons(x, fun=NULL, n=4, na.rm=TRUE, digits=12, dissolve=FALSE)
#v <- st_as_stars(rcrmr0) %>% 
#    st_as_sf(merge = TRUE) %>% # this is the raster to polygons part
#    st_cast("MULTIPOLYGON") %>% # cast the polygons to polylines
#    ms_dissolve()
#st_write(v, paste0(vecDir,"hfp2019.shp"), delete_layer=T)

# Forest landscape integrity
r = raster(paste0(can300dir, 'flii.tif'))
rc = crop(r, rbnd300)
rc[rc==-9999] = NA
rc = rc/1000
rcr = resample(rc, rbnd300)
rcrm = mask(rcr, rbnd300)
writeRaster(rcrm, paste0(vecDir,'raster300/flii.tif'), overwrite=TRUE)
rcrmr = reclassify(rcrm, c(-Inf,10,0, 10,+Inf,NA)) # keep 0 values
writeRaster(rcrmr, paste0(vecDir,'raster300/flii1.tif'), overwrite=TRUE)
