library(foreign)
library(rgeos)
library(raster)
library(tidyverse)
library(leaflet)

region = "yt_mining"
disturb = "mining"
dataDir <- "../../gisdata/intactness/analysis/"

bnd = shapefile(paste0(dataDir,region,"/vector/bnd.shp"))
bnd_area = gArea(bnd) / 1000000
r_bnd = read.dbf(paste0(dataDir,region,"/raster/bnd.tif.vat.dbf"))
r_bnd_area = r_bnd$Count * 30 * 30 / 1000000
r_mining = shapefile(paste0(dataDir,region,"/vector/mining.shp"))
r_mining_area = gArea(r_mining) / 1000000

maps=c("ha2010","cifl2013","gifl2013","hf2009","ff","un100","wild","msa90")
x <- tibble(map=maps,region_km2=round(bnd_area,0),intact_km2=0,intact_pct=0,mining_km2=round(r_mining_area,0),omitted_km2=0,omitted_pct=0)

for (i in maps) {
	ii = read.dbf(paste0(dataDir,region,"/raster/",i,".tif.vat.dbf"))
	x[x$map==i, "intact_km2"] <- ii$Count * 30 * 30 / 1000000
	d <- read.dbf(paste0(dataDir,region,"/vector/",i,"_mining.dbf"))
	if (nrow(d)==0) {
		x[x$map==i, "omitted_km2"] <- 0
	} else {
		v <- shapefile(paste0(dataDir,region,"/vector/",i,"_mining.shp"))
		x[x$map==i, "omitted_km2"] <- gArea(v) / 1000000
	}
}

x$intact_pct <- x$intact_km2 / r_bnd_area
x$omitted_pct <- x$omitted_km2 / r_mining_area
x$intact_km2 <- round(x$intact_km2, 0)
x$intact_pct <- round(x$intact_pct * 100, 0)
x$omitted_km2 <- round(x$omitted_km2, 0)
x$omitted_pct <- round(x$omitted_pct * 100, 0)

write_csv(x, "output/yt_mining_accuracy.csv")
