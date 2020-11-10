# Calculate the area of each dataset within the Canadian boreal region
# PV 2020-06-10

library(sf)
library(tidyverse)

maps=c('ha2010','cifl2000','cifl2013','gifl2000','gifl2013','gifl2016','hfp2000','hfp2005','hfp2010','hfp2013','ab2000','ab2005','ab2010','ab2015','ghm2016','vlia2015')
dataDir <- 'C:/Users/PIVER37/Documents/gisdata/intactness/boreal/'
boreal <- st_read(paste0(dataDir,"boreal.shp"))
boreal_km2 = st_area(boreal)/1000000
x <- tibble(dataset=maps,
	boreal_km2=boreal_km2,cover_km2=0,cover_pct=0,intact_km2=0,intact_pct_boreal=0,intact_pct_cover=0)

# Calculate coverage of cifl and gifl datasets
vc = st_read(paste0(dataDir,'cifl.shp')) # VERIFY THIS IS THE APPROPRIATE DATASET FOR HA2010
x$cover_km2[x$dataset %in% c('cifl2000','cifl2013')] = st_area(vc)/1000000
vc = st_read(paste0(dataDir,'gifl.shp'))
x$cover_km2[x$dataset %in% c('gifl2000','gifl2013','gifl2016')] = st_area(vc)/1000000
x$cover_km2[x$dataset %in% c('ha2010','hfp2000','hfp2005','hfp2010','hfp2013','ab2000','ab2005','ab2010','ab2015','ghm2016','vlia2015')] = boreal_km2

# Calculate area intact in each dataset
for (i in maps) {
    vi = st_read(paste0(dataDir,i,".shp"))
    x$intact_km2[x$dataset==i] = sum(st_area(vi))/1000000
}

x = mutate(x,
    cover_pct = round(cover_km2 / boreal_km2 * 100,1),
    intact_pct_boreal = round(intact_km2 / boreal_km2 * 100,1),
    intact_pct_cover = round(intact_km2 / cover_km2 * 100,1))

write_csv(x, "2_cover/output/ca_coverage.csv")
