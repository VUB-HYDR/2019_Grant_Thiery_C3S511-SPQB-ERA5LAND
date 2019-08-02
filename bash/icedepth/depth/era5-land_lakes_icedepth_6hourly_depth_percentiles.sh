#!/bin/bash -l

# =======================================================================
# SUMMARY
# =======================================================================

# Operations on C3S_511 ice depth files to calculate percentiles:
    # daily aggregation
    # mask for inland water bodies
    # timmin and max; then percentiles

# =======================================================================
# INITIALIZATION
# =======================================================================

# load CDO
module load CDO

# set output directory
outDIR=/theia/data/brussel/101/vsc10116/C3S_511/era5-land/icedepth/depth

# user scratch directory
scratchDIR=/theia/scratch/projects/climate/users/lgrant

# set mask directory (lakecover)
maskDIR=/theia/scratch/projects/climate/data/dataset/era5-land/lakes/lakecover

# set starting directory
inDIR=/theia/scratch/projects/climate/data/dataset/era5-land/lakes/icedepth

# years
YEARs=('2001_2005' '2006_2007' '2008_2009' '2010_2011' '2012_2013' '2014_2015' '2016_2017' '2018_2019')

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

    cdo -b F64 -O -L setreftime,2001-01-01,00:00:00,1days -settaxis,$((${YEAR:0:4}+0))-01-01,00:00:00,1days -daymean era5-land_lakes_icedepth_6hourly_${YEAR}.nc $scratchDIR/startfile_${YEAR}.nc

done

cdo -b F64 mergetime $scratchDIR/startfile_*.nc $scratchDIR/icedepth_2001_2019_unmasked.nc

rm $scratchDIR/startfile_*.nc

# mask starting file
cdo ifthen $maskDIR/era5-land_lakemask.nc $scratchDIR/icedepth_2001_2019_unmasked.nc $scratchDIR/icedepth_daily_2001_2019.nc

rm $scratchDIR/icedepth_2001_2019_unmasked.nc

# ==============================================================================
# PERCENTILE BOUNDS
# ==============================================================================

#marker
echo ' '
echo 'BOUNDS CALC'
echo ' '


cdo timmin $scratchDIR/icedepth_daily_2001_2019.nc $scratchDIR/minfile.nc


cdo timmax $scratchDIR/icedepth_daily_2001_2019.nc $scratchDIR/maxfile.nc

# ==============================================================================
# PERCENTILES
# ==============================================================================

#marker
echo ' '
echo 'PERCENTILES CALC'
echo ' '


for PERC in "${PERCENTs[@]}"; do

    cdo -b F64 -O -L timpctl,$((${PERC}+0)) $scratchDIR/icedepth_daily_2001_2019.nc $scratchDIR/minfile.nc $scratchDIR/maxfile.nc $outDIR/percentiles/era5-land_lakes_icedepth_percentile_${PERC}.nc

    cdo -b F64 -O -L fldmean $outDIR/percentiles/era5-land_lakes_icedepth_percentile_${PERC}.nc $outDIR/percentiles/era5-land_lakes_icedepth_percentile_${PERC}_fldmean.nc

    cdo -b F64 -O -L fldstd $outDIR/percentiles/era5-land_lakes_icedepth_percentile_${PERC}.nc $outDIR/percentiles/era5-land_lakes_icedepth_percentile_${PERC}_fldstd.nc

done


rm $scratchDIR/icedepth_daily_2001_2019.nc
rm $scratchDIR/minfile.nc
rm $scratchDIR/maxfile.nc
