library(foreign)
library(rgeos)
library(raster)
library(tidyverse)
library(leaflet)

region = "ab_seismic"
dataDir <- "../../gisdata/intactness/analysis/"

bnd = shapefile(paste0(dataDir,region,"/vector/bnd.shp"))
bnd_area = gArea(bnd) / 1000000
r_bnd = read.dbf(paste0(dataDir,region,"/raster/bnd.tif.vat.dbf"))
r_bnd_area = r_bnd$Count * 30 * 30 / 1000000
r_seismic_2012 = shapefile(paste0(dataDir,region,"/vector/abmi2012.shp"))
r_seismic_2012 <- r_seismic_2012[r_seismic_2012$PublicCode=="Seismic line",]
r_seismic_2012_area = gArea(r_seismic_2012) / 1000000
r_seismic_2010 = shapefile(paste0(dataDir,region,"/vector/abmi2010.shp"))
r_seismic_2010 <- r_seismic_2010[r_seismic_2010$PublicCode=="Seismic line",]
r_seismic_2010_area = gArea(r_seismic_2010) / 1000000
r_seismic_2007 = shapefile(paste0(dataDir,region,"/vector/abmi2007.shp"))
r_seismic_2007 <- r_seismic_2007[r_seismic_2007$FEATURE_TY=="CUTLINE-TRAIL",]
r_seismic_2007_area = gArea(r_seismic_2007) / 1000000

maps=c("ha2010","cifl2013","gifl2013","hf2009","ff","un100","wild","msa90")
x <- tibble(map=maps,region_km2=round(bnd_area,0),intact_km2=0,intact_pct=0,seismic_km2=0,omitted_km2=0,omitted_pct=0)

for (i in c("ha2010","cifl2013","gifl2013","hf2009","ff","un100","wild","msa90")) {
	ii = read.dbf(paste0(dataDir,region,"/raster/",i,".tif.vat.dbf"))
	x[x$map==i, "intact_km2"] <- ii$Count * 30 * 30 / 1000000
	if (i %in% c("cifl2013","gifl2013")) {
		v <- shapefile(paste0(dataDir,region,"/vector/",i,"_abmi2012.shp"))
		v <- v[v$PublicCode=="Seismic line",]
		x[x$map==i, "seismic_km2"] <- r_seismic_2012_area
		x[x$map==i, "omitted_km2"] <- gArea(v) / 1000000
	} else if (i %in% c("ha2010")) {
		v <- shapefile(paste0(dataDir,region,"/vector/",i,"_abmi2010.shp"))
		v <- v[v$PublicCode=="Seismic line",]
		x[x$map==i, "seismic_km2"] <- r_seismic_2010_area
		x[x$map==i, "omitted_km2"] <- gArea(v) / 1000000
	} else {
		v <- shapefile(paste0(dataDir,region,"/vector/",i,"_abmi2007.shp"))
		v <- v[v$FEATURE_TY=="CUTLINE-TRAIL",]
		x[x$map==i, "seismic_km2"] <- r_seismic_2007_area
		x[x$map==i, "omitted_km2"] <- gArea(v) / 1000000
	}
}

x$intact_pct <- x$intact_km2 / r_bnd_area
x$omitted_pct <- x$omitted_km2 / x$seismic_km2
x$seismic_km2 <- round(x$seismic_km2, 0)
x$intact_km2 <- round(x$intact_km2, 0)
x$intact_pct <- round(x$intact_pct * 100, 0)
x$omitted_km2 <- round(x$omitted_km2, 0)
x$omitted_pct <- round(x$omitted_pct * 100, 0)

write_csv(x, paste0("output/ab_seismic_accuracy.csv"))
