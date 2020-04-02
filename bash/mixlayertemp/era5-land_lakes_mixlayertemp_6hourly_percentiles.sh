#!/bin/bash -l

# =======================================================================
# SUMMARY
# =======================================================================

# Operations on C3S_511 mixlayertemp files:
    # daily aggregation
    # masking for inland water bodies
    # timmin and max; then percentiles

# =======================================================================
# INITIALIZATION
# =======================================================================

# set output directory
outDIR=/theia/data/brussel/101/vsc10116/C3S_511/era5-land/mixlayertemp

# user scratch directory
scratchDIR=/theia/scratch/projects/climate/users/lgrant/era5-land/proc/mixlayertemp_perc

# set mask directory (lakecover)
maskDIR=/theia/scratch/projects/climate/data/dataset/era5-land/lakes/lakecover

# set starting directory
inDIR=/theia/scratch/projects/climate/data/dataset/era5-land/lakes/mixlayertemp

# years
YEARs=('1981_1985' '1986_1990' '1991_1995' '1996_2000' '2001_2005' '2006_2010' '2011_2015' '2016_2019')

# percentiles
PERCENTs=('1' '5' '10' '50' '90' '95' '99')

# ==============================================================================
# PROCESSING
# ==============================================================================

cd $inDIR
pwd

# ==============================================================================
# DAILY MEANS + MASK
# ==============================================================================

#marker for stderr new beginning
echo ' '
echo 'SCRIPT START'
echo ' '

#TIMERANGEs=('1981_1990' '1991_2000' '2071_2080' '2081_2090' '2091_2099')
#for i in $(seq $((${TIMERANGEs[0]:0:4}+0)) $((${TIMERANGEs[1]:5:4}+0))); do

# prep start file to day res
for YEAR in "${YEARs[@]}"; do

    cdo -b F64 -O -L setreftime,1981-01-01,00:00:00,1days -settaxis,$((${YEAR:0:4}+0))-01-01,00:00:00,1days -daymean era5-land_lakes_mixlayertemp_6hourly_${YEAR}.nc $scratchDIR/startfile_${YEAR}.nc

done

cdo -b F64 mergetime $scratchDIR/startfile_*.nc $scratchDIR/mixlayertemp_1981_2018_unmasked.nc

rm $scratchDIR/startfile_*.nc

# mask starting file
cdo ifthen $maskDIR/era5-land_lakemask.nc $scratchDIR/mixlayertemp_1981_2018_unmasked.nc $scratchDIR/mixlayertemp_daily_1981_2018.nc

rm $scratchDIR/mixlayertemp_1981_2018_unmasked.nc

# ==============================================================================
# PERCENTILE BOUNDS
# ==============================================================================

#marker
echo ' '
echo 'BOUNDS CALC'
echo ' '


cdo timmin $scratchDIR/mixlayertemp_daily_1981_2018.nc $scratchDIR/minfile.nc


cdo timmax $scratchDIR/mixlayertemp_daily_1981_2018.nc $scratchDIR/maxfile.nc

# ==============================================================================
# PERCENTILES
# ==============================================================================

#marker
echo ' '
echo 'PERCENTILES CALC'
echo ' '


for PERC in "${PERCENTs[@]}"; do

    cdo -b F64 -O -L timpctl,$((${PERC}+0)) $scratchDIR/mixlayertemp_daily_1981_2018.nc $scratchDIR/minfile.nc $scratchDIR/maxfile.nc $outDIR/percentiles/era5-land_lakes_mixlayertemp_percentile_${PERC}_1981_2018.nc

    cdo -b F64 -O -L fldmean $outDIR/percentiles/era5-land_lakes_mixlayertemp_percentile_${PERC}.nc $outDIR/percentiles/era5-land_lakes_mixlayertemp_percentile_${PERC}_fldmean_1981_2018.nc

    cdo -b F64 -O -L fldstd $outDIR/percentiles/era5-land_lakes_mixlayertemp_percentile_${PERC}.nc $outDIR/percentiles/era5-land_lakes_mixlayertemp_percentile_${PERC}_fldstd_1981_2018.nc

done


rm $scratchDIR/mixlayertemp_daily_1981_2018.nc
rm $scratchDIR/minfile.nc
rm $scratchDIR/maxfile.nc
