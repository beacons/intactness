# Prepare datasets for interpixel comparison within common study area (GIFL x CIFL)
# Projection: Canada Albers Equal Area (epsg: 102001)
# PV 2020-06-10

library(sf)
library(rgdal)
library(raster)
library(fasterize)

# General arguments
cellsize = 1000
vecDir = 'C:/Users/PIVER37/Documents/gisdata/intactness/boreal/'
tmpDir = 'C:/Users/PIVER37/Documents/gisdata/intactness/tmp/'
rasDir = paste0('C:/Users/PIVER37/Documents/gisdata/intactness/boreal/agree',cellsize,'/')
if (!dir.exists(rasDir)) dir.create(rasDir)

# Create raster boundary
boreal = st_read(paste0(vecDir, 'boreal.shp'))
cifl = st_read(paste0(vecDir, 'cifl.shp'))
gifl = st_read(paste0(vecDir, 'gifl.shp'))
bnd_raster = raster(boreal, res=cellsize)
rcifl = fasterize(cifl, bnd_raster, fun="sum")
rgifl = fasterize(gifl, bnd_raster, fun="sum")
r = rcifl * rgifl
xmin = max(extent(cifl)[1], extent(gifl)[1])
xmax = min(extent(cifl)[2], extent(gifl)[2])
ymin = max(extent(cifl)[3], extent(gifl)[3])
ymax = min(extent(cifl)[4], extent(gifl)[4])
bnd = raster::crop(r, c(xmin, xmax, ymin, ymax))
bnd0 = bnd * 0
writeRaster(bnd, paste0(rasDir, 'bnd.tif'))

# Rasterize HA2010
v = st_read(paste0(vecDir, 'ha2010.shp'))
r = fasterize(v, bnd, fun="sum")
rc = mask(crop(r, extent(bnd)), bnd)
rcc = cover(rc, bnd0)
writeRaster(rcc, paste0(rasDir, 'ha2010.tif'))

# Rasterise CIFL2013
v = st_read(paste0(vecDir, 'cifl2013.shp'))
r = fasterize(v, bnd, fun="sum")
rc = mask(crop(r, extent(bnd)), bnd)
rcc = cover(rc, bnd0)
writeRaster(rcc, paste0(rasDir, 'cifl2013.tif'))

# Rasterise GIFL2016
v = st_read(paste0(vecDir, 'gifl2016.shp'))
r = fasterize(v, bnd, fun="sum")
rc = mask(crop(r, extent(bnd)), bnd)
rcc = cover(rc, bnd0)
writeRaster(rcc, paste0(rasDir, 'gifl2016.tif'))

# Rasterise HFP2013
v = st_read(paste0(vecDir, 'hfp2013.shp'))
r = fasterize(v, bnd, fun="sum")
rc = mask(crop(r, extent(bnd)), bnd)
rcc = cover(rc, bnd0)
writeRaster(rcc, paste0(rasDir, 'hfp2013.tif'))

# Rasterize AB2015
v = st_read(paste0(vecDir, 'ab2015.shp'))
r = fasterize(v, bnd, fun="sum")
rc = mask(crop(r, extent(bnd)), bnd)
rcc = cover(rc, bnd0)
writeRaster(rcc, paste0(rasDir, 'ab2015.tif'), overwrite=T)

# Rasterize VLIA2015
v = st_read(paste0(vecDir, 'vlia2015.shp'))
r = fasterize(v, bnd, fun="sum")
rc = mask(crop(r, extent(bnd)), bnd)
rcc = cover(rc, bnd0)
writeRaster(rcc, paste0(rasDir, 'vlia2015.tif'), overwrite=T)

# Rasterize GHM2016
v = st_read(paste0(vecDir, 'ghm2016.shp'))
r = fasterize(v, bnd, fun="sum")
rc = mask(crop(r, extent(bnd)), bnd)
rcc = cover(rc, bnd0)
writeRaster(rcc, paste0(rasDir, 'ghm2016.tif'), overwrite=T)
