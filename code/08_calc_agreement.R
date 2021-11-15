# Run spatial agreement analysis
# PV 2021-10-19

library(raster)
library(tidyverse)

cellsize = 1000; k=1
#cellsize = 250; k=16
rasDir = paste0('data/boreal/agree',cellsize,'/')
bnd = raster(paste0(rasDir, 'bnd.tif'))
maps1 = c('ha2010','cifl2013','gifl2016','hfp2013','hfp2019','ab2015','ghm2016','vlia2015')
n = length(maps1)
z = tibble(map=maps1, ha2010=numeric(n), cifl2013=numeric(n), gifl2016=numeric(n), hfp2013=numeric(n), hfp2019=numeric(n), ab2015=numeric(n), ghm2016=numeric(n), vlia2015=numeric(n))
n=1
jj=1
for (i in 1:(length(maps1[-8]))) {
    r1 = raster(paste0(rasDir, maps1[i], '.tif'))
    maps2 = maps1[-c(1:i)]
    for (j in 1:length(maps2)) {
        r2 = raster(paste0(rasDir, maps2[j], '.tif'))
        x = crosstab(r1, r2)
        jaccard = round(x[2,2] / (x[1,2] + x[2,1] + x[2,2])*100/k,0)
        z[j+jj,i+1] = jaccard
        cat('\n',maps1[i],'x',maps2[j],'=',jaccard,'\n\n')
        print(z); flush.console()
        n = n + 1
    }
    jj = jj + 1
}

write_csv(z, paste0('output/ca_agreement_',cellsize,'m.csv'))


# Where do maps all agree?
rr = list()
for (i in 1:length(maps1)) {
    cat(paste0(rasDir, maps1[i], '.tif'),"\n")
    r = raster(paste0(rasDir, maps1[i], '.tif'))
    rr[[i]] = r
}
hot8 = rr[[1]] + rr[[2]] + rr[[3]] + rr[[4]] + rr[[5]] + rr[[6]] + rr[[7]] + rr[[8]]
writeRaster(hot8, 'output/hot8.tif', overwrite=T)
#hot1 = rr[[1]] * rr[[2]] * rr[[3]] * rr[[4]] * rr[[5]] * rr[[6]] * rr[[7]]
#hot3 = rr[[1]] * rr[[2]] * rr[[3]]
#hot4 = rr[[4]] * rr[[5]] * rr[[6]] * rr[[7]]
