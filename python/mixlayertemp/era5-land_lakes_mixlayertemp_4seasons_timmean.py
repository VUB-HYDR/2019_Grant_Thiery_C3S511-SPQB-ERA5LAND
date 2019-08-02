#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 20 13:18:37 2019

@author: Luke
"""

#==============================================================================
#SUMMARY
#==============================================================================

#This script is used to plot average ERA5 mixlayertemp for 4 seasons

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

#==============================================================================
#SETTINGS
#==============================================================================

title_font = 13

tick_font = 11

#==============================================================================
#INITIALIZE
#==============================================================================

directory = '/Users/Luke/Documents/PHD/C3S_511/DATA/era5-land/mixlayertemp/timmean'
os.chdir(directory)
o_directory = '/Users/Luke/Documents/PHD/C3S_511/FIGURES/era5-land/mixlayertemp'

files = []
for file in sorted(os.listdir(directory)):
    if '.nc' in file:
        files.append(file)

#==============================================================================
#OPEN DATA
#==============================================================================

MAM = xr.open_dataset(files[2],decode_times=False).lmlt.squeeze(dim='time')
DJF = xr.open_dataset(files[0],decode_times=False).lmlt.squeeze(dim='time')
JJA = xr.open_dataset(files[1],decode_times=False).lmlt.squeeze(dim='time')
SON = xr.open_dataset(files[3],decode_times=False).lmlt.squeeze(dim='time')

lon = SON.longitude.values
lat = SON.latitude.values

seasons = [DJF,MAM,JJA,SON]

season_names = ['DJF', 'MAM', 'JJA', 'SON']
letters = ['a)','b)','c)','d)']
    
    
#==============================================================================
#TEST DATA BOUNDS
#==============================================================================
    
DJFmax = np.nanmax(DJF.values)
DJFmin = np.nanmin(DJF.values)

MAMmax = np.nanmax(MAM.values)
MAMmin = np.nanmin(MAM.values)

JJAmax = np.nanmax(JJA.values)
JJAmin = np.nanmin(JJA.values)

SONmax = np.nanmax(SON.values)
SONmin = np.nanmin(SON.values)

#=============================================================================
#PLOT
#=============================================================================

f, axes = plt.subplots(2,2,figsize=(15,12));

lon, lat = np.meshgrid(lon, lat)

cmap_whole = plt.cm.get_cmap('Spectral')
cmap55 = cmap_whole(0.01)   
cmap50 = cmap_whole(0.05)
cmap45 = cmap_whole(0.1)
cmap40 = cmap_whole(0.15)
cmap35 = cmap_whole(0.2)
cmap30 = cmap_whole(0.25)
cmap25 = cmap_whole(0.3)
cmap20 = cmap_whole(0.35)
cmap10 = cmap_whole(0.4)
cmap5 = cmap_whole(0.45)
cmap0 = cmap_whole(0.5)
cmap_5 = cmap_whole(0.55)
cmap_10 = cmap_whole(0.6)
cmap_20 = cmap_whole(0.65)
cmap_25 = cmap_whole(0.7)
cmap_30 = cmap_whole(0.75)
cmap_35 = cmap_whole(0.8)
cmap_40 = cmap_whole(0.85)
cmap_45 = cmap_whole(0.9)
cmap_50 = cmap_whole(0.95)  
cmap_55 = cmap_whole(0.99)

cmap = mpl.colors.ListedColormap([cmap_55,cmap_40,cmap_25,cmap_10,cmap10,cmap25,cmap40,cmap55], N=8)  

parallels = np.arange(-60.,91.,30.);
meridians = np.arange(-135.,136.,45.);


count=0
for season,ax in zip(seasons,axes.flat):
    count=count+1
    m = Basemap(llcrnrlon=-170, llcrnrlat=-60, urcrnrlon=180, urcrnrlat=90, suppress_ticks=False);
    m.ax = ax
    ax.set_title(season_names[count-1],loc='center',fontsize=title_font)
    ax.set_title(letters[count-1],loc='left',fontsize=title_font)
    m.drawcoastlines(linewidth=0.2);
    m.drawmapboundary(fill_color='whitesmoke')
    parallels = np.arange(-60.,91.,30.);
    m.fillcontinents(color='white');
    ax.set_yticks(parallels);
    ax.set_xticks(meridians);
    ax.tick_params(labelbottom=False, labeltop=False, labelleft=False, labelright=False,
                     bottom=False, top=False, left=False, right=False, color='0.2',\
                     labelcolor='0.2', labelsize=5,width=0.4,direction="in",length=2.5)
    ax.spines['bottom'].set_color('0.2')
    ax.spines['bottom'].set_linewidth(0.4)
    ax.spines['top'].set_color('0.2')
    ax.spines['top'].set_linewidth(0.4)
    ax.xaxis.label.set_color('0.2')
    ax.spines['left'].set_color('0.2')
    ax.spines['left'].set_linewidth(0.4)
    ax.spines['right'].set_color('0.2')
    ax.spines['right'].set_linewidth(0.4)
    ax.yaxis.label.set_color('0.2')
    h = m.pcolormesh(lon, lat, season, latlon=True, cmap=cmap, vmin=270, vmax=310, zorder=2)

#=============================================================================
#PLOT
#=============================================================================

values = [270,275,280,285,290,295,300,305,310]
tick_locs = [270,275,280,285,290,295,300,305,310]

norm = mpl.colors.BoundaryNorm(values,cmap.N)
cbaxes = f.add_axes([0.25, 0.15, 0.5, 0.015])
cb = mpl.colorbar.ColorbarBase(ax=cbaxes, cmap=cmap,
                               norm=norm,
                               spacing='proportional',
                               orientation='horizontal',
                               ticks=tick_locs)
cb.set_label('Lake mixed layer temperature (K)',size=title_font)
cb.ax.xaxis.set_label_position('top');
cb.ax.tick_params(labelcolor='0.2', labelsize=tick_font, color='0.2',length=2.5, width=0.4, direction='out'); #change color of ticks?

cb.ax.set_xticklabels(['270','275','280','285','290','295','300','305','310'])
cb.outline.set_edgecolor('0.2')
cb.outline.set_linewidth(0.4)

plt.subplots_adjust(left=0.15, right=0.85, bottom=0.175, top=0.6, wspace=0.1, hspace=0.0)

plt.show()

#save figure
f.savefig(o_directory+'/'+'era5-land_lakes_mixlayertemp_4seasons.png',bbox_inches='tight',dpi=500)

























