#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 20 13:18:37 2019

@author: Luke
"""

#==============================================================================
#SUMMARY
#==============================================================================

#This script generates ERA5 lake ice depth signal plots

#==============================================================================
#IMPORT
#==============================================================================

import xarray as xr
import os
import numpy as np
from mpl_toolkits.basemap import Basemap
import matplotlib.pyplot as plt
import matplotlib as mpl

#==============================================================================
#FUNCTIONS
#==============================================================================

def reader(file):
    ds = xr.open_dataset(file, decode_times=False)
    da = ds.licd.squeeze(dim='time',drop=True)
    return da

#==============================================================================
#SETTINGS
#==============================================================================

title_font = 13

tick_font = 11

lats_font = 7

#==============================================================================
#INITIALIZE
#==============================================================================

directory = '/Users/Luke/Documents/PHD/C3S_511/DATA/era5-land/04_2020/icedepth/depth/signals'

o_directory = '/Users/Luke/Documents/PHD/C3S_511/SPQB/04_2020/era5-land'

#set directory
os.chdir(directory)

#==============================================================================
#OPEN DATA
#==============================================================================

files = []
for file in sorted(os.listdir(directory)):
    if '.nc' in file:
        files.append(file)

JAN = reader(files[4])
FEB = reader(files[3])
MAR = reader(files[7])
APR = reader(files[0])
MAY = reader(files[8]) 
JUN = reader(files[6])
JUL = reader(files[5])
AUG = reader(files[1])
SEP = reader(files[11])
OCT = reader(files[10])
NOV = reader(files[9])
DEC = reader(files[2])

months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']

dataset = [JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT,NOV,DEC]

sample_da = reader(files[0])

lat = sample_da.latitude.values
lon = sample_da.longitude.values

#==============================================================================
#DATA TESTS
#==============================================================================

testjan_min = np.nanmin(JAN.values)
testjan_max = np.nanmax(JAN.values)

testfeb_min = np.nanmin(FEB.values)
testfeb_max = np.nanmax(FEB.values)

testmar_min = np.nanmin(MAR.values)
testmar_max = np.nanmax(MAR.values)

#==============================================================================
#PLOT MAIN FIG
#==============================================================================

cmap_whole = plt.cm.get_cmap('RdBu_r')
cmap55 = cmap_whole(0.01)
cmap50 = cmap_whole(0.05)   #blue
cmap45 = cmap_whole(0.1)
cmap40 = cmap_whole(0.15)
cmap35 = cmap_whole(0.2)
cmap30 = cmap_whole(0.25)
cmap25 = cmap_whole(0.3)
cmap20 = cmap_whole(0.35)
cmap10 = cmap_whole(0.4)
cmap0 = 'darkgrey'
cmap_5 = cmap_whole(0.55)
cmap_10 = cmap_whole(0.6)
cmap_20 = cmap_whole(0.65)
cmap_25 = cmap_whole(0.7)
cmap_30 = cmap_whole(0.75)
cmap_35 = cmap_whole(0.8)
cmap_40 = cmap_whole(0.85)
cmap_45 = cmap_whole(0.9)
cmap_50 = cmap_whole(0.95)  #red
cmap_55 = cmap_whole(0.99)

cmap = mpl.colors.ListedColormap([cmap_50,cmap_30,cmap_20,cmap0,
                                  cmap20,cmap30,cmap50],N=7)
cmap.set_over(cmap55)
cmap.set_under(cmap_55)

values = [-0.75,-0.50,-0.25,-.025,0.025,0.25,0.5,0.75]
tick_locs = [-0.75,-0.50,-0.25,0,0.25,0.5,0.75]
norm = mpl.colors.BoundaryNorm(values,cmap.N)

#=============================================================================
#SET PLOTS
#=============================================================================

f, axes = plt.subplots(4,3,figsize=(15,15));

lon, lat = np.meshgrid(lon, lat)
    
count = 0
for month,ax in zip(dataset,axes.flatten()):
    count = count+1
    m = Basemap(projection='npaeqd',round=True,boundinglat=20,\
                lat_0=80,lon_0=0,resolution='l');
    m.ax = ax
    m.drawcoastlines(linewidth=0.4);
    m.drawmapboundary(fill_color='whitesmoke');
    m.fillcontinents(color='white');
    m.pcolormesh(lon,lat,month,latlon=True,cmap=cmap,norm=norm,vmax=0.75,vmin=-0.75,zorder=3)
    ax.set_title(months[count-1],loc='left',fontsize=title_font)

#==============================================================================
#COLORBAR
#==============================================================================

cbaxes = f.add_axes([0.2515, 0.165, 0.5, 0.015])
cb = mpl.colorbar.ColorbarBase(ax=cbaxes,cmap=cmap,
                               norm=norm,
                               spacing='uniform',
                               orientation='horizontal',
                               extend='both',
                               ticks=tick_locs)
cb.set_label('Change in ice thickness (m)',size=title_font)
cb.ax.xaxis.set_label_position('top');
cb.ax.tick_params(labelcolor='0.2',labelsize=tick_font,color='0.2',\
                  length=2.5,width=0.35,direction='out'); #change color of ticks?
cb.ax.set_xticklabels([r'$\leq$-0.75','-0.50',\
                       '-0.25','0','0.25','0.5',r'0.75$\leq$'])
cb.outline.set_edgecolor('0.2')
cb.outline.set_linewidth(0.4)

bluelabel = 'More ice cover'
redlabel = 'Less ice cover'

#plot arrows
plt.text(0.75, -2.8, bluelabel, size=title_font, ha='center', va='center')
plt.text(0.25, -2.8, redlabel, size=title_font, ha='center', va='center')

plt.arrow(0.505, -3.5, 0.44, 0, width=0.25, linewidth=0.1, label=bluelabel,\
          shape='right', head_width=0.5, head_length=0.06,\
          facecolor=cmap40, edgecolor='k', clip_on=False)
plt.arrow(0.495, -3.5, -0.44, 0, width=0.25, linewidth=0.1, label=redlabel,\
          shape='left', head_width=0.5, head_length=0.06,\
          facecolor=cmap_40, edgecolor='k', clip_on=False)

plt.subplots_adjust(left=0.25, right=0.75, bottom=0.2, top=0.85, wspace=0.05, hspace=0.05)

plt.show()

#save figure
f.savefig(o_directory+'/'+'C3S_D511_ERA5-land_lakes_mixedlayertemperature_icedepth_Figure_2.4.10.png',bbox_inches='tight',dpi=500)

























