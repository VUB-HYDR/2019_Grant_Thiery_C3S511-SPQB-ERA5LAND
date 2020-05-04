#!/bin/bash -l

# =======================================================================
# SUMMARY
# =======================================================================

# Operations on C3S_511 mixed layer temperature files:
    # masking for inland water bodies
    # selection of seasonal averages: 1) temporal average (spatial plots per season) and 2) global/annual means (time series per season)
    # global/annual means on monthly series for time series
    # seasonal signals (between two 5-year means)

# =======================================================================
# INITIALIZATION
# =======================================================================

# set output directory
outDIR=/theia/data/brussel/101/vsc10116/C3S_511/era5-land/mixlayertemp

# user scratch directory
scratchDIR=/theia/scratch/projects/climate/users/lgrant/era5-land/proc/mixlayertemp

# set mask directory (lakecover)
maskDIR=/theia/scratch/projects/climate/data/dataset/era5-land/lakes/lakecover

# set starting directory
inDIR=/theia/scratch/projects/climate/data/dataset/era5-land/lakes/mixlayertemp

# seasons
SEASONs=('DJF' 'MAM' 'JJA' 'SON')

# years
YEARs=('1981_1985' '1986_1990' '1991_1995' '1996_2000' '2001_2005' '2006_2010' '2011_2015' '2016_2019')

# ==============================================================================
# PROCESSING
# ==============================================================================

cd $inDIR
pwd

#TIMERANGEs=('1981_1990' '1991_2000' '2071_2080' '2081_2090' '2091_2099')
#for i in $(seq $((${TIMERANGEs[0]:0:4}+0)) $((${TIMERANGEs[1]:5:4}+0))); do

# prep start file to day res
for YEAR in "${YEARs[@]}"; do

    cdo -b F64 -O -L setreftime,1981-01-01,00:00:00,1months -settaxis,$((${YEAR:0:4}+0))-01-01,00:00:00,1months -monmean era5-land_lakes_mixlayertemp_6hourly_${YEAR}.nc $scratchDIR/startfile_${YEAR}.nc

done

cdo -b F64 mergetime $scratchDIR/startfile_*.nc $scratchDIR/mixlayertemp_1981_2019_unmasked.nc

rm $scratchDIR/startfile_*.nc

# mask starting file
cdo ifthen $maskDIR/era5-land_lakemask.nc $scratchDIR/mixlayertemp_1981_2019_unmasked.nc $scratchDIR/mixlayertemp_monthly_1981_2019.nc

rm $scratchDIR/mixlayertemp_1981_2019_unmasked.nc


# seasonal files to operate on
cdo -b F64 -O -L yearmean -selmon,12,1,2 $scratchDIR/mixlayertemp_monthly_1981_2019.nc $scratchDIR/mixlayertemp_DJF_1981_2019.nc
cdo -b F64 -O -L yearmean -selmon,3/5 $scratchDIR/mixlayertemp_monthly_1981_2019.nc $scratchDIR/mixlayertemp_MAM_1981_2019.nc
cdo -b F64 -O -L yearmean -selmon,6/8 $scratchDIR/mixlayertemp_monthly_1981_2019.nc $scratchDIR/mixlayertemp_JJA_1981_2019.nc
cdo -b F64 -O -L yearmean -selmon,9/11 $scratchDIR/mixlayertemp_monthly_1981_2019.nc $scratchDIR/mixlayertemp_SON_1981_2019.nc


# global annual mean time series
cdo -b F64 -O -L fldmean -yearmonmean $scratchDIR/mixlayertemp_monthly_1981_2019.nc $outDIR/era5-land_lakes_mixlayertemp_global_annual_fldmean_1981_2019.nc

# calculate diagnostics
for SEASON in "${SEASONs[@]}"; do

    # global mean time series for seasons
    cdo -b F64 -O fldmean $scratchDIR/mixlayertemp_${SEASON}_1981_2019.nc $outDIR/fldmean/era5-land_lakes_mixlayertemp_${SEASON}_global_annual_fldmean_1981_2019.nc

    # temporal mean for seasonal average maps
    cdo -b F64 -O timmean $scratchDIR/mixlayertemp_${SEASON}_1981_2019.nc $outDIR/timmean/era5-land_lakes_mixlayertemp_${SEASON}_timmean_1981_2019.nc

    # signal for seasonal average maps (first 5 years)
    cdo -b F64 -O -L timmean -seldate,1981-01-01T00:00:00,1990-12-31T00:00:00 $scratchDIR/mixlayertemp_${SEASON}_1981_2019.nc $scratchDIR/mixlayertemp_${SEASON}_10year_start.nc

    # signal for seasonal average maps (last 5 years)
    cdo -b F64 -O -L timmean -seldate,2010-01-01T00:00:00,2019-12-31T00:00:00 $scratchDIR/mixlayertemp_${SEASON}_1981_2019.nc $scratchDIR/mixlayertemp_${SEASON}_10year_end.nc

    #signal for seasonal average maps (diff)
    cdo -b F64 -O sub $scratchDIR/mixlayertemp_${SEASON}_10year_end.nc $scratchDIR/mixlayertemp_${SEASON}_10year_start.nc $outDIR/signals/era5-land_lakes_mixlayertemp_${SEASON}_signal_1981_2019.nc

    # remove temporary files per season
    rm $scratchDIR/mixlayertemp_${SEASON}_1981_2019.nc
    rm $scratchDIR/mixlayertemp_${SEASON}_10year_end.nc
    rm $scratchDIR/mixlayertemp_${SEASON}_10year_start.nc

done


rm $scratchDIR/mixlayertemp_monthly_1981_2019.nc

