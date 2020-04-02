#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Oct 24 21:05:53 2018

@author: Luke
"""

#==============================================================================
#SUMMARY
#==============================================================================

#This script generates ERA5 lakes fldmean timeseries for ice depth
    
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

def reader(file):
    da=xr.open_dataset(file,decode_times=False).licd.squeeze(dim=['lat','lon']).values
    years = np.count_nonzero(da)
    if years == 38:
        year_range = np.arange(1981,1981+years)
    if years == 39:
        year_range = np.arange(1981,1981+years-1)
        da = da[:-1]
    ds = xr.DataArray(da,coords=[year_range],dims=['time'])
    return ds

#==============================================================================
#SETTINGS
#==============================================================================

title_font = 13

tick_font = 11

#==============================================================================
#INITIALIZE
#==============================================================================

directory = '/Users/Luke/Documents/PHD/C3S_511/DATA/era5-land/04_2020/icedepth/depth/fldmean'
os.chdir(directory)
o_directory = '/Users/Luke/Documents/PHD/C3S_511/SPQB/04_2020/era5-land'

files = []
for file in sorted(os.listdir(directory)):
    if '.nc' in file:
        files.append(file)

#variable with which to concatenate along
ens = xr.Variable('ensemble',[0,1,2])

#open time series
DJF = xr.concat([reader(files[2]),reader(files[3]),reader(files[4])],dim=ens).mean(dim='ensemble')
MAM = xr.concat([reader(files[0]),reader(files[7]),reader(files[8])],dim=ens).mean(dim='ensemble')
JJA = xr.concat([reader(files[5]),reader(files[6]),reader(files[1])],dim=ens).mean(dim='ensemble')
SON = xr.concat([reader(files[9]),reader(files[10]),reader(files[11])],dim=ens).mean(dim='ensemble')

#==============================================================================
#PLOTTING
#==============================================================================

#initiate plots
f, ax = plt.subplots(1,1,figsize=(12,8 ),sharex=True)

time = DJF.time.values

#load data
h = ax.plot(time,DJF,lw=2,color='steelblue',marker='o',label='De-Ja-Fe')
h = ax.plot(time,MAM,lw=2,color='mediumseagreen',marker='^',label='Ma-Ap-Ma')
h = ax.plot(time,JJA,lw=2,color='indianred',marker='s',label='Ju-Ju-Au')
h = ax.plot(time,SON,lw=2,color='sienna',marker='+',label='Se-Oc-No')

#figure adjustments
ax.set_xlim(1981,2019)
ax.tick_params(labelsize=tick_font,axis="x",direction="in", left="off",labelleft="on")
ax.tick_params(labelsize=tick_font,axis="y",direction="in")
ax.spines['right'].set_visible(False)
ax.spines['top'].set_visible(False)
ax.yaxis.grid(color='0.8', linestyle='dashed', linewidth=0.5)
ax.xaxis.grid(color='0.8', linestyle='dashed', linewidth=0.5)
ax.set_axisbelow(True)

#legend
handles, labels = ax.get_legend_handles_labels()
f.legend(handles, labels, bbox_to_anchor=(0.7, 0.5, 0.12, .15), loc=3,
           mode="expand", borderaxespad=0.,\
           frameon=True, handlelength=0.75, handletextpad=0.5,\
           fontsize=title_font, facecolor='white', edgecolor='k')

#labels
f.text(0.5, 0.065, 'Years', ha='center', fontsize=title_font)
f.text(0.065, 0.5, 'Ice thickness (m)', va='center', rotation='vertical', fontsize=title_font)

plt.show(h)

#save figure
f.savefig(o_directory+'/'+'C3S_D511_ERA5-land_lakes_mixedlayertemperature_icedepth_Figure_2.4.13.png',bbox_inches='tight',dpi=900)
