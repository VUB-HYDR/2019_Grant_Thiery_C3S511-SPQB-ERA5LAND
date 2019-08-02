#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 20 13:18:37 2019

@author: Luke
"""

#==============================================================================
#SUMMARY
#==============================================================================

#This script calculates and plots flipped histograms
#for lake mixed layer temperatures

#==============================================================================
#IMPORT
#==============================================================================

import xarray as xr
import os
import numpy as np
import matplotlib.pyplot as plt

#==============================================================================
#FUNCTIONS
#==============================================================================

def reducer(file):
    da = xr.open_dataset(file,decode_times=False).lmlt.squeeze(dim='time')
    da_1d_mean = da.mean(dim='longitude').values
    da_1d_std = da.std(dim='longitude').values
    all_lat = da.latitude.values 
    lat = np.where(da_1d_mean>0,all_lat,np.nan)
    lat = lat[np.logical_not(np.isnan(lat))]
    da_1d_mean = da_1d_mean[np.logical_not(np.isnan(da_1d_mean))]
    da_1d_std = da_1d_std[np.logical_not(np.isnan(da_1d_std))]
    return da_1d_mean,da_1d_std,lat

#==============================================================================
#SETTINGS
#==============================================================================

title_font = 12

tick_font = 10

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

MAMmean,MAMstd,MAMlat = reducer(files[2])
DJFmean,DJFstd,DJFlat = reducer(files[0])
JJAmean,JJAstd,JJAlat = reducer(files[1])
SONmean,SONstd,SONlat = reducer(files[3])

seasons = [[DJFmean,DJFstd,DJFlat],\
           [MAMmean,MAMstd,MAMlat],\
           [JJAmean,JJAstd,JJAlat],\
           [SONmean,SONstd,SONlat]]

season_names = ['DJF', 'MAM', 'JJA', 'SON']
letters = ['a)','b)','c)','d)']

#==============================================================================
#PLOT HISTOGRAM
#==============================================================================

#initialize plots
f,axes = plt.subplots(2,2,sharex=True,sharey=True,figsize=(10,10))

count=0
for season,ax in zip(seasons,axes.flat):
    count = count+1
    ax.plot(season[0], season[2], lw=3, color='steelblue', zorder=1)
    ax.fill_betweenx(season[2], (season[0]+season[1]),\
            (season[0]-season[1]),\
            lw=0.1, color='#a6bddb', zorder=1)
    ax.set_ylim(-60,91)
    ax.set_yticks(np.arange(-60,91,10))
    ax.set_yticklabels(['-60°',None,'-40°',None,'-20°',None,'0°',None,'20°',None,'40°',None,'60°',None,'80°'])
    ax.set_xlim(270,310)
    ax.set_xticks(np.arange(270,315,5))
    ax.spines['right'].set_visible(False)
    ax.spines['top'].set_visible(False)
    ax.xaxis.grid(color='0.8', linestyle='dashed', linewidth=0.5,zorder=0)
    ax.set_axisbelow(True)
    ax.set_title(letters[count-1],loc='left',fontsize=title_font)
    ax.set_title(season_names[count-1],loc='center',fontsize=title_font)

#labels
f.text(0.5, 0.05, 'Lake temperature (K)', ha='center', fontsize=title_font)
f.text(0.045, 0.5, 'Latitude', va='center', rotation='vertical', fontsize=title_font)

plt.show()

#save figure
f.savefig(o_directory+'/'+'era5-land_lakes_mixlayertemp_fliphist.png',bbox_inches='tight',dpi=500)


