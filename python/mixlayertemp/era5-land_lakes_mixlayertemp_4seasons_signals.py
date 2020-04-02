#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 20 13:18:37 2019

@author: Luke
"""

#==============================================================================
#SUMMARY
#==============================================================================

#This script is used to plot era5 mixlayertemp signals (10yr avg future minus 10yr avg hist) for 4 seasons

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

directory = '/Users/Luke/Documents/PHD/C3S_511/DATA/era5-land/04_2020/mixlayertemp/signals'
os.chdir(directory)
o_directory = '/Users/Luke/Documents/PHD/C3S_511/SPQB/04_2020/era5-land'

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
    
#==============================================================================
#PLOT TEST HIST
#==============================================================================

#hist to see spread of values dictating colorbar range for signal plots
f, ax1 = plt.subplots(1,4,figsize=(12,3),sharey=True)

count=0
for season,ax in zip(seasons,ax1.flat):
    count=count+1
    ax.hist(season.values.flatten(),bins=20,range=(-7,7),rwidth=0.9)
    ax.set_title(season_names[count-1],loc='right')
    ax.spines['right'].set_visible(False)
    ax.spines['top'].set_visible(False)

f.text(0.5, 0.0, 'Change in temp', ha='center')
f.text(0.0, 0.5, 'Frequency', va='center', rotation='vertical')

plt.tight_layout()
plt.show()  

#=============================================================================
#PLOT MAIN FIGURE
#=============================================================================

f, axes = plt.subplots(2,2,figsize=(15,12));

lon, lat = np.meshgrid(lon, lat)

cmap_whole = plt.cm.get_cmap('RdBu')
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
cmap0 = 'lightgrey'
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

cmap = mpl.colors.ListedColormap([cmap_50,cmap_40,cmap_30,cmap_20,cmap_10,cmap_5,cmap0,
                                  cmap5,cmap10,cmap20,cmap30,cmap40,cmap50], N=13)   
    
values = [-3,-2.5,-2,-1.5,-1,-0.5,-0.25,0.25,0.5,1,1.5,2,2.5,3]
tick_locs = [-3,-2,-1,0,1,2,3]
norm = mpl.colors.BoundaryNorm(values,cmap.N)

#set color of over/under arrows on colorbar
cmap.set_over(cmap55)
cmap.set_under(cmap_55)
    
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
    h = m.pcolormesh(lon, lat, season, latlon=True, cmap=cmap, norm=norm, vmin=-3, vmax=3, zorder=2)

#=============================================================================
#COLORBAR
#=============================================================================
    
cbaxes = f.add_axes([0.25, 0.15, 0.5, 0.015])
cb = mpl.colorbar.ColorbarBase(ax=cbaxes, cmap=cmap,
                               norm=norm,
                               spacing='proportional',
                               orientation='horizontal',
                               extend='both',
                               ticks=tick_locs)
cb.set_label('Change in lake mixed layer temperature (K)',size=title_font)
cb.ax.xaxis.set_label_position('top');
cb.ax.tick_params(labelcolor='0.2', labelsize=tick_font, color='0.2',length=2.5, width=0.4, direction='out'); #change color of ticks?
cb.ax.set_xticklabels([r'$\leq$-3','-2','-1','0','1','2',r'3$\leq$'])
cb.outline.set_edgecolor('0.2')
cb.outline.set_linewidth(0.4)

#plot arrows
bluelabel = 'Warmer'
redlabel = 'Colder'

plt.text(0.75, -2.9, bluelabel, size=title_font, ha='center', va='center')
plt.text(0.25, -2.9, redlabel, size=title_font, ha='center', va='center')

plt.arrow(0.505, -3.5, 0.44, 0, width=0.25, linewidth=0.1, label=bluelabel,\
          shape='right', head_width=0.5, head_length=0.06,\
          facecolor=cmap40, edgecolor='k', clip_on=False)
plt.arrow(0.495, -3.5, -0.44, 0, width=0.25, linewidth=0.1, label=redlabel,\
          shape='left', head_width=0.5, head_length=0.06,\
          facecolor=cmap_40, edgecolor='k', clip_on=False)



plt.subplots_adjust(left=0.15, right=0.85, bottom=0.175, top=0.6, wspace=0.1, hspace=0.0)

plt.show()

#save figure
f.savefig(o_directory+'/'+'D511.N.n.x_ERA5-land_lakes_mixedlayertemperature_icedepth_Section_2.4.2_Figure_1.png',bbox_inches='tight',dpi=500)

























