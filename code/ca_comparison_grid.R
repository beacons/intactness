# Grid-level Comparison
# PV 2017-09-07

library(tidyverse)
library(raster)
library(velox)
library(rgeos)

v <- shapefile("../../gisdata/intactness/analysis/vector_ca/ca_cifl_gifl_grid20k.shp")
v$area_km2 <- round(gArea(v, byid=T)/1000000,1)

r1 <- velox("../../gisdata/intactness/analysis/ca_boreal1000/cifl_gifl_grid20k.tif")
z1 <- r1$extract(v,fun=function(x){mean(x, na.rm=TRUE)})

r2 <- velox("../../gisdata/intactness/analysis/ca_boreal1000/cifl_gifl.tif")
z2 <- r2$extract(v,fun=function(x){sum(x, na.rm=TRUE)})
#z2 <- round(z2 * 250 * 250 / 1000000, 1)

r3 <- velox("../../gisdata/intactness/analysis/ca_boreal1000/cifl2013.tif")
z3 <- r3$extract(v, fun=function(x){sum(x, na.rm=TRUE)})

r4 <- velox("../../gisdata/intactness/analysis/ca_boreal1000/gifl2013.tif")
z4 <- r4$extract(v, fun=function(x){sum(x, na.rm=TRUE)})

r5 <- velox("../../gisdata/intactness/analysis/ca_boreal1000/hf2009.tif")
z5 <- r5$extract(v, fun=function(x){sum(x, na.rm=TRUE)})

r6 <- velox("../../gisdata/intactness/analysis/ca_boreal1000/ff.tif")
z6 <- r6$extract(v, fun=function(x){sum(x, na.rm=TRUE)})

r7 <- velox("../../gisdata/intactness/analysis/ca_boreal1000/un100.tif")
z7 <- r7$extract(v, fun=function(x){sum(x, na.rm=TRUE)})

r8 <- velox("../../gisdata/intactness/analysis/ca_boreal1000/wild.tif")
z8 <- r8$extract(v, fun=function(x){sum(x, na.rm=TRUE)})

r9 <- velox("../../gisdata/intactness/analysis/ca_boreal1000/msa90.tif")
z9 <- r9$extract(v, fun=function(x){sum(x, na.rm=TRUE)})

x = data.frame(NTS=z1, Area_km2=z2, CIFL2013=round(z3/z2,4), GIFL2013=round(z4/z2,4), HF2009=round(z5/z2,4), 
	FF=round(z6/z2,4), UNUSED=round(z7/z2,4), WILD=round(z8/z2,4), MSA=round(z9/z2,4))

write_csv(x, "docs/tables/ca_grid_confusion_matrix_1000_4dp.csv")

method = "pearson"
f <- tibble(map=c("CIFL2013","GIFL2013","HF2009","FF","UNUSED","WILD","MSA"),CIFL2013=c(1,0,0,0,0,0,0),GIFL2013=c("",1,0,0,0,0,0),HF2009=c("","",1,0,0,0,0),FF=c("","","",1,0,0,0),UNUSED=c("","","","",1,0,0),WILD=c("","","","","",1,0),MSA=c("","","","","","",1))

f[2,2] = round(cor(x$CIFL2013,x$GIFL2013, method=method),2)
f[3,2] = round(cor(x$CIFL2013,x$HF2009, method=method),2)
f[4,2] = round(cor(x$CIFL2013,x$FF, method=method),2)
f[5,2] = round(cor(x$CIFL2013,x$UNUSED, method=method),2)
f[6,2] = round(cor(x$CIFL2013,x$WILD, method=method),2)
f[7,2] = round(cor(x$CIFL2013,x$MSA, method=method),2)

f[3,3] = round(cor(x$GIFL2013,x$HF2009, method=method),2)
f[4,3] = round(cor(x$GIFL2013,x$FF, method=method),2)
f[5,3] = round(cor(x$GIFL2013,x$UNUSED, method=method),2)
f[6,3] = round(cor(x$GIFL2013,x$WILD, method=method),2)
f[7,3] = round(cor(x$GIFL2013,x$MSA, method=method),2)

f[4,4] = round(cor(x$HF2009,x$FF, method=method),2)
f[5,4] = round(cor(x$HF2009,x$UNUSED, method=method),2)
f[6,4] = round(cor(x$HF2009,x$WILD, method=method),2)
f[7,4] = round(cor(x$HF2009,x$MSA, method=method),2)

f[5,5] = round(cor(x$FF,x$UNUSED, method=method),2)
f[6,5] = round(cor(x$FF,x$WILD, method=method),2)
f[7,5] = round(cor(x$FF,x$MSA, method=method),2)

f[6,6] = round(cor(x$UNUSED,x$WILD, method=method),2)
f[7,6] = round(cor(x$UNUSED,x$MSA, method=method),2)
f[7,7] = round(cor(x$WILD,x$MSA, method=method),2)

write_csv(f, paste0("docs/tables/ca_grid_confusion_matrix_",method,".csv"))
