# Sum output of intersections for 39 herds that are completely within GIFL and CIFL boundaries
# PV 2021-11-09

# NOTE: This script won't work unless you download the BEAD dataset (see s1_datasets.md for links)

library(sf)
library(tidyverse)
source("code/convert_tibbles.R")

imaps = c('ha2010','cifl2013','gifl2016','hfp2013','hfp2019','ghm2016','ab2015','vlia2015')
iDir = "data/bead/"
ranges = sort(st_read('data/bead/_ranges.gpkg')$Herd_OS) #list.files(iDir, pattern='.gpkg$')

# dissolve to calc %intact for CHFP2019 (2021-11-09)
cr = st_read('data/bead/_ranges.gpkg') %>%
    mutate(one=1) %>%
    group_by(one) %>% 
    summarize() 
r = st_read('data/boreal/hfp2019.shp')
rcr = rmapshaper::ms_clip(r, cr)
pct = round(st_area(rcr)/st_area(cr)*100,2) # %intact = 100 - pct

dtypes = c('poly30','line30','poly15','line15')

for (d in dtypes) {
    for (cr in ranges) {
        if (cr=="AtikakiBernes") {cr="Atikaki_Bernes"}
        if (cr=="OwlFlinstone") {cr="Owl_Flinstone"}
        if (cr=="SnakeSahtahneh") {cr="Snake_Sahtahneh"}
        cat(cr,'\n'); flush.console()
        v1 = as_tibble(st_read(paste0(iDir,cr,'.gpkg'), layer=d))
        if (d %in% c('line30','line15')) {
            v1 = select(v1, Class, Length)
        } else {
            v1 = select(v1, Class, Area)
        }
        if (cr=='Atikaki_Bernes') {
            v = v1
        } else {
            v = bind_rows(v, v1)
        }        
        if (d %in% c('line30','line15')) {
            vv = group_by(v, Class) %>% summarize(Length=sum(Length))
        } else {
            vv = group_by(v, Class) %>% summarize(Area=sum(Area))
        }

        for (i in imaps) {
            lyrs = st_layers(paste0(iDir,cr,'.gpkg'))$name
            if (paste0(i,'_',d) %in% lyrs) { # check if layer exists
                cat(cr,'-',i,'\n'); flush.console()
                x1 = as_tibble(st_read(paste0(iDir,cr,'.gpkg'), layer=paste0(i,'_',d)))
                if ("Class" %in% names(x1)) { # check if there is any data i.e., table is not empty
                    if (d %in% c('line30','line15')) { 
                        x1 = select(x1, Class, Length) %>% mutate(Map=i,Herd=cr)
                    } else {
                        x1 = select(x1, Class, Area) %>% mutate(Map=i,Herd=cr)
                    }
                    if (cr=='Atikaki_Bernes' & i=='ha2010') {
                        x = x1
                    } else {
                        x = bind_rows(x, x1)
                    }
                }
            }
        }
        if (d %in% c('line30','line15')) {
            xx = group_by(x, Class) %>% summarize(Length=sum(Length))
        } else {
            xx = group_by(x, Class) %>% summarize(Area=sum(Area))
        }
    }
    #write_csv(x, '7_ranges/output/ranges39_errors_long.csv')

    if (d %in% c('line30','line15')) { 
        y = select(x, Herd, Map, Class, Length) %>%
            group_by(Map, Class) %>%
            summarize(Length=sum(Length)) %>%
            ungroup()

        n = length(ranges)
        x0 = tibble(Herd=rep(ranges,7), Map=c(rep('ha2010',n),rep('cifl2013',n),rep('gifl2016',n),rep('hfp2013',n),rep('ghm2016',n),rep('ab2015',n),rep('vlia2015',n)),zero=0)
        z1 = left_join(x0,y) %>% mutate(zero=NULL) %>%
            spread(Class, Length)
        #write_csv(z1, '7_ranges/output/ranges39_errors.csv')

        z2 = spread(y, Class, Length) %>%
            transpose_tibble(Map) %>%
            rename(Class=columns)
        z2 = left_join(vv, z2)

        pct <- function(x) (round(x / z2$Length * 100,1))
        z3 = mutate_at(z2, imaps, pct)  %>% mutate(Length = round(Length/1000,0)) %>%
            relocate(Class,Length,ha2010,cifl2013,gifl2016,hfp2013,ghm2016,ab2015,vlia2015)

        write_csv(z3, paste0('output/ranges51_',d,'.csv'))
    } else {
        y = select(x, Herd, Map, Class, Area) %>%
            group_by(Map, Class) %>%
            summarize(Area=sum(Area)) %>%
            ungroup()

        n = length(ranges)
        x0 = tibble(Herd=rep(ranges,7), Map=c(rep('ha2010',n),rep('cifl2013',n),rep('gifl2016',n),rep('hfp2013',n),rep('ghm2016',n),rep('ab2015',n),rep('vlia2015',n)),zero=0)
        z1 = left_join(x0,y) %>% mutate(zero=NULL) %>%
            spread(Class, Area)
        #write_csv(z1, '7_ranges/output/ranges39_errors.csv')

        z2 = spread(y, Class, Area) %>%
            transpose_tibble(Map) %>%
            rename(Class=columns)
        z2 = left_join(vv, z2)

        pct <- function(x) (round(x / z2$Area * 100,1))
        z3 = mutate_at(z2, imaps, pct) %>% mutate(Area = round(Area/1000000,0)) %>%
            relocate(Class,Area,ha2010,cifl2013,gifl2016,hfp2013,ab2015,vlia2015,ghm2016)

        write_csv(z3, paste0('output/ranges51_',d,'.csv'))
    }
}
