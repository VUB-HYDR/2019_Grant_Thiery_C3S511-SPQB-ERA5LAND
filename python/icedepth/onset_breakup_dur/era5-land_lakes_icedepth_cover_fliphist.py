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
#for lake ice cover indices

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
    if 'start' in file:
        da = xr.open_dataset(file,decode_times=False).icestart.squeeze(dim='time')
    if 'end' in file:
        da = xr.open_dataset(file,decode_times=False).iceend.squeeze(dim='time')
    if 'dur' in file:
        da = xr.open_dataset(file,decode_times=False).iceduration.squeeze(dim='time')
    da_1d_mean = da.mean(dim='longitude').values
    da_1d_std = da.std(dim='longitude').values
    all_lat = da.latitude.values 
    lat = all_lat[(all_lat>=20)&(all_lat<=90)]
    mask = np.where((all_lat>=20)&(all_lat<=90))
    da_1d_mean = da_1d_mean[mask]
    da_1d_std = da_1d_std[mask]
    return da_1d_mean,da_1d_std,lat

#==============================================================================
#SETTINGS
#==============================================================================

title_font = 13

tick_font = 11

#==============================================================================
#INITIALIZE
#==============================================================================

directory = '/Users/Luke/Documents/PHD/C3S_511/DATA/era5-land/icedepth/cover/timmean'
os.chdir(directory)
o_directory = '/Users/Luke/Documents/PHD/C3S_511/FIGURES/era5-land/icedepth'

files = []
for file in sorted(os.listdir(directory)):
    if '.nc' in file:
        files.append(file)

#==============================================================================
#OPEN DATA
#==============================================================================

STARTmean,STARTstd,STARTlat = reducer(files[2])
ENDmean,ENDstd,ENDlat = reducer(files[1])
DURmean,DURstd,DURlat = reducer(files[0])


seasons = [[STARTmean,STARTstd,STARTlat],\
           [ENDmean,ENDstd,ENDlat],\
           [DURmean,DURstd,DURlat]]

indices = ['Ice onset','Ice break-up','Ice duration']
letters = ['a)','b)','c)']

#==============================================================================
#PLOT HISTOGRAM
#==============================================================================

#initialize plots
f,axes = plt.subplots(1,3,sharey=True,figsize=(15,7))

count=0
for season,ax in zip(seasons,axes.flat):
    count = count+1
    if count <= 2:
        ax.plot(season[0], season[2], lw=3, color='steelblue', zorder=1)
        ax.fill_betweenx(season[2], (season[0]+season[1]),\
                (season[0]-season[1]),\
                lw=0.1, color='#a6bddb', zorder=1)
        ax.set_ylim(20,90)
        ax.set_yticks(np.arange(20,90,10))
        ax.set_yticklabels(['20°','30°','40°','50°','60°','70°','80°','90°'],fontdict={'fontsize':tick_font})
        ax.set_xticks(ticks = np.arange(245,615,30))
        ax.set_xticklabels(['Sep',None,'Nov',None,'Jan',None,'Mar',None,'May',None,'Jul',None,'Sep'],fontdict={'fontsize':tick_font})
        ax.set_xlim(245,615)
        ax.spines['right'].set_visible(False)
        ax.spines['top'].set_visible(False)
        ax.xaxis.grid(color='0.8', linestyle='dashed', linewidth=0.5,zorder=0)
        ax.set_axisbelow(True)
        ax.set_title(letters[count-1],loc='left',fontsize=title_font)
        ax.set_title(indices[count-1],loc='center',fontsize=title_font)
    if count == 3:
        ax.plot(season[0], season[2], lw=3, color='steelblue', zorder=1)
        ax.fill_betweenx(season[2], (season[0]+season[1]),\
                (season[0]-season[1]),\
                lw=0.1, color='#a6bddb', zorder=1)
        ax.set_ylim(20,90)
        ax.set_yticks(np.arange(20,90,10))
        ax.set_xticks(ticks = np.arange(0,365,30))
        ax.set_xlim(0,365)
        ax.spines['right'].set_visible(False)
        ax.spines['top'].set_visible(False)
        ax.xaxis.grid(color='0.8', linestyle='dashed', linewidth=0.5,zorder=0)
        ax.set_axisbelow(True)
        ax.set_title(letters[count-1],loc='left',fontsize=title_font)
        ax.set_title(indices[count-1],loc='center',fontsize=title_font)
        

#labels
f.text(0.375, 0.055, 'Date in Hydrological year', ha='center', fontsize=title_font)
f.text(0.80, 0.055, 'Duration of ice cover', ha='center', fontsize=title_font)
f.text(0.075, 0.5, 'Latitude', va='center', rotation='vertical', fontsize=title_font)

plt.show()

#save figure
f.savefig(o_directory+'/'+'era5-land_lakes_icedepth_cover_fliphist.png',bbox_inches='tight',dpi=500)


