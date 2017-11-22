library(foreign)
library(rgeos)
library(raster)
library(tidyverse)
library(leaflet)

region = "bc_harvest"
disturb = "harvest"

bnd = shapefile(paste0("data/",region,"/vector/bnd.shp"))
bnd_area = gArea(bnd) / 1000000
r_bnd = read.dbf(paste0("data/",region,"/raster/bnd.tif.vat.dbf"))
r_bnd_area = r_bnd$Count * 30 * 30 / 1000000
r_harvest = shapefile(paste0("data/",region,"/vector/harvest.shp"))
r_harvest$year <- as.integer(r_harvest$GRIDCODE)

maps=c("cifl2013","gifl2013","hf2009","ff","un100","wild","msa90")
x <- tibble(map=maps,region_km2=round(bnd_area,0),intact_km2=0,intact_pct=0,harvest_km2=0,omitted_km2=0,omitted_pct=0)

for (i in c("cifl2013","gifl2013","hf2009","ff","un100","wild","msa90")) {
	if (file.exists(paste0("data/",region,"/raster/",i,".tif.vat.dbf"))) {
		ii = read.dbf(paste0("data/",region,"/raster/",i,".tif.vat.dbf"))
		x[x$map==i, "intact_km2"] <- ii$Count * 30 * 30 / 1000000
	} else {
		x[x$map==i, "intact_km2"] <- 0
	}
	if (file.exists(paste0("data/",region,"/raster/",i,"_",disturb,".tif.vat.dbf"))) {
		hi <- read.dbf(paste0("data/",region,"/raster/",i,"_",disturb,".tif.vat.dbf"))
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
x$omitted_pct <- x$omitted_km2 / x$harvest_km2 * 100
x$harvest_km2 <- round(x$harvest_km2, 0)
x$intact_km2 <- round(x$intact_km2, 0)
x$intact_pct <- round(x$intact_pct * 100, 0)
x$omitted_km2 <- round(x$omitted_km2, 0)
x$omitted_pct <- round(x$omitted_pct * 100, 0)

write_csv(x, paste0("data/",region,"/",disturb,"_accuracy.csv"))


mapHarvest <- function() {
	bnd <- spTransform(bnd, CRS("+proj=longlat +datum=WGS84"))
	cifl2013 = shapefile(paste0("data/",region,"/vector/cifl2013.shp"))
	cifl2013 <- spTransform(cifl2013, CRS("+proj=longlat +datum=WGS84"))
	gifl2013 = shapefile(paste0("data/",region,"/vector/gifl2013.shp"))
	gifl2013 <- spTransform(gifl2013, CRS("+proj=longlat +datum=WGS84"))
	hf2009 = shapefile(paste0("data/",region,"/vector/hf2009.shp"))
	hf2009 <- spTransform(hf2009, CRS("+proj=longlat +datum=WGS84"))
	ff = shapefile(paste0("data/",region,"/vector/ff.shp"))
	ff <- spTransform(ff, CRS("+proj=longlat +datum=WGS84"))
	unused = shapefile(paste0("data/",region,"/vector/un100.shp"))
	unused <- spTransform(unused, CRS("+proj=longlat +datum=WGS84"))
	wild = shapefile(paste0("data/",region,"/vector/wild.shp"))
	wild <- spTransform(wild, CRS("+proj=longlat +datum=WGS84"))
	msa = shapefile(paste0("data/",region,"/vector/msa90.shp"))
	msa <- spTransform(msa, CRS("+proj=longlat +datum=WGS84"))
	harvest <- shapefile(paste0("data/",region,"/vector/harvest.shp"))
	harvest <- spTransform(harvest, CRS("+proj=longlat +datum=WGS84"))
	#rharvest <- raster(paste0("data/",region,"/raster/harvest.tif"))
	#rharvest <- spTransform(rharvest, crs="+proj=longlat +datum=WGS84")
	#pc1_cols <- colorNumeric(palette="YlOrBr", values(rharvest), na.color = "transparent", reverse=TRUE)
	#pc1_cols <- colorNumeric(palette=viridis(n=10,option="D"), values(pc1), na.color = "transparent", reverse=FALSE)

	harvest$year <- as.integer(harvest$GRIDCODE) + 1900
	pal <- colorNumeric(palette = "RdYlGn", domain = harvest$year, reverse=TRUE)

	m <- leaflet(bnd) %>%
		addProviderTiles("Esri.NatGeoWorldMap", group="Esri.NatGeoWorldMap") %>%
		addProviderTiles("Esri.WorldImagery", group="Esri.WorldImagery") %>%
		addPolygons(data=bnd, fill=F, weight=2, color="black", fillOpacity=1, group="Ecoregion") %>%
		addPolygons(data=harvest, fill=T, weight=2, color=~pal(year), smoothFactor=0.2, fillOpacity=1, group="Harvest") %>%
		addLegend("bottomright", pal = pal, values = ~harvest$year, title = "Harvest Year", labFormat=labelFormat(big.mark=''), opacity = 1) %>%
		addPolygons(data=cifl2013, fill=T, weight=2, color="darkred", fillOpacity=0.5, group="CIFL2013") %>%
		addPolygons(data=gifl2013, fill=T, weight=2, color="darkgreen", fillOpacity=0.5, group="GIFL2013") %>%
		addPolygons(data=hf2009, fill=T, weight=2, color="darkblue", fillOpacity=0.5, group="HF2009") %>%
		addPolygons(data=ff, fill=T, weight=2, color="grey", fillOpacity=0.5, group="FF") %>%
		addPolygons(data=unused, fill=T, weight=2, color="red", fillOpacity=0.5, group="UNUSED") %>%
		addPolygons(data=wild, fill=T, weight=2, color="blue", fillOpacity=0.5, group="WILD") %>%
		addPolygons(data=msa, fill=T, weight=2, color="green", fillOpacity=0.5, group="MSA") %>%
		#addRasterImage(rharvest, col=pc1_cols, opacity=0.8, group="Temp indicator") %>%
		#addLegend(pal=pc1_cols, values=values(rharvest), bins=5, position=c("bottomright"), title="Temp indicator", opacity=0.8) %>%
		addLayersControl(position = "topright",
			baseGroups=c("Esri.NatGeoWorldMap", "Esri.WorldImagery"),
			overlayGroups = c("Ecoregion","Harvest","CIFL2013","GIFL2013","HF2009","FF","UNUSED","WILD","MSA"),
			options = layersControlOptions(collapsed = FALSE)) %>%
			hideGroup(c("Harvest","CIFL2013","GIFL2013","HF2009","FF","UNUSED","WILD","MSA"))
	print(m)
}
#mapHarvest()
