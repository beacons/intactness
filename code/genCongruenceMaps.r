library(rgdal)
library(raster)
library(rasterVis)

v <- readOGR('../../gisdata/intactness/analysis/vector_ca', 'ca_boreal_boundary')
b1 <- readOGR('../../gisdata/intactness/analysis/vector_ca', 'ca_cifl_boundary')
b2 <- readOGR('../../gisdata/intactness/analysis/vector_ca', 'ca_gifl_boundary')

b <- raster('../../gisdata/intactness/analysis/ca_boreal1000/boreal.tif')
b0 <- b * 0
b <- ratify(b)
bat <- levels(b)[[1]]
bat$boreal <- c('Boreal')
levels(b) <- bat

cifl_bnd = raster("../../gisdata/intactness/analysis/ca_boreal1000/cifl.tif")
gifl_bnd = raster("../../gisdata/intactness/analysis/ca_boreal1000/gifl.tif")
cifl_gifl = raster("../../gisdata/intactness/analysis/ca_boreal1000/cifl_gifl.tif")

# CIFL 2013
r1 = raster("../../gisdata/intactness/analysis/ca_boreal1000/cifl2013.tif")
r1c <- cover(r1, b0)
r1c <- mask(r1c, cifl_bnd)
r1cg <- mask(r1c, cifl_gifl)


################################################################################
# CIFL2013 X ...
################################################################################

# GIFL 2013
r3 = raster("../../gisdata/intactness/analysis/ca_boreal1000/gifl2013.tif")
r3 <- mask(r3, cifl_gifl)
r3c <- cover(r3, b0)
r3c <- r3c * 2
r <- r1cg + r3c
r <- ratify(r)
rat <- levels(r)[[1]]
rat$intact <- c('Agreement (both non-intact)','Disagreement (CIFL intact)','Disagreement (GIFL intact)','Agreement (both intact)')
levels(r) <- rat
png("supp_info/maps/cifl2013_x_gifl2013.png", width = 1200, height = 450)
levelplot(r, col.regions=c('darkgreen','yellow','red','blue'), colorkey=TRUE, margin=F, scales=list(draw=FALSE)) + 
	layer(sp.polygons(v, lwd=1, col="black")) +
	layer(panel.text(3500000, 7300000, "CIFL2013 x GIFL2013", font=18, col="black", cex=1.5))
dev.off()

# HF 2009
r5 = raster("../../gisdata/intactness/analysis/ca_boreal1000/hf2009.tif")
NAvalue(r5) <- 128
r5 <- mask(r5, cifl_bnd)
r5c <- cover(r5, b0)
r5c <- r5c * 2
r <- r1c + r5c
r <- ratify(r)
rat <- levels(r)[[1]]
rat$intact <- c('Agreement (both non-intact)','Disagreement (CIFL intact)','Disagreement (HF intact)','Agreement (both intact)')
levels(r) <- rat
png("supp_info/maps/cifl2013_x_hf2009.png", width = 1200, height = 450)
levelplot(r, col.regions=c('darkgreen','yellow','red','blue'), colorkey=TRUE, margin=F, scales=list(draw=FALSE)) + 
	layer(sp.polygons(v, lwd=1, col="black")) +
	layer(panel.text(3500000, 7300000, "CIFL2013 x HF2009", font=18, col="black", cex=1.5))
dev.off()

# FF 1997
r7 = raster("../../gisdata/intactness/analysis/ca_boreal1000/ff.tif")
r7 <- mask(r7, cifl_bnd)
r7c <- cover(r7, b0)
r7c <- r7c * 2
r <- r1c + r7c
r <- ratify(r)
rat <- levels(r)[[1]]
rat$intact <- c('Agreement (both non-intact)','Disagreement (CIFL intact)','Disagreement (FF intact)','Agreement (both intact)')
levels(r) <- rat
png("supp_info/maps/cifl2013_x_ff.png", width = 1200, height = 450)
levelplot(r, col.regions=c('darkgreen','yellow','red','blue'), colorkey=TRUE, margin=F, scales=list(draw=FALSE)) + 
	layer(sp.polygons(v, lwd=1, col="black")) +
	layer(panel.text(3500000, 7300000, "CIFL2013 x FF", font=18, col="black", cex=1.5))
dev.off()

# Unused
r8 = raster("../../gisdata/intactness/analysis/ca_boreal1000/un100.tif")
r8 <- mask(r8, cifl_bnd)
r8c <- cover(r8, b0)
r8c <- r8c * 2
r <- r1c + r8c
r <- ratify(r)
rat <- levels(r)[[1]]
rat$intact <- c('Agreement (both non-intact)','Disagreement (CIFL intact)','Disagreement (UNUSED intact)','Agreement (both intact)')
levels(r) <- rat
png("supp_info/maps/cifl2013_x_unused.png", width = 1200, height = 450)
levelplot(r, col.regions=c('darkgreen','yellow','red','blue'), colorkey=TRUE, margin=F, scales=list(draw=FALSE)) + 
	layer(sp.polygons(v, lwd=1, col="black")) +
	layer(panel.text(3500000, 7300000, "CIFL2013 x UNUSED", font=18, col="black", cex=1.5))
dev.off()

# Wild
r9 = raster("../../gisdata/intactness/analysis/ca_boreal1000/wild.tif")
NAvalue(r9) <- 128
r9 <- mask(r9, cifl_bnd)
r9c <- cover(r9, b0)
r9c <- r9c * 2
r <- r1c + r9c
r <- ratify(r)
rat <- levels(r)[[1]]
rat$intact <- c('Agreement (both non-intact)','Disagreement (CIFL intact)','Disagreement (WILD intact)','Agreement (both intact)')
levels(r) <- rat
png("supp_info/maps/cifl2013_x_wild.png", width = 1200, height = 450)
levelplot(r, col.regions=c('darkgreen','yellow','red','blue'), colorkey=TRUE, margin=F, scales=list(draw=FALSE)) + 
	layer(sp.polygons(v, lwd=1, col="black")) +
	layer(panel.text(3500000, 7300000, "CIFL2013 x WILD", font=18, col="black", cex=1.5))
dev.off()

# MSA90
r10 = raster("../../gisdata/intactness/analysis/ca_boreal1000/msa90.tif")
r10 <- mask(r10, cifl_bnd)
r10c <- cover(r10, b0)
r10c <- r10c * 2
r <- r1c + r10c
r <- ratify(r)
rat <- levels(r)[[1]]
rat$intact <- c('Agreement (both non-intact)','Disagreement (CIFL intact)','Disagreement (MSA intact)','Agreement (both intact)')
levels(r) <- rat
png("supp_info/maps/cifl2013_x_msa.png", width = 1200, height = 450)
levelplot(r, col.regions=c('darkgreen','yellow','red','blue'), colorkey=TRUE, margin=F, scales=list(draw=FALSE)) + 
	layer(sp.polygons(v, lwd=1, col="black")) +
	layer(panel.text(3500000, 7300000, "CIFL2013 x MSA", font=18, col="black", cex=1.5))
dev.off()


################################################################################
# GIFL2013 X ...
################################################################################

# HF 2009
r5 = raster("../../gisdata/intactness/analysis/ca_boreal1000/hf2009.tif")
NAvalue(r5) <- 128
r5 <- mask(r5, cifl_bnd)
r5c <- cover(r5, b0)
r5c <- r5c * 2
r <- r3c/2 + r5c
r <- ratify(r)
rat <- levels(r)[[1]]
rat$intact <- c('Agreement (both non-intact)','Disagreement (GIFL intact)','Disagreement (HF intact)','Agreement (both intact)')
levels(r) <- rat
png("supp_info/maps/gifl2013_x_hf2009.png", width = 1200, height = 450)
levelplot(r, col.regions=c('darkgreen','yellow','red','blue'), colorkey=TRUE, margin=F, scales=list(draw=FALSE)) + 
	layer(sp.polygons(v, lwd=1, col="black")) +
	layer(panel.text(3500000, 7300000, "GIFL2013 x HF2009", font=18, col="black", cex=1.5))
dev.off()

# FF 1997
r7 = raster("../../gisdata/intactness/analysis/ca_boreal1000/ff.tif")
r7 <- mask(r7, cifl_bnd)
r7c <- cover(r7, b0)
r7c <- r7c * 2
r <- r3c/2 + r7c
r <- ratify(r)
rat <- levels(r)[[1]]
rat$intact <- c('Agreement (both non-intact)','Disagreement (GIFL intact)','Disagreement (FF intact)','Agreement (both intact)')
levels(r) <- rat
png("supp_info/maps/gifl2013_x_ff.png", width = 1200, height = 450)
levelplot(r, col.regions=c('darkgreen','yellow','red','blue'), colorkey=TRUE, margin=F, scales=list(draw=FALSE)) + 
	layer(sp.polygons(v, lwd=1, col="black")) +
	layer(panel.text(3500000, 7300000, "GIFL2013 x FF", font=18, col="black", cex=1.5))
dev.off()

# Unused
r8 = raster("../../gisdata/intactness/analysis/ca_boreal1000/un100.tif")
r8 <- mask(r8, cifl_bnd)
r8c <- cover(r8, b0)
r8c <- r8c * 2
r <- r3c/2 + r8c
r <- ratify(r)
rat <- levels(r)[[1]]
rat$intact <- c('Agreement (both non-intact)','Disagreement (GIFL intact)','Disagreement (UNUSED intact)','Agreement (both intact)')
levels(r) <- rat
png("supp_info/maps/gifl2013_x_unused.png", width = 1200, height = 450)
levelplot(r, col.regions=c('darkgreen','yellow','red','blue'), colorkey=TRUE, margin=F, scales=list(draw=FALSE)) + 
	layer(sp.polygons(v, lwd=1, col="black")) +
	layer(panel.text(3500000, 7300000, "GIFL2013 x UNUSED", font=18, col="black", cex=1.5))
dev.off()

# Wild
r9 = raster("../../gisdata/intactness/analysis/ca_boreal1000/wild.tif")
NAvalue(r9) <- 128
r9 <- mask(r9, cifl_bnd)
r9c <- cover(r9, b0)
r9c <- r9c * 2
r <- r3c/2 + r9c
r <- ratify(r)
rat <- levels(r)[[1]]
rat$intact <- c('Agreement (both non-intact)','Disagreement (GIFL intact)','Disagreement (WILD intact)','Agreement (both intact)')
levels(r) <- rat
png("supp_info/maps/gifl2013_x_wild.png", width = 1200, height = 450)
levelplot(r, col.regions=c('darkgreen','yellow','red','blue'), colorkey=TRUE, margin=F, scales=list(draw=FALSE)) + 
	layer(sp.polygons(v, lwd=1, col="black")) +
	layer(panel.text(3500000, 7300000, "GIFL2013 x WILD", font=18, col="black", cex=1.5))
dev.off()

# MSA90
r10 = raster("../../gisdata/intactness/analysis/ca_boreal1000/msa90.tif")
r10 <- mask(r10, cifl_bnd)
r10c <- cover(r10, b0)
r10c <- r10c * 2
r <- r3c/2 + r10c
r <- ratify(r)
rat <- levels(r)[[1]]
rat$intact <- c('Agreement (both non-intact)','Disagreement (GIFL intact)','Disagreement (MSA intact)','Agreement (both intact)')
levels(r) <- rat
png("supp_info/maps/gifl2013_x_msa.png", width = 1200, height = 450)
levelplot(r, col.regions=c('darkgreen','yellow','red','blue'), colorkey=TRUE, margin=F, scales=list(draw=FALSE)) + 
	layer(sp.polygons(v, lwd=1, col="black")) +
	layer(panel.text(3500000, 7300000, "GIFL2013 x MSA", font=18, col="black", cex=1.5))
dev.off()


################################################################################
# HF2009 X ...
################################################################################

# FF 1997
r7 = raster("../../gisdata/intactness/analysis/ca_boreal1000/ff.tif")
r7 <- mask(r7, cifl_bnd)
r7c <- cover(r7, b0)
r7c <- r7c * 2
r <- r5c/2 + r7c
r <- ratify(r)
rat <- levels(r)[[1]]
rat$intact <- c('Agreement (both non-intact)','Disagreement (HF intact)','Disagreement (FF intact)','Agreement (both intact)')
levels(r) <- rat
png("supp_info/maps/hf2009_x_ff.png", width = 1200, height = 450)
levelplot(r, col.regions=c('darkgreen','yellow','red','blue'), colorkey=TRUE, margin=F, scales=list(draw=FALSE)) + 
	layer(sp.polygons(v, lwd=1, col="black")) +
	layer(panel.text(3500000, 7300000, "HF2009 x FF", font=18, col="black", cex=1.5))
dev.off()

# Unused
r8 = raster("../../gisdata/intactness/analysis/ca_boreal1000/un100.tif")
r8 <- mask(r8, cifl_bnd)
r8c <- cover(r8, b0)
r8c <- r8c * 2
r <- r5c/2 + r8c
r <- ratify(r)
rat <- levels(r)[[1]]
rat$intact <- c('Agreement (both non-intact)','Disagreement (HF intact)','Disagreement (UNUSED intact)','Agreement (both intact)')
levels(r) <- rat
png("supp_info/maps/hf2009_x_unused.png", width = 1200, height = 450)
levelplot(r, col.regions=c('darkgreen','yellow','red','blue'), colorkey=TRUE, margin=F, scales=list(draw=FALSE)) + 
	layer(sp.polygons(v, lwd=1, col="black")) +
	layer(panel.text(3500000, 7300000, "HF2009 x UNUSED", font=18, col="black", cex=1.5))
dev.off()

# Wild
r9 = raster("../../gisdata/intactness/analysis/ca_boreal1000/wild.tif")
NAvalue(r9) <- 128
r9 <- mask(r9, cifl_bnd)
r9c <- cover(r9, b0)
r9c <- r9c * 2
r <- r5c/2 + r9c
r <- ratify(r)
rat <- levels(r)[[1]]
rat$intact <- c('Agreement (both non-intact)','Disagreement (HF intact)','Disagreement (WILD intact)','Agreement (both intact)')
levels(r) <- rat
png("supp_info/maps/hf2009_x_wild.png", width = 1200, height = 450)
levelplot(r, col.regions=c('darkgreen','yellow','red','blue'), colorkey=TRUE, margin=F, scales=list(draw=FALSE)) + 
	layer(sp.polygons(v, lwd=1, col="black")) +
	layer(panel.text(3500000, 7300000, "HF2009 x WILD", font=18, col="black", cex=1.5))
dev.off()

# MSA90
r10 = raster("../../gisdata/intactness/analysis/ca_boreal1000/msa90.tif")
r10 <- mask(r10, cifl_bnd)
r10c <- cover(r10, b0)
r10c <- r10c * 2
r <- r5c/2 + r10c
r <- ratify(r)
rat <- levels(r)[[1]]
rat$intact <- c('Agreement (both non-intact)','Disagreement (HF intact)','Disagreement (MSA intact)','Agreement (both intact)')
levels(r) <- rat
png("supp_info/maps/hf2009_x_msa.png", width = 1200, height = 450)
levelplot(r, col.regions=c('darkgreen','yellow','red','blue'), colorkey=TRUE, margin=F, scales=list(draw=FALSE)) + 
	layer(sp.polygons(v, lwd=1, col="black")) +
	layer(panel.text(3500000, 7300000, "HF2009 x MSA", font=18, col="black", cex=1.5))
dev.off()


################################################################################
# FF X ...
################################################################################

# Unused
r8 = raster("../../gisdata/intactness/analysis/ca_boreal1000/un100.tif")
r8 <- mask(r8, cifl_bnd)
r8c <- cover(r8, b0)
r8c <- r8c * 2
r <- r7c/2 + r8c
r <- ratify(r)
rat <- levels(r)[[1]]
rat$intact <- c('Agreement (both non-intact)','Disagreement (FF intact)','Disagreement (UNUSED intact)','Agreement (both intact)')
levels(r) <- rat
png("supp_info/maps/ff_x_unused.png", width = 1200, height = 450)
levelplot(r, col.regions=c('darkgreen','yellow','red','blue'), colorkey=TRUE, margin=F, scales=list(draw=FALSE)) + 
	layer(sp.polygons(v, lwd=1, col="black")) +
	layer(panel.text(3500000, 7300000, "FF x UNUSED", font=18, col="black", cex=1.5))
dev.off()

# Wild
r9 = raster("../../gisdata/intactness/analysis/ca_boreal1000/wild.tif")
NAvalue(r9) <- 128
r9 <- mask(r9, cifl_bnd)
r9c <- cover(r9, b0)
r9c <- r9c * 2
r <- r7c/2 + r9c
r <- ratify(r)
rat <- levels(r)[[1]]
rat$intact <- c('Agreement (both non-intact)','Disagreement (FF intact)','Disagreement (WILD intact)','Agreement (both intact)')
levels(r) <- rat
png("supp_info/maps/ff_x_wild.png", width = 1200, height = 450)
levelplot(r, col.regions=c('darkgreen','yellow','red','blue'), colorkey=TRUE, margin=F, scales=list(draw=FALSE)) + 
	layer(sp.polygons(v, lwd=1, col="black")) +
	layer(panel.text(3500000, 7300000, "FF x WILD", font=18, col="black", cex=1.5))
dev.off()

# MSA90
r10 = raster("../../gisdata/intactness/analysis/ca_boreal1000/msa90.tif")
r10 <- mask(r10, cifl_bnd)
r10c <- cover(r10, b0)
r10c <- r10c * 2
r <- r7c/2 + r10c
r <- ratify(r)
rat <- levels(r)[[1]]
rat$intact <- c('Agreement (both non-intact)','Disagreement (FF intact)','Disagreement (MSA intact)','Agreement (both intact)')
levels(r) <- rat
png("supp_info/maps/ff_x_msa.png", width = 1200, height = 450)
levelplot(r, col.regions=c('darkgreen','yellow','red','blue'), colorkey=TRUE, margin=F, scales=list(draw=FALSE)) + 
	layer(sp.polygons(v, lwd=1, col="black")) +
	layer(panel.text(3500000, 7300000, "FF x MSA", font=18, col="black", cex=1.5))
dev.off()


################################################################################
# UNUSED X ...
################################################################################

# Wild
r9 = raster("../../gisdata/intactness/analysis/ca_boreal1000/wild.tif")
NAvalue(r9) <- 128
r9 <- mask(r9, cifl_bnd)
r9c <- cover(r9, b0)
r9c <- r9c * 2
r <- r8c/2 + r9c
r <- ratify(r)
rat <- levels(r)[[1]]
rat$intact <- c('Agreement (both non-intact)','Disagreement (UNUSED intact)','Disagreement (WILD intact)','Agreement (both intact)')
levels(r) <- rat
png("supp_info/maps/unused_x_wild.png", width = 1200, height = 450)
levelplot(r, col.regions=c('darkgreen','yellow','red','blue'), colorkey=TRUE, margin=F, scales=list(draw=FALSE)) + 
	layer(sp.polygons(v, lwd=1, col="black")) +
	layer(panel.text(3500000, 7300000, "UNUSED x WILD", font=18, col="black", cex=1.5))
dev.off()

# MSA90
r10 = raster("../../gisdata/intactness/analysis/ca_boreal1000/msa90.tif")
r10 <- mask(r10, cifl_bnd)
r10c <- cover(r10, b0)
r10c <- r10c * 2
r <- r8c/2 + r10c
r <- ratify(r)
rat <- levels(r)[[1]]
rat$intact <- c('Agreement (both non-intact)','Disagreement (UNUSED intact)','Disagreement (MSA intact)','Agreement (both intact)')
levels(r) <- rat
png("supp_info/maps/unused_x_msa.png", width = 1200, height = 450)
levelplot(r, col.regions=c('darkgreen','yellow','red','blue'), colorkey=TRUE, margin=F, scales=list(draw=FALSE)) + 
	layer(sp.polygons(v, lwd=1, col="black")) +
	layer(panel.text(3500000, 7300000, "UNUSED x MSA", font=18, col="black", cex=1.5))
dev.off()


################################################################################
# WILD X ...
################################################################################

# MSA90
r10 = raster("../../gisdata/intactness/analysis/ca_boreal1000/msa90.tif")
r10 <- mask(r10, cifl_bnd)
r10c <- cover(r10, b0)
r10c <- r10c * 2
r <- r9c/2 + r10c
r <- ratify(r)
rat <- levels(r)[[1]]
rat$intact <- c('Agreement (both non-intact)','Disagreement (WILD intact)','Disagreement (MSA intact)','Agreement (both intact)')
levels(r) <- rat
png("supp_info/maps/wild_x_msa.png", width = 1200, height = 450)
levelplot(r, col.regions=c('darkgreen','yellow','red','blue'), colorkey=TRUE, margin=F, scales=list(draw=FALSE)) + 
	layer(sp.polygons(v, lwd=1, col="black")) +
	layer(panel.text(3500000, 7300000, "WILD x MSA", font=18, col="black", cex=1.5))
dev.off()
