# ------------------------------------------------------------------------------
# Prepare BC case study data
# Pierre Vernier
# January 4, 2018
# ------------------------------------------------------------------------------

import os, sys, arcpy
from arcpy import env
from arcpy.sa import *

def gen_bc_data():
    # Prepare 1985-2010 harvest data for a given region within Canada

    region = 'bc_harvest'
    maps = ['ha2010'] #,'cifl2013', 'gifl2013', 'hf2009', 'ff', 'un100', 'wild', 'msa90']
    dropDir = 'E:/Pierre/Dropbox (BEACONs)/gisdata/'
    rasDir = dropDir + 'intactness/analysis/' + region + '/raster/'
    vecDir = dropDir + 'intactness/analysis/' + region + '/vector/'

    if not os.path.exists(rasDir):
        os.makedirs(rasDir)
    if not os.path.exists(vecDir):
        os.makedirs(vecDir)

    # Datasets
    bnd = vecDir + 'bnd.shp'
    prj = vecDir + 'bnd.prj'
    harvest = 'E:/Pierre/Dropbox (BEACONs)/gisdata/intactness/ForestChange/beacons/harvest_year.tif'
    harvest_lc = 'E:/Pierre/Dropbox (BEACONs)/gisdata/intactness/ForestChange/beacons/harvest_lc_year.tif'

    # Set workspace & parameters
    env.workspace = env.scratchFolder
    env.overwriteOutput = True
    arcpy.CheckOutExtension('Spatial')
    arcpy.env.outputCoordinateSystem = prj

    print('Rasterize boundary...')
    if not 'one' in [f.name for f in arcpy.ListFields(bnd)]:
        arcpy.AddField_management(bnd, 'one', 'SHORT', '4')
    arcpy.CalculateField_management(bnd, 'one', '1', 'Python')
    arcpy.FeatureToRaster_conversion(bnd, 'one', rasDir + 'bnd.tif', 30)

    arcpy.env.extent = rasDir + 'bnd.tif'
    arcpy.env.snapRaster = rasDir + 'bnd.tif'
    arcpy.env.cellSize = rasDir + 'bnd.tif'

    print('Extract change type and year to boundary...')
    x = ExtractByMask(harvest, bnd)
    x.save(rasDir + 'harvest.tif')
    x = ExtractByMask(harvest_lc, bnd)
    x.save(rasDir + 'harvest_lc.tif')

    arcpy.RasterToPolygon_conversion (rasDir + 'harvest.tif', vecDir + 'harvest.shp', "NO_SIMPLIFY", "VALUE")
    arcpy.RasterToPolygon_conversion (rasDir + 'harvest_lc.tif', vecDir + 'harvest_lc.shp', "NO_SIMPLIFY", "VALUE")

    print('Extract and manipulate data...')
    for i in maps:
        print('...' + i)
        
        arcpy.Clip_analysis('E:/Pierre/Dropbox (BEACONs)/gisdata/intactness/analysis/vector_na/na_' + i + '.shp', bnd, vecDir + i + '.shp')
        #arcpy.Clip_analysis('../data/vector/na_' + i + '.shp', bnd, vecDir + i + '.shp')
        if not 'one' in [f.name for f in arcpy.ListFields(vecDir + i + '.shp')]:
            arcpy.AddField_management(vecDir + i + '.shp', 'one', 'SHORT', '4')
        arcpy.CalculateField_management(vecDir + i + '.shp', 'one', '1', 'Python')
        arcpy.FeatureToRaster_conversion(vecDir + i + '.shp', 'one', rasDir + i + '.tif', 30)

        # Extract harvest to intact areas
        x = ExtractByMask(harvest, vecDir + i + '.shp')
        x.save(rasDir + i + '_harvest.tif')
        x = ExtractByMask(harvest_lc, vecDir + i + '.shp')
        x.save(rasDir + i + '_harvest_lc.tif')
        
        # Vectorize intactness-harvest rasters
        arcpy.RasterToPolygon_conversion (rasDir + i + '_harvest.tif', vecDir + i + '_harvest.shp', "NO_SIMPLIFY", "VALUE")
        arcpy.RasterToPolygon_conversion (rasDir + i + '_harvest_lc.tif', vecDir + i + '_harvest_lc.shp', "NO_SIMPLIFY", "VALUE")
        
        # Buffer harvest areas by 500m or 1000m
        #if i in ['cifl2013','gifl2013']:

        #    if i=='cifl2013':
        #        bufferDist = "500 Meters"
        #    else:
        #        bufferDist = "1000 Meters"

        #    arcpy.Buffer_analysis(vecDir + 'harvest.shp', 'buff1.shp', bufferDist, "FULL", "ROUND", "ALL")
        #    arcpy.Clip_analysis('buff1.shp', vecDir + 'bnd.shp', vecDir + 'harvest_buff.shp')
        #    arcpy.Clip_analysis(vecDir + 'harvest_buff.shp', vecDir + i + '.shp', vecDir + i + '_harvest_buff.shp')

        #    arcpy.Buffer_analysis(vecDir + 'harvest_lc.shp', 'buff2.shp', bufferDist, "FULL", "ROUND", "ALL")
        #    arcpy.Clip_analysis('buff2.shp', vecDir + 'bnd.shp', vecDir + 'harvest_lc_buff.shp')
        #    arcpy.Clip_analysis(vecDir + 'harvest_lc_buff.shp', vecDir + i + '.shp', vecDir + i + '_harvest_lc_buff.shp')
