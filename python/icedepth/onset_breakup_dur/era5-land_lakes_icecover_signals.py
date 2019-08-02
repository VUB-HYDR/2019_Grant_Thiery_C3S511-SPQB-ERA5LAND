#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 20 13:18:37 2019

@author: Luke
"""

#==============================================================================
#SUMMARY
#==============================================================================

#This script generates ERA5 icedepth (communicated as ice cover start/end/duration)
#signal plots

#==============================================================================
#IMPORT
#==============================================================================

import xarray as xr
import numpy as np
from mpl_toolkits.basemap import Basemap
import matplotlib.pyplot as plt
import matplotlib as mpl
import os

#==============================================================================
#FUNCTIONS
#==============================================================================

def reader(file):
    if 'start' in file:
        da = xr.open_dataset(file,decode_times=False).icestart.squeeze(dim='time')
    if 'end' in file:
        da = xr.open_dataset(file,decode_times=False).iceend.squeeze(dim='time')
    if 'dur' in file:
        da = xr.open_dataset(file,decode_times=False).iceduration.squeeze(dim='time')
    return da
    
#==============================================================================
#SETTINGS
#==============================================================================

title_font = 13

arrow_font = 11

tick_font = 11

lats_font = 7

#==============================================================================
#INITIALIZE DIRECTORIES
#==============================================================================

#output directory
o_directory = '/Users/Luke/Documents/PHD/C3S_511/FIGURES/era5-land/icedepth'

directory = '/Users/Luke/Documents/PHD/C3S_511/DATA/era5-land/icedepth/cover/signals'

os.chdir(directory)

files = []
for file in sorted(os.listdir(directory)):
    if '.nc' in file:
        files.append(file)

#==============================================================================
#DATA 
#==============================================================================

start_plottable = reader(files[2])
end_plottable = reader(files[1])
dur_plottable = reader(files[0])

signals = [start_plottable,end_plottable,dur_plottable]

lat = start_plottable.latitude.values
lon = start_plottable.longitude.values

ice_titles = ['Ice onset', 'Ice break-up', 'Ice duration']
letters = ['a)', 'b)', 'c)']

#==============================================================================
#PLOT TEST HIST
#==============================================================================

#hist to see spread of values dictating colorbar range for signal plots
f, ax1 = plt.subplots(1,3,figsize=(12,3),sharey=True)

count=0
for season,ax in zip(signals,ax1.flat):
    count=count+1
    ax.hist(season.values.flatten(),bins=40,range=(-50,50),rwidth=0.9)
    ax.set_title(ice_titles[count-1],loc='right')
    ax.spines['right'].set_visible(False)
    ax.spines['top'].set_visible(False)

f.text(0.5, 0.0, 'Day of Year for ice start', ha='center')
f.text(0.0, 0.5, 'Frequency', va='center', rotation='vertical')

plt.tight_layout()
plt.show()  

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

cmap = mpl.colors.ListedColormap([cmap_50,cmap_40,cmap_35,cmap_30,cmap_25,cmap_20,cmap0,
                                  cmap20,cmap25,cmap30,cmap35,cmap40,cmap50],N=13)
cmap.set_over(cmap55)
cmap.set_under(cmap_55)

#=============================================================================
#SET PLOTS
#=============================================================================

f, axes = plt.subplots(1,3,figsize=(15,12));

lon, lat = np.meshgrid(lon, lat)

parallels = np.arange(30.,81.,10.)
parallels_lbs = ['30°','40°','50°','60°','70°']
    
count = 0
for rcpmap,ax in zip(signals,axes.flatten()):
    count = count+1
    m = Basemap(projection='npaeqd',round=True,boundinglat=20,\
                lat_0=80,lon_0=0,resolution='l');
    m.ax = ax
    m.drawcoastlines(linewidth=0.2);
    m.drawmapboundary(linewidth=0.15);
    m.fillcontinents(color='whitesmoke');
    m.drawparallels(parallels,linewidth=0.1,color='0.75')
    for i in np.arange(len(parallels[:-1])):
        ax.annotate(parallels_lbs[i],xy=m(342.5,parallels[i]),fontsize=lats_font)
    m.pcolormesh(lon,lat,rcpmap,latlon=True,cmap=cmap,vmax=30,vmin=-30,zorder=3)
    if count<=3:
        ax.set_title(ice_titles[count-1],loc='center',fontsize=title_font)
        ax.set_title(letters[count-1],loc='left',fontsize=title_font)

    
#==============================================================================
#COLORBAR
#==============================================================================
        
values = [-30,-25,-20,-15,-10,-5,-1,1,5,10,15,20,25,30]

tick_locs = [-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30]

norm = mpl.colors.BoundaryNorm(values,cmap.N,clip=True)
cbaxes = f.add_axes([0.215, 0.35, 0.6, 0.015])
cb = mpl.colorbar.ColorbarBase(ax=cbaxes,cmap=cmap,
                               norm=norm,
                               spacing='uniform',
                               orientation='horizontal',
                               extend='both',
                               ticks=tick_locs)
cb.set_label('Change in ice onset, break-up or duration (days)',size=title_font)
cb.ax.xaxis.set_label_position('top');
cb.ax.tick_params(labelcolor='0.2',labelsize=tick_font,color='0.2',\
                  length=2.5,width=0.35,direction='out'); #change color of ticks?
cb.ax.set_xticklabels([r'$\leq$-30','-25','-20','-15','-10',\
                       '-5','0','5','10','15','20','25',r'30$\leq$'])
cb.outline.set_edgecolor('0.2')
cb.outline.set_linewidth(0.4)

#plot arrows
bluelabel = 'Later date (panels a,b) or longer duration (panel c)'
redlabel = 'Earlier date (panels a,b) or shorter duration (panel c)'

plt.text(0.75, -2.8, bluelabel, size=arrow_font, ha='center', va='center')
plt.text(0.25, -2.8, redlabel, size=arrow_font, ha='center', va='center')

plt.arrow(0.505, -3.5, 0.5, 0, width=0.25, linewidth=0.1, label=bluelabel,\
          shape='right', head_width=0.5, head_length=0.06,\
          facecolor=cmap40, edgecolor='k', clip_on=False)
plt.arrow(0.495, -3.5, -0.5, 0, width=0.25, linewidth=0.1, label=redlabel,\
          shape='left', head_width=0.5, head_length=0.06,\
          facecolor=cmap_40, edgecolor='k', clip_on=False)

plt.subplots_adjust(left=0.175, right=0.85, bottom=0.2, top=0.875, wspace=0.03, hspace=0.05)

plt.show()

#save figure
f.savefig(o_directory+'/'+'era5-land_lakes_icedepth_icecover_signals.png',bbox_inches='tight',dpi=900 )

























