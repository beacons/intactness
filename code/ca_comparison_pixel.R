# Pixel level Comparison
# PV 2017-09-06
# caret::confusionMatrix
# x$byClass["Specificity"] = fraction of intact pixels in map1 also mapped as intact in map2
# x$byClass["Neg Pred Value"] = fraction of intact pixels in map2 also mapped as intact in map1
# Other packages: rfUtilities::accuracy, raster::crosstab, diffeR::crosstabm

library(raster)
library(tidyverse)
library(caret)

validate <- function(map1, map2, na1, na2, mask) {
	x1 <- raster(mask)
	x0 <- x1 * 0 # assign boreal grid a value of 0
	
	ra <- raster(map1)
	if (!na1=="") {
		NAvalue(ra) <- na1
	}
	ra <- ra * x1
	ra <- cover(ra, x0) # convert NA values to 0
	a <- getValues(ra)
	
	rb <- raster(map2)
	if (!na2=="") {
		NAvalue(rb) <- na2
	}
	rb <- rb * x1
	rb <- cover(rb, x0) # convert NA values to 0
	b <- getValues(rb)
	confusionMatrix(a,b)
}

mask = "../../gisdata/intactness/analysis/ca_boreal1000/cifl_gifl.tif"
x1 <- validate(map1="../../gisdata/intactness/analysis/ca_boreal1000/cifl2013.tif", map2="../../gisdata/intactness/analysis/ca_boreal1000/gifl2013.tif", na1="", na2="", mask)
x2 <- validate(map1="../../gisdata/intactness/analysis/ca_boreal1000/cifl2013.tif", map2="../../gisdata/intactness/analysis/ca_boreal1000/hf2009.tif", na1="", na2=128, mask)
x3 <- validate(map1="../../gisdata/intactness/analysis/ca_boreal1000/cifl2013.tif", map2="../../gisdata/intactness/analysis/ca_boreal1000/ff.tif", na1="", na2="", mask)
x4 <- validate(map1="../../gisdata/intactness/analysis/ca_boreal1000/cifl2013.tif", map2="../../gisdata/intactness/analysis/ca_boreal1000/un100.tif", na1="", na2="", mask)
x5 <- validate(map1="../../gisdata/intactness/analysis/ca_boreal1000/cifl2013.tif", map2="../../gisdata/intactness/analysis/ca_boreal1000/wild.tif", na1="", na2=128, mask)
x6 <- validate(map1="../../gisdata/intactness/analysis/ca_boreal1000/cifl2013.tif", map2="../../gisdata/intactness/analysis/ca_boreal1000/msa90.tif", na1="", na2="", mask)
x7 <- validate(map1="../../gisdata/intactness/analysis/ca_boreal1000/gifl2013.tif", map2="../../gisdata/intactness/analysis/ca_boreal1000/hf2009.tif", na1="", na2=128, mask)
x8 <- validate(map1="../../gisdata/intactness/analysis/ca_boreal1000/gifl2013.tif", map2="../../gisdata/intactness/analysis/ca_boreal1000/ff.tif", na1="", na2="", mask)
x9 <- validate(map1="../../gisdata/intactness/analysis/ca_boreal1000/gifl2013.tif", map2="../../gisdata/intactness/analysis/ca_boreal1000/un100.tif", na1="", na2="", mask)
x10 <- validate(map1="../../gisdata/intactness/analysis/ca_boreal1000/gifl2013.tif", map2="../../gisdata/intactness/analysis/ca_boreal1000/wild.tif", na1="", na2=128, mask)
x11 <- validate(map1="../../gisdata/intactness/analysis/ca_boreal1000/gifl2013.tif", map2="../../gisdata/intactness/analysis/ca_boreal1000/msa90.tif", na1="", na2="", mask)
x12 <- validate(map1="../../gisdata/intactness/analysis/ca_boreal1000/hf2009.tif", map2="../../gisdata/intactness/analysis/ca_boreal1000/ff.tif", na1=128, na2="", mask)
x13 <- validate(map1="../../gisdata/intactness/analysis/ca_boreal1000/hf2009.tif", map2="../../gisdata/intactness/analysis/ca_boreal1000/un100.tif", na1=128, na2="", mask)
x14 <- validate(map1="../../gisdata/intactness/analysis/ca_boreal1000/hf2009.tif", map2="../../gisdata/intactness/analysis/ca_boreal1000/wild.tif", na1=128, na2=128, mask)
x15 <- validate(map1="../../gisdata/intactness/analysis/ca_boreal1000/hf2009.tif", map2="../../gisdata/intactness/analysis/ca_boreal1000/msa90.tif", na1=128, na2="", mask)
x16 <- validate(map1="../../gisdata/intactness/analysis/ca_boreal1000/ff.tif", map2="../../gisdata/intactness/analysis/ca_boreal1000/un100.tif", na1="", na2="", mask)
x17 <- validate(map1="../../gisdata/intactness/analysis/ca_boreal1000/ff.tif", map2="../../gisdata/intactness/analysis/ca_boreal1000/wild.tif", na1="", na2=128, mask)
x18 <- validate(map1="../../gisdata/intactness/analysis/ca_boreal1000/ff.tif", map2="../../gisdata/intactness/analysis/ca_boreal1000/msa90.tif", na1="", na2="", mask)
x19 <- validate(map1="../../gisdata/intactness/analysis/ca_boreal1000/un100.tif", map2="../../gisdata/intactness/analysis/ca_boreal1000/wild.tif", na1="", na2=128, mask)
x20 <- validate(map1="../../gisdata/intactness/analysis/ca_boreal1000/un100.tif", map2="../../gisdata/intactness/analysis/ca_boreal1000/msa90.tif", na1="", na2="", mask)
x21 <- validate(map1="../../gisdata/intactness/analysis/ca_boreal1000/wild.tif", map2="../../gisdata/intactness/analysis/ca_boreal1000/msa90.tif", na1=128, na2="", mask)

# x$byClass["Specificity"] = fraction of intact pixels in map1 also mapped as intact in map2
# x$byClass["Neg Pred Value"] = fraction of intact pixels in map2 also mapped as intact in map1
f <- tibble(map=c("CIFL2013","GIFL2013","HF2009","FF","UNUSED","WILD","MSA"),CIFL2013=c(1,0,0,0,0,0,0),GIFL2013=c(0,1,0,0,0,0,0),HF2009=c(0,0,1,0,0,0,0),FF=c(0,0,0,1,0,0,0),UNUSED=c(0,0,0,0,1,0,0),WILD=c(0,0,0,0,0,1,0),MSA=c(0,0,0,0,0,0,1))
f[2,2] = paste0(round(x1$byClass["Specificity"],2)," (",x1$table[1,2],")")
f[3,2] = paste0(round(x2$byClass["Specificity"],2)," (",x2$table[1,2],")")
f[4,2] = paste0(round(x3$byClass["Specificity"],2)," (",x3$table[1,2],")")
f[5,2] = paste0(round(x4$byClass["Specificity"],2)," (",x4$table[1,2],")")
f[6,2] = paste0(round(x5$byClass["Specificity"],2)," (",x5$table[1,2],")")
f[7,2] = paste0(round(x6$byClass["Specificity"],2)," (",x6$table[1,2],")")
f[3,3] = paste0(round(x7$byClass["Specificity"],2)," (",x7$table[1,2],")")
f[4,3] = paste0(round(x8$byClass["Specificity"],2)," (",x8$table[1,2],")")
f[5,3] = paste0(round(x9$byClass["Specificity"],2)," (",x9$table[1,2],")")
f[6,3] = paste0(round(x10$byClass["Specificity"],2)," (",x10$table[1,2],")")
f[7,3] = paste0(round(x11$byClass["Specificity"],2)," (",x11$table[1,2],")")
f[4,4] = paste0(round(x12$byClass["Specificity"],2)," (",x12$table[1,2],")")
f[5,4] = paste0(round(x13$byClass["Specificity"],2)," (",x13$table[1,2],")")
f[6,4] = paste0(round(x14$byClass["Specificity"],2)," (",x14$table[1,2],")")
f[7,4] = paste0(round(x15$byClass["Specificity"],2)," (",x15$table[1,2],")")
f[5,5] = paste0(round(x16$byClass["Specificity"],2)," (",x16$table[1,2],")")
f[6,5] = paste0(round(x17$byClass["Specificity"],2)," (",x17$table[1,2],")")
f[7,5] = paste0(round(x18$byClass["Specificity"],2)," (",x18$table[1,2],")")
f[6,6] = paste0(round(x19$byClass["Specificity"],2)," (",x19$table[1,2],")")
f[7,6] = paste0(round(x20$byClass["Specificity"],2)," (",x20$table[1,2],")")
f[7,7] = paste0(round(x21$byClass["Specificity"],2)," (",x21$table[1,2],")")

f[1,3] = paste0(round(x1$byClass["Neg Pred Value"],2)," (",x1$table[2,1],")")
f[1,4] = paste0(round(x2$byClass["Neg Pred Value"],2)," (",x2$table[2,1],")")
f[1,5] = paste0(round(x3$byClass["Neg Pred Value"],2)," (",x3$table[2,1],")")
f[1,6] = paste0(round(x4$byClass["Neg Pred Value"],2)," (",x4$table[2,1],")")
f[1,7] = paste0(round(x5$byClass["Neg Pred Value"],2)," (",x5$table[2,1],")")
f[1,8] = paste0(round(x6$byClass["Neg Pred Value"],2)," (",x6$table[2,1],")")
f[2,4] = paste0(round(x7$byClass["Neg Pred Value"],2)," (",x7$table[2,1],")")
f[2,5] = paste0(round(x8$byClass["Neg Pred Value"],2)," (",x8$table[2,1],")")
f[2,6] = paste0(round(x9$byClass["Neg Pred Value"],2)," (",x9$table[2,1],")")
f[2,7] = paste0(round(x10$byClass["Neg Pred Value"],2)," (",x10$table[2,1],")")
f[2,8] = paste0(round(x11$byClass["Neg Pred Value"],2)," (",x11$table[2,1],")")
f[3,5] = paste0(round(x12$byClass["Neg Pred Value"],2)," (",x12$table[2,1],")")
f[3,6] = paste0(round(x13$byClass["Neg Pred Value"],2)," (",x13$table[2,1],")")
f[3,7] = paste0(round(x14$byClass["Neg Pred Value"],2)," (",x14$table[2,1],")")
f[3,8] = paste0(round(x15$byClass["Neg Pred Value"],2)," (",x15$table[2,1],")")
f[4,6] = paste0(round(x16$byClass["Neg Pred Value"],2)," (",x16$table[2,1],")")
f[4,7] = paste0(round(x17$byClass["Neg Pred Value"],2)," (",x17$table[2,1],")")
f[4,8] = paste0(round(x18$byClass["Neg Pred Value"],2)," (",x18$table[2,1],")")
f[5,7] = paste0(round(x19$byClass["Neg Pred Value"],2)," (",x19$table[2,1],")")
f[5,8] = paste0(round(x20$byClass["Neg Pred Value"],2)," (",x20$table[2,1],")")
f[6,8] = paste0(round(x21$byClass["Neg Pred Value"],2)," (",x21$table[2,1],")")

write_csv(f, "docs/tables/ca_pixel_confusion_matrix_proportion.csv")


accuracy <- function() {
	# x$byClass["Specificity"] = fraction of intact pixels in map1 also mapped as intact in map2
	# x$byClass["Neg Pred Value"] = fraction of intact pixels in map2 also mapped as intact in map1
	f <- tibble(map=c("CIFL2013","GIFL2013","HF2009","FF","UNUSED","WILD","MSA"),CIFL2013=c(1,0,0,0,0,0,0),GIFL2013=c(0,1,0,0,0,0,0),HF2009=c(0,0,1,0,0,0,0),FF=c(0,0,0,1,0,0,0),UNUSED=c(0,0,0,0,1,0,0),WILD=c(0,0,0,0,0,1,0),MSA=c(0,0,0,0,0,0,1))
	f[2,2] = round(x1$overall["Accuracy"],2)
	f[3,2] = round(x2$overall["Accuracy"],2)
	f[4,2] = round(x3$overall["Accuracy"],2)
	f[5,2] = round(x4$overall["Accuracy"],2)
	f[6,2] = round(x5$overall["Accuracy"],2)
	f[7,2] = round(x6$overall["Accuracy"],2)
	f[3,3] = round(x7$overall["Accuracy"],2)
	f[4,3] = round(x8$overall["Accuracy"],2)
	f[5,3] = round(x9$overall["Accuracy"],2)
	f[6,3] = round(x10$overall["Accuracy"],2)
	f[7,3] = round(x11$overall["Accuracy"],2)
	f[4,4] = round(x12$overall["Accuracy"],2)
	f[5,4] = round(x13$overall["Accuracy"],2)
	f[6,4] = round(x14$overall["Accuracy"],2)
	f[7,4] = round(x15$overall["Accuracy"],2)
	f[5,5] = round(x16$overall["Accuracy"],2)
	f[6,5] = round(x17$overall["Accuracy"],2)
	f[7,5] = round(x18$overall["Accuracy"],2)
	f[6,6] = round(x19$overall["Accuracy"],2)
	f[7,6] = round(x20$overall["Accuracy"],2)
	f[7,7] = round(x21$overall["Accuracy"],2)

	write_csv(f, "docs/tables/ca_pixel_confusion_matrix_kappa.csv")
}