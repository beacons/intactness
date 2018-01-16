library(foreign)
library(rgeos)
library(raster)
library(tidyverse)
library(leaflet)

region = "bc_harvest"
disturb = "harvest"
dataDir <- "../../gisdata/intactness/analysis/"

bnd = shapefile(paste0(dataDir,region,"/vector/bnd.shp"))
bnd_area = gArea(bnd) / 1000000
r_bnd = read.dbf(paste0(dataDir,region,"/raster/bnd.tif.vat.dbf"))
r_bnd_area = r_bnd$Count * 30 * 30 / 1000000
r_harvest = shapefile(paste0(dataDir,region,"/vector/harvest.shp"))
r_harvest$year <- as.integer(r_harvest$GRIDCODE)

maps=c("ha2010","cifl2013","gifl2013","hf2009","ff","un100","wild","msa90")
x <- tibble(map=maps,region_km2=round(bnd_area,0),intact_km2=0,intact_pct=0,harvest_km2=0,omitted_km2=0,omitted_pct=0)

for (i in c("ha2010","cifl2013","gifl2013","hf2009","ff","un100","wild","msa90")) {
	if (file.exists(paste0(dataDir,region,"/raster/",i,".tif.vat.dbf"))) {
		ii = read.dbf(paste0(dataDir,region,"/raster/",i,".tif.vat.dbf"))
		x[x$map==i, "intact_km2"] <- ii$Count * 30 * 30 / 1000000
	} else {
		x[x$map==i, "intact_km2"] <- 0
	}
	if (file.exists(paste0(dataDir,region,"/raster/",i,"_",disturb,".tif.vat.dbf"))) {
		hi <- read.dbf(paste0(dataDir,region,"/raster/",i,"_",disturb,".tif.vat.dbf"))
		if (i=="hf2009") {
			hi <- filter(hi, VALUE<109)
		} else if (i=="ff") {
			hi <- filter(hi, VALUE<97)
		} else if (i %in% c("un100","wild","msa90")) {
			hi <- filter(hi, VALUE<100)
		}
		x[x$map==i, "omitted_km2"] <- sum(hi$COUNT) * 30 * 30 / 1000000
	} else {
		x[x$map==i, "omitted_km2"] <- 0
	}
	if (i=="hf2009") {
		r_harvest_sub <- r_harvest[r_harvest$year<109,]
		r_harvest_area = gArea(r_harvest_sub) / 1000000
	} else if (i=="ff") {
		r_harvest_sub <- r_harvest[r_harvest$year<97,]
		r_harvest_area = gArea(r_harvest_sub) / 1000000
	} else if (i %in% c("un100","wild","msa90")) {
		r_harvest_sub <- r_harvest[r_harvest$year<100,]
		r_harvest_area = gArea(r_harvest_sub) / 1000000
	} else {
		r_harvest_area = gArea(r_harvest) / 1000000
	}
	x[x$map==i, "harvest_km2"] <- r_harvest_area
}

x$intact_pct <- x$intact_km2 / r_bnd_area
x$omitted_pct <- x$omitted_km2 / x$harvest_km2
x$harvest_km2 <- round(x$harvest_km2, 0)
x$intact_km2 <- round(x$intact_km2, 0)
x$intact_pct <- round(x$intact_pct * 100, 0)
x$omitted_km2 <- round(x$omitted_km2, 0)
x$omitted_pct <- round(x$omitted_pct * 100, 0)

write_csv(x, "output/bc_harvest_accuracy.csv")
