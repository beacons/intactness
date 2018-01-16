# ------------------------------------------------------------------------------
# Python functions to prepare data for intactness analyses
# Pierre Vernier
# January 4, 2018
# ------------------------------------------------------------------------------

import os, sys, arcpy
from arcpy import env
from arcpy.sa import *

def gen_boreal_data(extent):
    '''Prepare datasets for analysis at three spatial extents of the boreal region:
    North America (extent="na"), Canada (extent="ca"), and Alaska (extent="ak").'''

    # General arguments
    cellsize = 1000
    dropDir = 'E:/Pierre/Dropbox (BEACONs)/gisdata/'
    rasDir = dropDir + 'intactness/analysis/' + extent + '_boreal' + str(cellsize) + '/'
    vecDir = dropDir + 'intactness/analysis/' + 'vector_' + extent + '/'
    borealShp = vecDir + extent + '_boreal_boundary.shp'
    wgs84Prj = 'code/prj/WGS 1984.prj'
    albersPrj = "code/prj/brandt_albers.prj"

    # Original datasets
    brandtShp = dropDir + 'strata/brandt/original/NABoreal.shp'
    ecozonesShp = dropDir + 'ecoregions/ecozones.shp'
    ecoregionsL2Shp = dropDir + 'ecoregions/TerrestrialEcoregions_L2_Shapefile/NA_Terrestrial_Ecoregions_Level_II/data/eco_areas_lvl2/eco_areas_lvl2.shp'
    ciflBnd = dropDir + 'intactness/GFWC/GFWC_Study_Area_StatsCan_BND2006.shp'
    cifl2000Shp = dropDir + 'intactness/GFWC/Canada_IFL_circa2000_Revised.shp'
    cifl2013Shp = dropDir + 'intactness/GFWC/GFWC_Canada_IFL_2013_Final.shp'
    giflBnd = dropDir + 'intactness/GFW/forest_zone.shp'
    gifl2000Shp = dropDir + 'intactness/GFW/ifl_2000.shp'
    gifl2013Shp = dropDir + 'intactness/GFW/ifl_2013.shp'
    ffShp = dropDir + 'intactness/FrontierForests/frontier.shp'
    unusedAsc = dropDir + 'intactness/HANPP/4_unused00.asc'
    anthromesGrd1 = dropDir + 'intactness/Anthromes/anthromes_v1'
    anthromesGrd2 = dropDir + 'intactness/Anthromes/a2000/anthro2_a2000'
    msaAsc = dropDir + 'intactness/globio/MSA_OECD_BL_2000.asc'
    hfGrd = dropDir + 'intactness/HumanFootprint/original/hf_v2geo'
    hf1993Tif = dropDir + 'intactness/HumanFootprint/latest/Maps/HFP1993.tif'
    hf2009Tif = dropDir + 'intactness/HumanFootprint/latest/Maps/HFP2009.tif'
    lcmImg = dropDir + 'intactness/LCM/Statewide_LCM_Final_Products/Statewide_LCM_Unclassified_500.img'
    #pbaBnd = 'E:/Pierre/Dropbox (BEACONs)/PBA/Jan2016/gisdata/strata/pan_ecoregions_fda_v3.shp'
    ha2010Shp = dropDir + 'intactness/GFWC/HumanAccess_2010/Canada_Access_2010.shp'

    # Set workspace & parameters
    env.workspace = env.scratchFolder
    env.workspace = 'C:/Users/pvernier/desktop/tmp'
    env.overwriteOutput = True
    arcpy.CheckOutExtension("Spatial")
    arcpy.env.outputCoordinateSystem = albersPrj

    '''
    # Create boreal boundary based on Brandt's boreal (boreal + boreal alpine)
    print("Create boreal region boundary")
    arcpy.MakeFeatureLayer_management(brandtShp, "lyr")
    if extent=="ca":
        query = """ ("TYPE" = 'BOREAL' OR "TYPE" = 'B_ALPINE') AND ("COUNTRY" = 'CANADA') """
    elif extent=="ak":
        query = """ ("TYPE" = 'BOREAL' OR "TYPE" = 'B_ALPINE') AND ("COUNTRY" = 'USA') """
    elif extent=="na":
        query = """ ("TYPE" = 'BOREAL' OR "TYPE" = 'B_ALPINE') AND ("COUNTRY" = 'CANADA' OR "COUNTRY" = 'USA') """
    arcpy.SelectLayerByAttribute_management("lyr", "NEW_SELECTION", query)
    if not 'one' in [f.name for f in arcpy.ListFields("lyr")]:
        arcpy.AddField_management("lyr", "one", "SHORT", "4")
    arcpy.CalculateField_management("lyr", "one", "1", "Python")
    arcpy.Dissolve_management("lyr", borealShp, "one")

    # Convert Brandt's boreal shapefile to raster
    print("Rasterize boreal region")
    #arcpy.FeatureToRaster_conversion(borealShp, "one", rasDir + "boreal.tif", cellsize)
    '''
    # Now that we have a boundary grid we can set spatial analysis parameters
    arcpy.env.extent = rasDir + "boreal.tif"
    arcpy.env.snapRaster = rasDir + "boreal.tif"
    arcpy.env.cellSize = cellsize

    print "Clip HA 2010 to boreal..."
    arcpy.Clip_analysis(ha2010Shp, borealShp, "tmp1.shp")
    arcpy.Dissolve_management("tmp1.shp", "tmp2.shp")
    arcpy.Erase_analysis(borealShp, "tmp2.shp", vecDir + extent + "_ha2010.shp")
    arcpy.FeatureToRaster_conversion(vecDir + extent + "_ha2010.shp", "one", "tmp", cellsize)
    x = Raster("tmp") * Raster(rasDir + "boreal.tif")
    x.save(rasDir + "ha2010.tif")
    '''
    # Alaska LCM
    if extent=="ak":
        
        # Project and extract LCM1 (landscape intactness in Alaska)
        #arcpy.Clip_analysis(lcmShp, borealShp, "lcm.shp")
        #if not 'one' in [f.name for f in arcpy.ListFields("lcm.shp")]:
        #    arcpy.AddField_management("lcm.shp", "one", "SHORT", "4")
        #arcpy.CalculateField_management("lcm.shp", "one", "1", "Python")
        #arcpy.Dissolve_management("lcm.shp", vecDir + extent + "_lcm_boundary.shp", "one")
        
        print "Project and reclassify Alaska LCM..."
        x = Raster(lcmImg) * Raster(rasDir + "boreal.tif")
        #x.save(rasDir + "lcm.tif")
        remap = RemapRange([[0,0.999999,"NODATA"],[1,1,1]])
        y = Reclassify(x, "Value", remap, "DATA")
        y.save(rasDir + "lcm1.tif")

    if extent=="ca":
        # Convert boreal ecozones to raster (Canada only)
        print("Clip and rasterize ecozones")
        arcpy.Clip_analysis(ecozonesShp, borealShp, vecDir + "ca_ecozones.shp")
        arcpy.FeatureToRaster_conversion(vecDir + "ca_ecozones.shp", "ECOZONE", rasDir + "ecozones.tif", cellsize)
    elif extent=="na":
        # Convert boreal ecoregions L2 to raster
        print("Clip and rasterize ecoregions level 2")
        arcpy.Clip_analysis(ecoregionsL2Shp, borealShp, vecDir + "na_ecoregionsL2.shp")
        arcpy.FeatureToRaster_conversion(vecDir + "na_ecoregionsL2.shp", "LEVEL2", rasDir + "ecoregionsL2.tif", cellsize)

    # Project and convert Canada IFL boundary to raster
    if not extent=="ak":
        print("Extract Canada IFL study area boundaries")
        arcpy.Clip_analysis(ciflBnd, borealShp, "cifl.shp")
        if not 'one' in [f.name for f in arcpy.ListFields("cifl.shp")]:
            arcpy.AddField_management("cifl.shp", "one", "SHORT", "4")
        arcpy.CalculateField_management("cifl.shp", "one", "1", "Python")
        arcpy.Dissolve_management("cifl.shp", vecDir + extent + "_cifl_boundary.shp", "one")
        arcpy.FeatureToRaster_conversion(vecDir + extent + "_cifl_boundary.shp", "one", rasDir + "cifl.tif", cellsize)

    # Project and convert Global IFL boundary to raster
    print("Extract Global IFL study area boundaries")
    arcpy.Clip_analysis(giflBnd, borealShp, "gifl.shp")
    if not 'one' in [f.name for f in arcpy.ListFields("gifl.shp")]:
        arcpy.AddField_management("gifl.shp", "one", "SHORT", "4")
    arcpy.CalculateField_management("gifl.shp", "one", "1", "Python")
    arcpy.Dissolve_management("gifl.shp", vecDir + extent + "_gifl_boundary.shp", "one")
    arcpy.FeatureToRaster_conversion(vecDir + extent + "_gifl_boundary.shp", "one", rasDir + "gifl.tif", cellsize)

    # Save intersection of CIFL and GIFL
    if not extent=="ak":
        x = Raster(rasDir + "cifl.tif") * Raster(rasDir + "gifl.tif")
        x.save(rasDir + "cifl_gifl.tif")

    # Extract other intactness datasets
    if not extent=="ak":
        
        print "Project and convert CIFL 2000 to raster..."
        if not 'one' in [f.name for f in arcpy.ListFields(cifl2000Shp)]:
            arcpy.AddField_management(cifl2000Shp, "one", "SHORT", "4")
        arcpy.CalculateField_management(cifl2000Shp, "one", "1", "Python")
        arcpy.FeatureToRaster_conversion(cifl2000Shp, "one", "tmp", cellsize)
        x = Raster("tmp") * Raster(rasDir + "boreal.tif")
        x.save(rasDir + "cifl2000.tif")

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

    print "Clip CIFL 2013 to boreal..."
    arcpy.Clip_analysis(cifl2013Shp, borealShp, "tmp.shp")
    arcpy.Dissolve_management("tmp.shp", vecDir + extent + "_cifl2013.shp")
    print "Clip CIFL 2000 to boreal..."
    arcpy.Clip_analysis(cifl2000Shp, borealShp, "tmp.shp")
    arcpy.Dissolve_management("tmp.shp", vecDir + extent + "_cifl2000.shp")

    #print "Clip GIFL 2013 to boreal..."
    #arcpy.Clip_analysis(gifl2013Shp, borealShp, "tmp.shp")
    #arcpy.Dissolve_management("tmp.shp", vecDir + extent + "_gifl2013.shp")
    #print "Clip GIFL 2000 to boreal..."
    #arcpy.Clip_analysis(gifl2000Shp, borealShp, "tmp.shp")
    #arcpy.Dissolve_management("tmp.shp", vecDir + extent + "_gifl2000.shp")

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
    #print "Project and reclassify Anthropogenic Biomes (version 1)..."
    #x = Raster(anthromesGrd1) * Raster(rasDir + "boreal.tif")
    #remap = RemapRange([[1,52,"NODATA"],[61,62,1],[63,63,"NODATA"]])
    #y = Reclassify(x, "Value", remap, "DATA")
    #y.save(rasDir + "wild_v1.tif")

    # Project and reclassify Anthropogenic Biomes version 2
    print "Project and reclassify Anthropogenic Biomes (version 2)..."
    x = Raster(anthromesGrd2) * Raster(rasDir + "boreal.tif")
    remap = RemapRange([[1,52,"NODATA"],[53,53,"NODATA"],[54,54,"NODATA"],[61,61,1],[62,62,"NODATA"]])
    y = Reclassify(x, "Value", remap, "DATA")
    y.save(rasDir + "wild.tif")

    # Project and reclassify Globio MSA2000
    print "Project and reclassify Globio MSA2000..."
    arcpy.ASCIIToRaster_conversion(msaAsc, "msa", "FLOAT")
    arcpy.DefineProjection_management("msa", wgs84Prj)
    x = Raster("msa") * Raster(rasDir + "boreal.tif")
    remap = RemapRange([[0,0.9,"NODATA"],[0.9,1,1]])
    y = Reclassify(x, "Value", remap, "DATA")
    y.save(rasDir + "msa90.tif")

    # Reclassify Human Footprint
    #print "Project and reclassify Human Footprint..."
    #x = Raster(hfGrd) * Raster(rasDir + "boreal.tif")
    #remap = RemapRange([[0,0,1],[1,100,"NODATA"]])
    #y = Reclassify(x, "Value", remap, "DATA")
    #y.save(rasDir + "hf0.tif")

    # Reclassify Human Footprint (0=intact; 0.000000001-100=impact)
    print "Project and reclassify 1993 Human Footprint..."
    x = Raster(hf1993Tif) * Raster(rasDir + "boreal.tif")
    #x.save(rasDir + "hf1993_ALL.tif")
    remap = RemapRange([[0,0,1],[0,100,"NODATA"]])
    y = Reclassify(x, "Value", remap, "DATA")
    y.save(rasDir + "hf1993.tif")

    print "Project and reclassify 2009 Human Footprint..."
    x = Raster(hf2009Tif) * Raster(rasDir + "boreal.tif")
    #x.save(rasDir + "hf2009_ALL.tif")
    remap = RemapRange([[0,0,1],[0,100,"NODATA"]])
    y = Reclassify(x, "Value", remap, "DATA")
    y.save(rasDir + "hf2009.tif")
    '''

def convert_raster_to_vector():
    '''Convert selected intactness rasters to vector for case studies'''

    # Modify path here
    dropDir = 'E:/Pierre/Dropbox (BEACONs)/gisdata/intactness/'
    ha2010Shp = 'E:/Pierre/Dropbox (BEACONs)/PBA/Jan2016/gisdata/strata/boreal_vPB25_bnd_intactPB_dslv.shp'

    # Original datasets
    borealShp = dropDir + 'analysis/vector/na_boreal_boundary.shp'
    cifl2000Shp = dropDir + 'GFWC/Canada_IFL_circa2000_Revised.shp'
    cifl2013Shp = dropDir + 'GFWC/GFWC_Canada_IFL_2013_Final.shp'
    gifl2000Shp = dropDir + 'GFW/ifl_2000.shp'
    gifl2013Shp = dropDir + 'GFW/ifl_2013.shp'
    ffShp = dropDir + 'FrontierForests/frontier.shp'
    hf1993Tif = dropDir + 'analysis/na_boreal1000/hf1993.tif'
    hf2009Tif = dropDir + 'analysis/na_boreal1000/hf2009.tif'
    un100Tif = dropDir + 'analysis/na_boreal1000/un100.tif'
    wildTif = dropDir + 'analysis/na_boreal1000/wild.tif'
    msa90Tif = dropDir + 'analysis/na_boreal1000/msa90.tif'
    lcm1Tif = dropDir + 'analysis/na_boreal1000/lcm1.tif'

    # Set workspace & parameters
    brandtPrj = "prj/brandt_albers.prj"
    env.workspace = env.scratchFolder
    env.overwriteOutput = True
    arcpy.CheckOutExtension("Spatial")
    arcpy.env.outputCoordinateSystem = brandtPrj
    '''
    # Human Access
    arcpy.Clip_analysis(ha2010Shp, borealShp, "../data/vector/na_ha2010.shp")

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

    arcpy.RasterToPolygon_conversion ("../data/yt_central_harvest/region_harvest_high_year.tif", "../data/yt_central_harvest/region_harvest_high_year_vec.shp", "NO_SIMPLIFY", "VALUE")
    '''
