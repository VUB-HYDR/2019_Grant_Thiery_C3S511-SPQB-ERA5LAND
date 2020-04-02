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
#for lake ice depth 

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
    da = xr.open_dataset(file,decode_times=False).licd.squeeze(dim='time')
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

title_font = 14

tick_font = 12

#==============================================================================
#INITIALIZE
#==============================================================================

directory = '/Users/Luke/Documents/PHD/C3S_511/DATA/era5-land/04_2020/icedepth/depth/timmean'
os.chdir(directory)
o_directory = '/Users/Luke/Documents/PHD/C3S_511/SPQB/04_2020/era5-land'

files = []
for file in sorted(os.listdir(directory)):
    if '.nc' in file:
        files.append(file)

#==============================================================================
#OPEN DATA
#==============================================================================


JANmean,JANstd,JANlat = reducer(files[4])
FEBmean,FEBstd,FEBlat = reducer(files[3])
MARmean,MARstd,MARlat = reducer(files[7])
APRmean,APRstd,APRlat = reducer(files[0])
MAYmean,MAYstd,MAYlat = reducer(files[8]) 
JUNmean,JUNstd,JUNlat = reducer(files[6])
JULmean,JULstd,JULlat = reducer(files[5])
AUGmean,AUGstd,AUGlat = reducer(files[1])
SEPmean,SEPstd,SEPlat = reducer(files[11])
OCTmean,OCTstd,OCTlat = reducer(files[10])
NOVmean,NOVstd,NOVlat = reducer(files[9])
DECmean,DECstd,DEClat = reducer(files[2])

seasons = [[JANmean,JANstd,JANlat],\
           [FEBmean,FEBstd,FEBlat],\
           [MARmean,MARstd,MARlat],\
           [APRmean,APRstd,APRlat],\
           [MAYmean,MAYstd,MAYlat],\
           [JUNmean,JUNstd,JUNlat],\
           [JULmean,JULstd,JULlat],\
           [AUGmean,AUGstd,AUGlat],\
           [SEPmean,SEPstd,SEPlat],\
           [OCTmean,OCTstd,OCTlat],\
           [NOVmean,NOVstd,NOVlat],\
           [DECmean,DECstd,DEClat]]

months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']

#==============================================================================
#PLOT HISTOGRAM
#==============================================================================

#initialize plots
f,axes = plt.subplots(4,3,sharex=True,sharey=True,figsize=(15,15))

count=0
for season,ax in zip(seasons,axes.flat):
    count = count+1
    ax.plot(season[0], season[2], lw=3, color='steelblue', zorder=1)
    ax.fill_betweenx(season[2], (season[0]+season[1]),\
            (season[0]-season[1]),\
            lw=0.1, color='#a6bddb', zorder=1)
    ax.set_ylim(20,90)
    ax.set_yticks(np.arange(20,90,10))
    ax.set_yticklabels(['20°','30°','40°','50°','60°','70°','80°','90°'],fontdict={'fontsize':tick_font})
    ax.set_xlim(0,2.4)
    ax.set_xticklabels([0.2,None,0.6,None,1.0,None,1.4,None,1.8,None,2.2,None],fontdict={'fontsize':tick_font})
    ax.set_xticks(np.arange(0.2,2.4,0.2))
    ax.spines['right'].set_visible(False)
    ax.spines['top'].set_visible(False)
    ax.xaxis.grid(color='0.8', linestyle='dashed', linewidth=0.5,zorder=0)
    ax.set_axisbelow(True)
    ax.set_title(months[count-1],loc='left',fontsize=title_font)

#labels
f.text(0.5, 0.075, 'Ice thickness (m)', ha='center', fontsize=title_font)
f.text(0.075, 0.5, 'Latitude', va='center', rotation='vertical', fontsize=title_font)

plt.show()

#save figure
f.savefig(o_directory+'/'+'D511.N.n.x_ERA5-land_lakes_mixedlayertemperature_icedepth_Section_2.4.1_Figure_6.png',bbox_inches='tight',dpi=500)


