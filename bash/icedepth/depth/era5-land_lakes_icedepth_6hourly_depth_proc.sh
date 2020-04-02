#!/bin/bash -l

# =======================================================================
# SUMMARY
# =======================================================================

# Operations on 6-hourly C3S_511 ice depth files:
    # mask inland water bodies
    # fieldmeans and timmeans on different months
    # signals on different months

# =======================================================================
# INITIALIZATION
# =======================================================================

# set output directory
outDIR=/theia/data/brussel/101/vsc10116/C3S_511/era5-land/icedepth/depth

# user scratch directory
scratchDIR=/theia/scratch/projects/climate/users/lgrant/era5-land/proc/icedepth

# set mask directory (lakecover)
maskDIR=/theia/scratch/projects/climate/data/dataset/era5-land/lakes/lakecover

# set starting directory
inDIR=/theia/scratch/projects/climate/data/dataset/era5-land/lakes/icedepth

# months
MONTHs=('JAN' 'FEB' 'MAR' 'APR' 'MAY' 'JUN' 'JUL' 'AUG' 'SEP' 'OCT' 'NOV' 'DEC')

# years
YEARs=('1981_1982' '1983_1984' '1985_1986' '1987_1988' '1989_1990' '1991_1992' '1993_1994' '1995_1996' '1997_1998' '1999_2000' '2001_2005' '2006_2007' '2008_2009' '2010_2011' '2012_2013' '2014_2015' '2016_2017' '2018_2019')

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

    cdo -b F64 -O -L setreftime,1981-01-01,00:00:00,1months -settaxis,$((${YEAR:0:4}+0))-01-01,00:00:00,1months -monmean era5-land_lakes_icedepth_6hourly_${YEAR}.nc $scratchDIR/startfile_${YEAR}.nc

done

cdo -b F64 mergetime $scratchDIR/startfile_*.nc $scratchDIR/icedepth_1981_2018_unmasked.nc

rm $scratchDIR/startfile_*.nc

# mask starting file
cdo ifthen $maskDIR/era5-land_lakemask.nc $scratchDIR/icedepth_1981_2018_unmasked.nc $scratchDIR/icedepth_monthly_1981_2018.nc

rm $scratchDIR/icedepth_1981_2018_unmasked.nc

# ==============================================================================
# TIMMEANS & FLDMEANS
# ==============================================================================

#marker
echo ' '
echo 'TIMMEANS CALC'
echo ' '


for i in $(seq 0 11); do

    cdo -b F64 -O -L timmean -selmon,$(($i+1)) -seldate,1981-01-01T00:00:00,2018-12-31T00:00:00 $scratchDIR/icedepth_monthly_1981_2018.nc $outDIR/timmean/era5-land_lakes_icedepth_timmean_${MONTHs[$i]}_1981_2018.nc

done


#marker
echo ' '
echo 'FLDMEANS CALC'
echo ' '


for i in $(seq 0 11); do

    cdo -b F64 -O -L fldmean -selmon,$(($i+1)) -seldate,1981-01-01T00:00:00,2018-12-31T00:00:00 $scratchDIR/icedepth_monthly_1981_2018.nc $outDIR/fldmean/era5-land_lakes_icedepth_fldmean_${MONTHs[$i]}_1981_2018.nc

done

# ==============================================================================
# SIGNALS
# ==============================================================================

#marker
echo ' '
echo 'SIGNALS CALC'
echo ' '


for i in $(seq 0 11); do

    # signal (first 5 years)
    cdo -b F64 -O -L timmean -seldate,1981-01-01T00:00:00,1990-12-31T00:00:00 -selmon,$(($i+1)) $scratchDIR/icedepth_monthly_1981_2018.nc $scratchDIR/era5-land_lakes_icedepth_${MONTHs[$i]}_1981_1990_10year.nc

    # signal (last 5 years)
    cdo -b F64 -O -L timmean -seldate,2009-01-01T00:00:00,2018-12-31T00:00:00 -selmon,$(($i+1)) $scratchDIR/icedepth_monthly_1981_2018.nc $scratchDIR/era5-land_lakes_icedepth_${MONTHs[$i]}_2009_2018_10year.nc

    #signal (diff)
    cdo -b F64 -O -L sub $scratchDIR/era5-land_lakes_icedepth_${MONTHs[$i]}_2009_2018_10year.nc $scratchDIR/era5-land_lakes_icedepth_${MONTHs[$i]}_1981_1990_10year.nc $outDIR/signals/era5-land_lakes_icedepth_signal_${MONTHs[$i]}_1981_2018.nc

done

rm $scratchDIR/era5-land_lakes*.nc

rm $scratchDIR/icedepth_monthly_1981_2018.nc
