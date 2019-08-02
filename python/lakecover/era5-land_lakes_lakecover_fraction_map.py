#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 20 13:18:37 2019

@author: Luke
"""

#==============================================================================
#SUMMARY
#==============================================================================

#This script is used to plot lake cover in Flake for era5 data

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

directory = '/Users/Luke/Documents/PHD/C3S_511/DATA/era5-land/lakecover'
os.chdir(directory)
file = 'era5-land_lakemask.nc'
o_directory = '/Users/Luke/Documents/PHD/C3S_511/FIGURES/era5-land/lakecover'

#==============================================================================
#OPEN DATA
#==============================================================================

cover = xr.open_dataset(file,decode_times=False).cl.squeeze(dim='time')
cover = cover.where(cover>0)

lon = cover.longitude.values
lat = cover.latitude.values

#=============================================================================
#PLOT
#=============================================================================

f, ax = plt.subplots(1,1,figsize=(15,12));

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

cmap = mpl.colors.ListedColormap([cmap_50,cmap_40,cmap_30,cmap_20,cmap_10,cmap10,cmap20,cmap30,cmap40,cmap50], N=10)  

parallels = np.arange(-60.,91.,30.);
meridians = np.arange(-135.,136.,45.);

m = Basemap(llcrnrlon=-170, llcrnrlat=-60, urcrnrlon=180, urcrnrlat=90, suppress_ticks=False);
m.ax = ax
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
h = m.pcolormesh(lon, lat, cover, latlon=True, cmap=cmap, vmin=0, vmax=1, zorder=2)

#=============================================================================
#COLORBAR
#=============================================================================

values = [0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0]
tick_locs = [0,0.2,0.4,0.6,0.8,1.0]

norm = mpl.colors.BoundaryNorm(values,cmap.N)
cbaxes = f.add_axes([0.25, 0.15, 0.5, 0.015])
cb = mpl.colorbar.ColorbarBase(ax=cbaxes, cmap=cmap,
                               norm=norm,
                               spacing='uniform',
                               orientation='horizontal',
                               ticks=tick_locs)
cb.set_label('Grid-fraction lake cover',size=title_font)
cb.ax.xaxis.set_label_position('top');
cb.ax.tick_params(labelcolor='0.2', labelsize=tick_font, color='0.2',length=2.5, width=0.4, direction='out'); #change color of ticks?

cb.ax.set_xticklabels(['0','0.2','0.4','0.6','0.8','1.0'])
cb.outline.set_edgecolor('0.2')
cb.outline.set_linewidth(0.4)

plt.subplots_adjust(left=0.15, right=0.85, bottom=0.175, top=0.6, wspace=0.1, hspace=0.0)

plt.show()

#save figure
f.savefig(o_directory+'/'+'era5-land_lakes_lakecover_0_1_map.png',bbox_inches='tight',dpi=500)

























