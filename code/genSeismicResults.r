library(foreign)
library(rgeos)
library(raster)
library(tidyverse)
library(leaflet)

region = "ab_seismic"

bnd = shapefile(paste0("data/",region,"/vector/bnd.shp"))
bnd_area = gArea(bnd) / 1000000
r_bnd = read.dbf(paste0("data/",region,"/raster/bnd.tif.vat.dbf"))
r_bnd_area = r_bnd$Count * 30 * 30 / 1000000
r_seismic_2012 = shapefile(paste0("data/",region,"/vector/abmi2012.shp"))
r_seismic_2012 <- r_seismic_2012[r_seismic_2012$PublicCode=="Seismic line",]
r_seismic_2012_area = gArea(r_seismic_2012) / 1000000
r_seismic_2007 = shapefile(paste0("data/",region,"/vector/abmi2007.shp"))
r_seismic_2007 <- r_seismic_2007[r_seismic_2007$FEATURE_TY=="CUTLINE-TRAIL",]
r_seismic_2007_area = gArea(r_seismic_2007) / 1000000

maps=c("cifl2013","gifl2013","hf2009","ff","un100","wild","msa90")
x <- tibble(map=maps,region_km2=round(bnd_area,0),intact_km2=0,intact_pct=0,seismic_km2=0,omitted_km2=0,omitted_pct=0)

for (i in c("cifl2013","gifl2013","hf2009","ff","un100","wild","msa90")) {
	ii = read.dbf(paste0("data/",region,"/raster/",i,".tif.vat.dbf"))
	x[x$map==i, "intact_km2"] <- ii$Count * 30 * 30 / 1000000
	if (i %in% c("cifl2013","gifl2013")) {
		v <- shapefile(paste0("data/",region,"/vector/",i,"_abmi2012.shp"))
		v <- v[v$PublicCode=="Seismic line",]
		x[x$map==i, "seismic_km2"] <- r_seismic_2012_area
		x[x$map==i, "omitted_km2"] <- gArea(v) / 1000000
	} else {
		v <- shapefile(paste0("data/",region,"/vector/",i,"_abmi2007.shp"))
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

write_csv(x, paste0("data/",region,"/seismic_accuracy.csv"))

mapSeismic <- function() {
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
	#abmi2014 <- shapefile(paste0("data/",region,"/vector/abmi2014.shp"))
	#abmi2014 <- spTransform(abmi2014, CRS("+proj=longlat +datum=WGS84"))
	#seismic2014 <- abmi2014[abmi2014$PUBLIC_COD=="Seismic line",]
	abmi2012 <- shapefile(paste0("data/",region,"/vector/abmi2012.shp"))
	abmi2012 <- spTransform(abmi2012, CRS("+proj=longlat +datum=WGS84"))
	seismic2012 <- abmi2012[abmi2012$PublicCode=="Seismic line",]
	#abmi2010 <- shapefile(paste0("data/",region,"/vector/abmi2010.shp"))
	#abmi2010 <- spTransform(abmi2010, CRS("+proj=longlat +datum=WGS84"))
	#seismic2010 <- abmi2010[abmi2010$PublicCode=="Seismic line",]
	abmi2007 <- shapefile(paste0("data/",region,"/vector/abmi2007.shp"))
	abmi2007 <- spTransform(abmi2007, CRS("+proj=longlat +datum=WGS84"))
	seismic2007 <- abmi2007[abmi2007$FEATURE_TY=="CUTLINE-TRAIL",]

	m <- leaflet(bnd) %>%
		addProviderTiles("Esri.NatGeoWorldMap", group="Esri.NatGeoWorldMap") %>%
		addProviderTiles("Esri.WorldImagery", group="Esri.WorldImagery") %>%
		addPolygons(data=bnd, fill=F, weight=2, color="black", fillOpacity=1, group="Ecoregion") %>%
		#addPolygons(data=seismic2014, fill=F, weight=2, color="black", fillOpacity=1, group="Seismic2014") %>%
		addPolygons(data=seismic2012, fill=F, weight=2, color="black", fillOpacity=1, group="Seismic2012") %>%
		#addPolygons(data=seismic2010, fill=F, weight=2, color="red", fillOpacity=1, group="Seismic2010") %>%
		addPolygons(data=seismic2007, fill=F, weight=2, color="blue", fillOpacity=1, group="Seismic2007") %>%
		addPolygons(data=cifl2013, fill=T, weight=2, color="darkred", fillOpacity=0.5, group="CIFL2013") %>%
		addPolygons(data=gifl2013, fill=T, weight=2, color="darkgreen", fillOpacity=0.5, group="GIFL2013") %>%
		addPolygons(data=hf2009, fill=T, weight=2, color="darkblue", fillOpacity=0.5, group="HF2009") %>%
		addPolygons(data=ff, fill=T, weight=2, color="grey", fillOpacity=0.5, group="FF") %>%
		addPolygons(data=unused, fill=T, weight=2, color="red", fillOpacity=0.5, group="UNUSED") %>%
		addPolygons(data=wild, fill=T, weight=2, color="blue", fillOpacity=0.5, group="WILD") %>%
		addPolygons(data=msa, fill=T, weight=2, color="green", fillOpacity=0.5, group="MSA") %>%
		addLayersControl(position = "topright",
			baseGroups=c("Esri.NatGeoWorldMap", "Esri.WorldImagery"),
			overlayGroups = c("Ecoregion","Seismic2012","Seismic2007","CIFL2013","GIFL2013","HF2009","FF","UNUSED","WILD","MSA"),
			options = layersControlOptions(collapsed = FALSE)) %>%
			hideGroup(c("Seismic2012","Seismic2007","CIFL2013","GIFL2013","HF2009","FF","UNUSED","WILD","MSA"))
	print(m)
}
mapSeismic()
