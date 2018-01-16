# ------------------------------------------------------------------------------
# Prepare Alberta case study data
# Pierre Vernier
# January 4, 2018
# ------------------------------------------------------------------------------

import os, sys, arcpy
from arcpy import env
from arcpy.sa import *

def gen_ab_data():
    # Prepare 2007-14 ABMI data for a given region with Alberta
    
    region = 'ab_seismic'
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
    #abmiShp = 'E:/Pierre/Dropbox (BEACONs)/gisdata/intactness/ABMI/HF_w2w_2012_v2_20150707.gdb/HF_w2w_2012_v3_20150707'
    abmi2014 = 'E:/Pierre/Dropbox (BEACONs)/gisdata/intactness/ABMI/ABMI_HFI_2014_public.gdb/clipped_to_boreal'
    abmi2012 = 'E:/Pierre/Dropbox (BEACONs)/gisdata/intactness/ABMI/HF_w2w_2012_v3_20150707.gdb/clipped_to_boreal'
    abmi2010 = 'E:/Pierre/Dropbox (BEACONs)/gisdata/intactness/ABMI/HF_2010_v13_Merged_Public.gdb/clipped_to_boreal'
    abmi2007 = 'E:/Pierre/Dropbox (BEACONs)/gisdata/intactness/ABMI/HFv43_merged.gdb/clipped_to_boreal'

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
    #arcpy.Clip_analysis(abmiShp, bnd, vecDir + 'abmi.shp')
    arcpy.Clip_analysis(abmi2014, bnd, vecDir + 'abmi2014.shp')
    arcpy.Clip_analysis(abmi2012, bnd, vecDir + 'abmi2012.shp')
    arcpy.Clip_analysis(abmi2010, bnd, vecDir + 'abmi2010.shp')
    arcpy.Clip_analysis(abmi2007, bnd, vecDir + 'abmi2007.shp')

    print('Extract and manipulate data...')
    for i in maps:
        print('...' + i)

        arcpy.Clip_analysis('E:/Pierre/Dropbox (BEACONs)/gisdata/intactness/analysis/vector_na/na_' + i + '.shp', bnd, vecDir + i + '.shp')
        #arcpy.Clip_analysis('../data/vector/na_' + i + '.shp', bnd, vecDir + i + '.shp')
        if not 'one' in [f.name for f in arcpy.ListFields(vecDir + i + '.shp')]:
            arcpy.AddField_management(vecDir + i + '.shp', 'one', 'SHORT', '4')
        arcpy.CalculateField_management(vecDir + i + '.shp', 'one', '1', 'Python')
        arcpy.FeatureToRaster_conversion(vecDir + i + '.shp', 'one', rasDir + i + '.tif', 30)

        if i in ['cifl2013', 'gifl2013']:
            arcpy.Clip_analysis(vecDir + 'abmi2014.shp', vecDir + i + '.shp', vecDir + i + '_abmi2014.shp')
            arcpy.Clip_analysis(vecDir + 'abmi2012.shp', vecDir + i + '.shp', vecDir + i + '_abmi2012.shp')
        elif i in ['ha2010','hf2009']:
            arcpy.Clip_analysis(vecDir + 'abmi2010.shp', vecDir + i + '.shp', vecDir + i + '_abmi2010.shp')
        else:
            arcpy.Clip_analysis(vecDir + 'abmi2007.shp', vecDir + i + '.shp', vecDir + i + '_abmi2007.shp')

        # Buffer harvest areas by 500m or 1000m
        #if i in ['cifl2013','gifl2013']:

        #    if i=='cifl2013':
        #        bufferDist = "500 Meters"
        #    else:
        #        bufferDist = "1000 Meters"

        #    for yr in ['2014','2012','2010','2007']:
        #        arcpy.Buffer_analysis(vecDir + 'abmi' + yr + '.shp', 'buff1.shp', bufferDist, "FULL", "ROUND", "ALL")
        #        arcpy.Clip_analysis('buff1.shp', vecDir + 'bnd.shp', vecDir + 'abmi' + yr + '_buff.shp')
        #        arcpy.Clip_analysis(vecDir + 'abmi' + yr + '_buff.shp', vecDir + i + '.shp', vecDir + i + '_abmi' + '_buff.shp')


    '''
    # OLD CODE

    # Project and convert Canada IFL boundary to raster
    print("Extract Canada IFL study area boundaries")
    arcpy.Clip_analysis(ciflBnd, abBorealShp, "cifl.shp")
    if not 'one' in [f.name for f in arcpy.ListFields("cifl.shp")]:
        arcpy.AddField_management("cifl.shp", "one", "SHORT", "4")
    arcpy.CalculateField_management("cifl.shp", "one", "1", "Python")
    arcpy.Dissolve_management("cifl.shp", vecDir + "abmi_cifl_boundary.shp", "one")
    arcpy.FeatureToRaster_conversion(vecDir + "abmi_cifl_boundary.shp", "one", rasDir + "cifl.tif", cellsize)

    # Project and convert Global IFL boundary to raster
    print("Extract Global IFL study area boundaries")
    arcpy.Clip_analysis(giflBnd, abBorealShp, "gifl.shp")
    if not 'one' in [f.name for f in arcpy.ListFields("gifl.shp")]:
        arcpy.AddField_management("gifl.shp", "one", "SHORT", "4")
    arcpy.CalculateField_management("gifl.shp", "one", "1", "Python")
    arcpy.Dissolve_management("gifl.shp", vecDir + "abmi_gifl_boundary.shp", "one")
    arcpy.FeatureToRaster_conversion(vecDir + "abmi_gifl_boundary.shp", "one", rasDir + "gifl.tif", cellsize)

    # Rasterize ABMI HFI and clip to boreal Alberta
    if not 'one' in [f.name for f in arcpy.ListFields(abmiShp)]:
        arcpy.AddField_management(abmiShp, "one", "SHORT", "4")
    arcpy.CalculateField_management(abmiShp, "one", "1", "Python")
    #arcpy.FeatureToRaster_conversion(abmiShp, "PUBLIC_CODE", "abmi_code", cellsize)
    print("Rasterizing...")
    arcpy.PolygonToRaster_conversion(abmiShp, "code", "abmi_code", "#", "#", cellsize)
    print("Intersecting...")
    x = Raster(rasDir + "boreal.tif") * Raster("abmi_code")
    print("Saving...")
    x.save(rasDir + "abmi_codes.tif")
    #arcpy.FeatureToRaster_conversion(abmiShp, "one", "abmi", cellsize)
    #x = Raster(rasDir + "boreal.tif") * Raster("abmi")
    #x.save(rasDir + "abmi.tif")

    # Extract other intactness datasets Albert boreal
    print "Project and convert CIFL 2000 to raster..."
    if not 'one' in [f.name for f in arcpy.ListFields(cifl2000Shp)]:
        arcpy.AddField_management(cifl2000Shp, "one", "SHORT", "4")
        arcpy.CalculateField_management(cifl2000Shp, "one", "1", "Python")
    arcpy.FeatureToRaster_conversion(cifl2000Shp, "one", "tmp", cellsize)
    x = Raster("tmp") * Raster(rasDir + "boreal.tif")
    x.save(rasDir + "cifl2000.tif")

    print "Project and convert CIFL 2013 to raster..."
    if not 'one' in [f.name for f in arcpy.ListFields(cifl2013Shp)]:
        arcpy.AddField_management(cifl2013Shp, "one", "SHORT", "4")
        arcpy.CalculateField_management(cifl2013Shp, "one", "1", "Python")
    arcpy.FeatureToRaster_conversion(cifl2013Shp, "one", "tmp", cellsize)
    x = Raster("tmp") * Raster(rasDir + "boreal.tif")
    x.save(rasDir + "cifl2013.tif")

    # Project and convert global GIFL to raster
    print "Project and convert GIFL 2000 to raster..."
    if not 'one' in [f.name for f in arcpy.ListFields(gifl2000Shp)]:
        arcpy.AddField_management(gifl2000Shp, "one", "SHORT", "4")
        arcpy.CalculateField_management(gifl2000Shp, "one", "1", "Python")
    arcpy.FeatureToRaster_conversion(gifl2000Shp, "one", "tmp", cellsize)
    x = Raster("tmp") * Raster(rasDir + "boreal.tif")
    x.save(rasDir + "gifl2000.tif")

    print "Project and convert GIFL 2013 to raster..."
    if not 'one' in [f.name for f in arcpy.ListFields(gifl2013Shp)]:
        arcpy.AddField_management(gifl2013Shp, "one", "SHORT", "4")
        arcpy.CalculateField_management(gifl2013Shp, "one", "1", "Python")
    arcpy.FeatureToRaster_conversion(gifl2013Shp, "one", "tmp", cellsize)
    x = Raster("tmp") * Raster(rasDir + "boreal.tif")
    x.save(rasDir + "gifl2013.tif")

    # Project and convert Frontier Forests to raster
    print "Project and convert Frontier Forests to raster..."
    if not 'one' in [f.name for f in arcpy.ListFields(ffShp)]:
        arcpy.AddField_management(ffShp, "one", "SHORT", "4")
        arcpy.CalculateField_management(ffShp, "one", "1", "Python")
    arcpy.FeatureToRaster_conversion(ffShp, "one", "tmp", cellsize)
    x = Raster("tmp") * Raster(rasDir + "boreal.tif")
    x.save(rasDir + "ff.tif")

    # Project and reclassify Unused00
    print "Project and reclassify Unused00..."
    arcpy.ASCIIToRaster_conversion(unusedAsc, "unused", "INTEGER")
    arcpy.DefineProjection_management("unused", wgs84Prj)
    x = Raster("unused") * Raster(rasDir + "boreal.tif")
    remap = RemapValue([[0,"NODATA"],[1,1]])
    y = Reclassify(x, "Value", remap, "DATA")
    y.save(rasDir + "un100.tif")

    # Project and reclassify Anthropogenic Biomes version 1
    print "Project and reclassify Anthropogenic Biomes (version 1)..."
    x = Raster(anthromesGrd1) * Raster(rasDir + "boreal.tif")
    remap = RemapRange([[1,52,"NODATA"],[61,62,1],[63,63,"NODATA"]])
    y = Reclassify(x, "Value", remap, "DATA")
    y.save(rasDir + "wild_v1.tif")

    # Project and reclassify Anthropogenic Biomes version 2
    print "Project and reclassify Anthropogenic Biomes (version 2)..."
    x = Raster(anthromesGrd2) * Raster(rasDir + "boreal.tif")
    remap = RemapRange([[1,52,"NODATA"],[53,53,"NODATA"],[54,54,"NODATA"],[61,61,1],[62,62,"NODATA"]])
    y = Reclassify(x, "Value", remap, "DATA")
    y.save(rasDir + "wild_v2.tif")

    # Project and reclassify Globio MSA2000
    print "Project and reclassify Globio MSA2000..."
    arcpy.ASCIIToRaster_conversion(msaAsc, "msa", "FLOAT")
    arcpy.DefineProjection_management("msa", wgs84Prj)
    x = Raster("msa") * Raster(rasDir + "boreal.tif")
    remap = RemapRange([[0,0.9,"NODATA"],[0.9,1,1]])
    y = Reclassify(x, "Value", remap, "DATA")
    y.save(rasDir + "msa90.tif")

    # Reclassify Human Footprint
    print "Project and reclassify Human Footprint..."
    x = Raster(hfGrd) * Raster(rasDir + "boreal.tif")
    remap = RemapRange([[0,0,1],[1,100,"NODATA"]])
    y = Reclassify(x, "Value", remap, "DATA")
    y.save(rasDir + "hf0.tif")

    # Reclassify Human Footprint (0=intact; 0.000000001-100=impact)
    print "Project and reclassify 1993 Human Footprint..."
    x = Raster(hf1993Tif) * Raster(rasDir + "boreal.tif")
    x.save(rasDir + "hf1993_ALL.tif")
    remap = RemapRange([[0,0,1],[0,100,"NODATA"]])
    y = Reclassify(x, "Value", remap, "DATA")
    y.save(rasDir + "hf1993.tif")

    print "Project and reclassify 2009 Human Footprint..."
    x = Raster(hf2009Tif) * Raster(rasDir + "boreal.tif")
    x.save(rasDir + "hf2009_ALL.tif")
    remap = RemapRange([[0,0,1],[0,100,"NODATA"]])
    y = Reclassify(x, "Value", remap, "DATA")
    y.save(rasDir + "hf2009.tif")
    '''
