# ------------------------------------------------------------------------------
# ras2vec.py
# Description: Generate NA wide vector intactness maps
# Author: Pierre Vernier
# Updated: Sept 26, 2017
# ------------------------------------------------------------------------------

import os, sys, arcpy
from arcpy import env
from arcpy.sa import *

# Script arguments
dropDir = 'E:/Pierre/Dropbox (BEACONs)/gisdata/intactness/'

# Original datasets
borealShp = '../data/vector/na_boreal_boundary.shp'
cifl2000Shp = dropDir + 'GFWC/Canada_IFL_circa2000_Revised.shp'
cifl2013Shp = dropDir + 'GFWC/GFWC_Canada_IFL_2013_Final.shp'
gifl2000Shp = dropDir + 'GFW/ifl_2000.shp'
gifl2013Shp = dropDir + 'GFW/ifl_2013.shp'
ffShp = dropDir + 'FrontierForests/frontier.shp'
hf1993Tif = '../data/na_boreal1000/hf1993.tif'
hf2009Tif = '../data/na_boreal1000/hf2009.tif'
un100Tif = '../data/na_boreal1000/un100.tif'
wildTif = '../data/na_boreal1000/wild.tif'
msa90Tif = '../data/na_boreal1000/msa90.tif'
lcm1Tif = '../data/na_boreal1000/lcm1.tif'

# Set workspace & parameters
brandtPrj = "prj/brandt_albers.prj"
env.workspace = env.scratchFolder
env.overwriteOutput = True
arcpy.CheckOutExtension("Spatial")
arcpy.env.outputCoordinateSystem = brandtPrj
'''
# CIFL
arcpy.Clip_analysis(cifl2000Shp, borealShp, "../data/vector/na_cifl2000.shp")
arcpy.Clip_analysis(cifl2013Shp, borealShp, "../data/vector/na_cifl2013.shp")

# GIFL
arcpy.Clip_analysis(gifl2000Shp, borealShp, "../data/vector/na_gifl2000.shp")
arcpy.Clip_analysis(gifl2013Shp, borealShp, "../data/vector/na_gifl2013.shp")

# FF
arcpy.Clip_analysis(ffShp, borealShp, "../data/vector/na_ff.shp")

# HF
arcpy.RasterToPolygon_conversion (hf1993Tif, "../data/vector/na_hf1993.shp", "NO_SIMPLIFY", "VALUE")
arcpy.RasterToPolygon_conversion (hf2009Tif, "../data/vector/na_hf2009.shp", "NO_SIMPLIFY")

# UN100
arcpy.RasterToPolygon_conversion (un100Tif, "../data/vector/na_un100.shp", "NO_SIMPLIFY", "VALUE")

# WILD
arcpy.RasterToPolygon_conversion (wildTif, "../data/vector/na_wild.shp", "NO_SIMPLIFY", "VALUE")

# MSA90
arcpy.RasterToPolygon_conversion (msa90Tif, "../data/vector/na_msa90.shp", "NO_SIMPLIFY", "VALUE")

# LCM1
arcpy.RasterToPolygon_conversion (lcm1Tif, "../data/vector/na_lcm1.shp", "NO_SIMPLIFY", "VALUE")
'''

arcpy.RasterToPolygon_conversion ("../data/yt_central_harvest/region_harvest_high_year.tif", "../data/yt_central_harvest/region_harvest_high_year_vec.shp", "NO_SIMPLIFY", "VALUE")
