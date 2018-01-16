# Calculate the area of each dataset within the Canadian boreal region
# PV 2018-01-03

library(rgdal)
library(raster)
library(tidyverse)

dataDir <- "../../gisdata/intactness/analysis/"
boreal <- raster(paste0(dataDir,"ca_boreal1000/boreal.tif"))
z = cellStats(boreal, sum)
x <- tibble(dataset=c("HA2010","CIFL2013","CIFL2000","GIFL2013","GIFL2000","HF2009","HF1993","FF","UNUSED","WILD","MSA"),
	boreal_km2=z,cover_km2=z,cover_pct=0,intact_km2=0,intact_pct_boreal=0,intact_pct_cover=0)

# Canada Access
#r_bnd = raster(paste0(dataDir,"ca_boreal1000/pba.tif"))
#x$cover_km2[x$dataset %in% c("HA2010")] <- cellStats(r_bnd, sum)
r1 = raster(paste0(dataDir,"ca_boreal1000/ha2010.tif"))
x$intact_km2[x$dataset=="HA2010"] <- cellStats(r1, sum)

# Canada IFL
r_bnd = raster(paste0(dataDir,"ca_boreal1000/cifl.tif"))
x$cover_km2[x$dataset %in% c("CIFL2000","CIFL2013")] <- cellStats(r_bnd, sum)
r1 = raster(paste0(dataDir,"ca_boreal1000/cifl2013.tif"))
x$intact_km2[x$dataset=="CIFL2013"] <- cellStats(r1, sum)
r2 = raster(paste0(dataDir,"ca_boreal1000/cifl2000.tif"))
x$intact_km2[x$dataset=="CIFL2000"] <- cellStats(r2, sum)

# Global IFL
r_bnd = raster(paste0(dataDir,"ca_boreal1000/gifl.tif"))
x$cover_km2[x$dataset %in% c("GIFL2000","GIFL2013")] <- cellStats(r_bnd, sum)
r1 = raster(paste0(dataDir,"ca_boreal1000/gifl2013.tif"))
x$intact_km2[x$dataset=="GIFL2013"] <- cellStats(r1, sum)
r2 = raster(paste0(dataDir,"ca_boreal1000/gifl2000.tif"))
x$intact_km2[x$dataset=="GIFL2000"] <- cellStats(r2, sum)

### Human Footprint
r1 = raster(paste0(dataDir,"ca_boreal1000/hf2009.tif"))
NAvalue(r1) <- 128
x$intact_km2[x$dataset=="HF2009"] <- cellStats(r1, sum)
r2 = raster(paste0(dataDir,"ca_boreal1000/hf1993.tif"))
NAvalue(r2) <- 128
x$intact_km2[x$dataset=="HF1993"] <- cellStats(r2, sum)

### Frontier Forests
r = raster(paste0(dataDir,"ca_boreal1000/ff.tif"))
x$intact_km2[x$dataset=="FF"] <- cellStats(r, sum)

### HANPP
r = raster(paste0(dataDir,"ca_boreal1000/un100.tif"))
x$intact_km2[x$dataset=="UNUSED"] <- cellStats(r, sum)

### Anthromes
r = raster(paste0(dataDir,"ca_boreal1000/wild.tif"))
NAvalue(r) <- 128
x$intact_km2[x$dataset=="WILD"] <- cellStats(r, sum)

### GLOBIO
r = raster(paste0(dataDir,"ca_boreal1000/msa90.tif"))
x$intact_km2[x$dataset=="MSA"] <- cellStats(r, sum)

x$cover_pct = round(x$cover_km2 / x$boreal_km2 * 100,1)
x$intact_pct_boreal = round(x$intact_km2 / x$boreal_km2 * 100,1)
x$intact_pct_cover = round(x$intact_km2 / x$cover_km2 * 100,1)

write_csv(x, "output/ca_coverage.csv")
