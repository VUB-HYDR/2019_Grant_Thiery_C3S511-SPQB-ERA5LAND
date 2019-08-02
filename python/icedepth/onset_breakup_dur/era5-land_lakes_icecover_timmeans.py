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
#timmean plots

#==============================================================================
#IMPORT
#==============================================================================

import xarray as xr
import numpy as np
from mpl_toolkits.basemap import Basemap
import matplotlib.pyplot as plt
import matplotlib as mpl

#==============================================================================
#FUNCTIONS
#==============================================================================

def reader(filename):
    ds = xr.open_dataset(filename, decode_times=False)
    if 'duration' in filename:
        da = ds.iceduration.squeeze(dim='time')
    if 'start' in filename:
        da = ds.icestart.squeeze(dim='time') #make october 1st 
    if 'end' in filename:
        da = ds.iceend.squeeze(dim='time')
    return da
    
#==============================================================================
#SETTINGS
#==============================================================================

title_font = 13

tick_font = 11

lats_font = 7

#==============================================================================
#INITIALIZE DIRECTORIES
#==============================================================================

#output directory
o_directory = '/Users/Luke/Documents/PHD/C3S_511/FIGURES/era5-land/icedepth'

#data
startfile = '/Users/Luke/Documents/PHD/C3S_511/DATA/era5-land/icedepth/cover/timmean/era5-land_lakes_icecover_start_global_timmean_2001_2018.nc'
endfile = '/Users/Luke/Documents/PHD/C3S_511/DATA/era5-land/icedepth/cover/timmean/era5-land_lakes_icecover_end_global_timmean_2001_2018.nc'
durfile = '/Users/Luke/Documents/PHD/C3S_511/DATA/era5-land/icedepth/cover/timmean/era5-land_lakes_icecover_duration_global_timmean_2001_2018.nc'


#==============================================================================
#DATA AND MIN/MAXES FOR CHECK
#==============================================================================

start_plottable = reader(startfile)
end_plottable = reader(endfile)
dur_plottable = reader(durfile)

lat = start_plottable.latitude.values
lon = start_plottable.longitude.values

#==============================================================================
#COLORS
#==============================================================================

#colormaps for start/end

#oranges - Sep Oct Nov
oranges = plt.cm.get_cmap('Purples')
orange_cols = []
for i in np.linspace(0.2,1,9):
    orange_cols.append(oranges(i))

#blues - Dec Jan Feb    
blues = plt.cm.get_cmap('Blues')
blue_cols = []
for i in np.linspace(0.2,1,9):
    blue_cols.append(blues(i))    
    
#greens - Mar Apr May    
greens = plt.cm.get_cmap('Greens')
green_cols = []
for i in np.linspace(0.2,1,9):
    green_cols.append(greens(i))    
    
#reds - Jun Jul Aug
reds = plt.cm.get_cmap('Reds')
red_cols = []
for i in np.linspace(0.2,1,9):
    red_cols.append(reds(i))

cmap = mpl.colors.ListedColormap(orange_cols+blue_cols+green_cols+red_cols,N=36)

#colormap for duration
cmap_whole = plt.cm.get_cmap('viridis_r')
cmap50 = cmap_whole(0.05)
cmap45 = cmap_whole(0.1)
cmap40 = cmap_whole(0.15)
cmap35 = cmap_whole(0.2)
cmap30 = cmap_whole(0.25)
cmap25 = cmap_whole(0.3)
cmap20 = cmap_whole(0.35)
cmap10 = cmap_whole(0.4)
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

cmap_dur = mpl.colors.ListedColormap([cmap50, cmap40, cmap35, cmap20, cmap10, cmap0,
                                   cmap_10, cmap_20, cmap_35, cmap_40, cmap_50, cmap_55], N=12)

    
#=============================================================================
#PLOTTING
#=============================================================================

f, (ax1,ax2,ax3) = plt.subplots(1,3,figsize=(15,12));

lon, lat = np.meshgrid(lon, lat);

parallels = np.arange(30.,81.,10.);

parallels_lbs = ['30°','40°','50°','60°','70°'];

#=============================================================================
#ICE START
#=============================================================================

m = Basemap(projection='npaeqd',round=True,boundinglat=20,\
            lat_0=80,lon_0=0,resolution='l');
m.ax = ax1
ax1.set_title('a)',fontsize=title_font,loc='left')
ax1.set_title('Ice onset',fontsize=title_font,loc='center')
m.drawcoastlines(linewidth=0.2);
m.drawmapboundary(linewidth=0.15);
m.fillcontinents(color='lightgrey');
m.drawparallels(parallels,linewidth=0.1,color='0.75')
for i in np.arange(len(parallels[:-1])):
    ax1.annotate(parallels_lbs[i],xy=m(342.5,parallels[i]),fontsize=lats_font)
m.pcolormesh(lon, lat, start_plottable, latlon=True, cmap=cmap, vmax=610, vmin=245, zorder=3)

#setup colorbar
values = np.arange(240,610,10)
ticks = np.arange(240,610,30)
norm = mpl.colors.BoundaryNorm(values,cmap.N)
cbaxes = f.add_axes([0.1325, 0.315, 0.5, 0.015])
cb = mpl.colorbar.ColorbarBase(ax=cbaxes, cmap=cmap,
                               norm=norm,
                               spacing='uniform',
                               orientation='horizontal',
                               extend='neither',
                               ticks=ticks)
cb.set_label('Days in hydrological year',size=title_font)
cb.ax.xaxis.set_label_position('top');
cb.ax.tick_params(labelcolor='0.2', labelsize=tick_font, color='0.2', width=0.35, direction='out'); #change color of ticks?
cb.ax.set_xticklabels(['Sep','Oct','Nov','Dec','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep'])
cb.outline.set_edgecolor('0.3')
cb.outline.set_linewidth(0.35)


#=============================================================================
#ICE END
#=============================================================================

m2 = Basemap(projection='npaeqd',round=True,boundinglat=20,lat_0=90,lon_0=0,resolution='l');
m2.ax = ax2
ax2.set_title('b)',fontsize=title_font,loc='left')
ax2.set_title('Ice break-up',fontsize=title_font,loc='center')
m2.drawcoastlines(linewidth=0.2);
m2.drawmapboundary(linewidth=0.15);
m2.fillcontinents(color='lightgrey');
m2.drawparallels(parallels,linewidth=0.1,color='0.75')
for i in np.arange(len(parallels[:-1])):
    ax2.annotate(parallels_lbs[i],xy=m2(342.5,parallels[i]),fontsize=lats_font)
m2.pcolormesh(lon, lat, end_plottable, latlon=True, cmap=cmap, vmax=610, vmin=245, zorder=3)


#=============================================================================
#ICE DUR
#=============================================================================

m3 = Basemap(projection='npaeqd',round=True,boundinglat=20,lat_0=90,lon_0=0,resolution='l');
m3.ax = ax3
ax3.set_title('c)',fontsize=title_font,loc='left')
ax3.set_title('Ice duration',fontsize=title_font,loc='center')
m3.drawcoastlines(linewidth=0.2);
m3.drawmapboundary(linewidth=0.15);
m3.fillcontinents(color='lightgrey');
m3.drawparallels(parallels,linewidth=0.1,color='0.75')
for i in np.arange(len(parallels[:-1])):
    ax3.annotate(parallels_lbs[i],xy=m3(342.5,parallels[i]),fontsize=lats_font)
m3.pcolormesh(lon, lat, dur_plottable, latlon=True, cmap=cmap_dur, vmax=360,vmin=0, zorder=3)

#=============================================================================
#COLORBAR
#=============================================================================

values3 = [0,30,60,90,120,150,180,210,240,270,300,330,360]
norm3 = mpl.colors.BoundaryNorm(values3,cmap_dur.N)
cbaxes3 = f.add_axes([0.9175, 0.3595, 0.014, 0.275])
cb3 = mpl.colorbar.ColorbarBase(ax=cbaxes3, cmap=cmap_dur,
                               norm=norm3,
                               spacing='uniform',
                               orientation='vertical',
                               extend='neither',
                               ticks=values3 )
cb3.set_label('Days of ice cover',size=title_font)
cb3.ax.tick_params(labelcolor='0.2', labelsize=tick_font, color='0.2', width=0.35, direction='out'); #change color of ticks?
cb3.outline.set_edgecolor('0.3')
cb3.outline.set_linewidth(0.35)


plt.subplots_adjust(left=0.125, right=0.9, bottom=0.1, top=0.9, wspace=0.03, hspace=0.1)
plt.show()

#save figure
f.savefig(o_directory+'/'+'era5-land_lakes_icedepth_icecover_timmeans.png',bbox_inches='tight',dpi=500)
