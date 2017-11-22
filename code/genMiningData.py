# ------------------------------------------------------------------------------
# genFootprintData.py
# Description: Prepare placer mining data for a given region within Yukon
# Author: Pierre Vernier
# Updated: Sept 19, 2017
# ------------------------------------------------------------------------------

import os, sys, arcpy
from arcpy import env
from arcpy.sa import *

region = 'yt_mining'
maps = ['cifl2013', 'gifl2013', 'hf2009', 'ff', 'un100', 'wild', 'msa90']
rasDir = '../data/' + region + '/raster/'
vecDir = '../data/' + region + '/vector/'

if not os.path.exists(rasDir):
    os.makedirs(rasDir)
if not os.path.exists(vecDir):
    os.makedirs(vecDir)

# Datasets
bnd = vecDir + 'bnd.shp'
prj = vecDir + 'bnd.prj'
#streams = 'E:/Pierre/Dropbox (BEACONs)/gisdata/prov/Yukon/Mining/Placer_Streams_250k.shp'
#claims = 'E:/Pierre/Dropbox (BEACONs)/gisdata/prov/Yukon/Mining/Placer_Claims_50k.shp'
mining = 'E:/Pierre/Dropbox (BEACONs)/gisdata/intactness/nwb_footprint/Mining_Disturbance_All.shp'

# Set workspace & parameters
env.workspace = env.scratchFolder
env.overwriteOutput = True
arcpy.CheckOutExtension('Spatial')
arcpy.env.outputCoordinateSystem = prj
'''
print('Rasterize boundary...')
if not 'one' in [f.name for f in arcpy.ListFields(bnd)]:
    arcpy.AddField_management(bnd, 'one', 'SHORT', '4')
arcpy.CalculateField_management(bnd, 'one', '1', 'Python')
arcpy.FeatureToRaster_conversion(bnd, 'one', rasDir + 'bnd.tif', 30)
'''
arcpy.env.extent = rasDir + 'bnd.tif'
arcpy.env.snapRaster = rasDir + 'bnd.tif'
arcpy.env.cellSize = rasDir + 'bnd.tif'
'''
# Streams: select STRMPOT_CD=1, extract to boundary, and buffer by 500m
arcpy.MakeFeatureLayer_management(streams, "lyr")
arcpy.SelectLayerByAttribute_management("lyr", "NEW_SELECTION", ' "STRMPOT_CD" = 1 ')
arcpy.Clip_analysis("lyr", bnd, vecDir + 'streams.shp')
arcpy.Buffer_analysis(vecDir + 'streams.shp', 'buff1.shp', "500 Meters", "FULL", "ROUND", "ALL")
arcpy.Clip_analysis('buff1.shp', vecDir + 'bnd.shp', vecDir + 'streams_buff500.shp')

# Claims: select STATUS="Active" and extract to boundary
arcpy.MakeFeatureLayer_management(claims, "lyr")
arcpy.SelectLayerByAttribute_management("lyr", "NEW_SELECTION", " STATUS = 'Active' ")
arcpy.Clip_analysis("lyr", bnd, vecDir + 'claims.shp')
'''
# Mining: create
if not 'one' in [f.name for f in arcpy.ListFields(mining)]:
    arcpy.AddField_management(mining, 'one', 'SHORT', '4')
arcpy.CalculateField_management(mining, 'one', '1', 'Python')
arcpy.Clip_analysis(mining, bnd, 'tmp.shp')
arcpy.Dissolve_management('tmp.shp', vecDir + 'mining.shp', 'one')

print('Extract and manipulate data...')
for i in maps:
    print('...' + i)
    '''
    arcpy.Clip_analysis('../data/vector/na_' + i + '.shp', bnd, vecDir + i + '.shp')
    if not 'one' in [f.name for f in arcpy.ListFields(vecDir + i + '.shp')]:
        arcpy.AddField_management(vecDir + i + '.shp', 'one', 'SHORT', '4')
    arcpy.CalculateField_management(vecDir + i + '.shp', 'one', '1', 'Python')
    arcpy.FeatureToRaster_conversion(vecDir + i + '.shp', 'one', rasDir + i + '.tif', 30)

    if i=='cifl2013':
        arcpy.Clip_analysis(vecDir + 'streams.shp', vecDir + i + '.shp', vecDir + i + '_streams.shp')
        arcpy.Clip_analysis(vecDir + 'streams_buff500.shp', vecDir + i + '.shp', vecDir + i + '_streams_buff500.shp')
    elif i=='gifl2013':
        arcpy.Clip_analysis(vecDir + 'streams.shp', vecDir + i + '.shp', vecDir + i + '_streams.shp')
        arcpy.Clip_analysis(vecDir + 'streams_buff500.shp', vecDir + i + '.shp', vecDir + i + '_streams_buff500.shp')
    else:
        arcpy.Clip_analysis(vecDir + 'streams.shp', vecDir + i + '.shp', vecDir + i + '_streams.shp')
        arcpy.Clip_analysis(vecDir + 'streams_buff500.shp', vecDir + i + '.shp', vecDir + i + '_streams_buff500.shp')
    '''
    #arcpy.Clip_analysis(vecDir + 'claims.shp', vecDir + i + '.shp', vecDir + i + '_claims.shp')
    arcpy.Clip_analysis(vecDir + 'mining.shp', vecDir + i + '.shp', vecDir + i + '_mining.shp')
