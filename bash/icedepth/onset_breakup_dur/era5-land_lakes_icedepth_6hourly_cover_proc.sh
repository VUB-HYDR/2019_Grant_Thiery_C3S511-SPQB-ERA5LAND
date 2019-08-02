#!/bin/bash -l

# =======================================================================
# SUMMARY
# =======================================================================

# Operations on C3S_511 ice depth files:
    # daily aggregation & file merging
    # calculation of ice start/end/duration and timmeans
    # fldmeans of ice start/end/duration
    # signals between two 5-year means

# =======================================================================
# INITIALIZATION
# =======================================================================

# load CDO
module load CDO

# set output directory
outDIR=/theia/data/brussel/101/vsc10116/C3S_511/era5-land/icedepth/cover

# user scratch directory
scratchDIR=/theia/scratch/projects/climate/users/lgrant

# set mask directory (lakecover)
maskDIR=/theia/scratch/projects/climate/data/dataset/era5-land/lakes/lakecover

# set starting directory
inDIR=/theia/scratch/projects/climate/data/dataset/era5-land/lakes/icedepth

# years
YEARs=('2001_2005' '2006_2007' '2008_2009' '2010_2011' '2012_2013' '2014_2015' '2016_2017' '2018_2019')

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

    cdo -b F64 -O -L setreftime,2001-01-01,00:00:00,1days -settaxis,$((${YEAR:0:4}+0))-01-01,00:00:00,1days -gtc,0.0001 -daymin era5-land_lakes_icedepth_6hourly_${YEAR}.nc $scratchDIR/startfile_${YEAR}.nc

done

cdo -b F64 mergetime $scratchDIR/startfile_*.nc $scratchDIR/icecover_2001_2019_unmasked.nc

rm $scratchDIR/startfile_*.nc

# mask starting file
cdo ifthen $maskDIR/era5-land_lakemask.nc $scratchDIR/icecover_2001_2019_unmasked.nc $scratchDIR/icecover_daily_2001_2019.nc

rm $scratchDIR/icecover_2001_2019_unmasked.nc

# ==============================================================================
# ICE START
# ==============================================================================

#marker for stderr ice start
echo ' '
echo 'ICE START CALC'
echo ' '


# select October to December for 1st to 2nd-last year
cdo -b F64 -O -L setctomiss,0 -muldoy -selmon,10/12 -seldate,2001-01-01T00:00:00,2018-01-01T00:00:00 $scratchDIR/icecover_daily_2001_2019.nc $scratchDIR/icecover_daily_2001_2018_part1.nc


# select January to September for 2nd to last year (lag by 365)
cdo -b F64 -O -L addc,365 -setctomiss,0 -muldoy -selmon,1/9 -seldate,2002-01-01T00:00:00,2018-12-31T00:00:00 $scratchDIR/icecover_daily_2001_2019.nc $scratchDIR/icecover_daily_2001_2018_part2.nc


# merge selections
cdo -b F64 mergetime $scratchDIR/icecover_daily_2001_2018_part1.nc $scratchDIR/icecover_daily_2001_2018_part2.nc $scratchDIR/dummy_final.nc


rm $scratchDIR/icecover_daily_2001_2018_part*.nc


for i in $(seq 2001 2017); do

    # ice start
    cdo -b F64 -O -L timmin -seldate,$i-10-01T00:00:00,$(($i+1))-09-31T00:00:00 $scratchDIR/dummy_final.nc $scratchDIR/dummy_start_$i.nc

done


rm $scratchDIR/dummy_final.nc


cdo -b F64 -O mergetime $scratchDIR/dummy_start_*.nc $scratchDIR/icecover_start_2001_2018_dummy.nc


rm $scratchDIR/dummy_start_*.nc


cdo -b F64 -O -L setreftime,2001-01-01,00:00:00,1years -settaxis,2001-01-01,00:00:00,1years -setattribute,icestart@long_name='First day of lake ice cover' -setname,'icestart' -setunit,"day of hydrological year" $scratchDIR/icecover_start_2001_2018_dummy.nc $outDIR/era5-land_lakes_icecover_start_2001_2018.nc


# signal (first 5 years)
cdo -b F64 -O -L timmean -seldate,2001-01-01T00:00:00,2005-12-31T00:00:00 $outDIR/era5-land_lakes_icecover_start_2001_2018.nc $scratchDIR/era5-land_lakes_icecover_start_2001_2005_5year.nc


# signal (last 5 years)
cdo -b F64 -O -L timmean -seldate,2014-01-01T00:00:00,2018-12-31T00:00:00 $outDIR/era5-land_lakes_icecover_start_2001_2018.nc $scratchDIR/era5-land_lakes_icecover_start_2014_2018_5year.nc


#signal (diff)
cdo -b F64 -O -L sub $scratchDIR/era5-land_lakes_icecover_start_2014_2018_5year.nc $scratchDIR/era5-land_lakes_icecover_start_2001_2005_5year.nc $outDIR/signals/era5-land_lakes_icecover_start_signals_2001_2018.nc


rm $scratchDIR/era5-land_lakes_icecover_start_2001_2005_5year.nc
rm $scratchDIR/era5-land_lakes_icecover_start_2014_2018_5year.nc
rm $scratchDIR/icecover_start_2001_2018_dummy.nc

# ==============================================================================
# ICE END
# ==============================================================================

#marker for stderr ice end
echo ' '
echo 'ICE END CALC'
echo ' '


# select September to December for 1st to 2nd-last year
cdo -b F64 -O -L setctomiss,0 -muldoy -selmon,9/12 -seldate,2001-01-01T00:00:00,2018-01-01T00:00:00 $scratchDIR/icecover_daily_2001_2019.nc $scratchDIR/icecover_daily_2001_2018_part1.nc


# select January to August for 2nd to last year (lag by 365)
cdo -b F64 -O -L addc,365 -setctomiss,0 -muldoy -selmon,1/8 -seldate,2002-01-01T00:00:00,2018-12-31T00:00:00 $scratchDIR/icecover_daily_2001_2019.nc $scratchDIR/icecover_daily_2001_2018_part2.nc


# merge selections
cdo -b F64 mergetime $scratchDIR/icecover_daily_2001_2018_part1.nc $scratchDIR/icecover_daily_2001_2018_part2.nc $scratchDIR/dummy_final.nc


rm $scratchDIR/icecover_daily_2001_2018_part*.nc


for i in $(seq 2001 2017); do

    # ice start
    cdo -b F64 -O -L timmax -seldate,$i-09-01T00:00:00,$(($i+1))-08-31T00:00:00 $scratchDIR/dummy_final.nc $scratchDIR/dummy_end_$i.nc

done


rm $scratchDIR/dummy_final.nc


cdo -b F64 -O mergetime $scratchDIR/dummy_end_*.nc $scratchDIR/icecover_end_2001_2018_dummy.nc


rm $scratchDIR/dummy_end_*.nc


cdo -b F64 -O -L setreftime,2001-01-01,00:00:00,1years -settaxis,2001-01-01,00:00:00,1years -setattribute,iceend@long_name='Last day of lake ice cover' -setname,'iceend' -setunit,"day of hydrological year" $scratchDIR/icecover_end_2001_2018_dummy.nc $outDIR/era5-land_lakes_icecover_end_2001_2018.nc


# signal (first 5 years)
cdo -b F64 -O -L timmean -seldate,2001-01-01T00:00:00,2005-12-31T00:00:00 $outDIR/era5-land_lakes_icecover_end_2001_2018.nc $scratchDIR/era5-land_lakes_icecover_end_2001_2005_5year.nc


# signal (last 5 years)
cdo -b F64 -O -L timmean -seldate,2014-01-01T00:00:00,2018-12-31T00:00:00 $outDIR/era5-land_lakes_icecover_end_2001_2018.nc $scratchDIR/era5-land_lakes_icecover_end_2014_2018_5year.nc


#signal (diff)
cdo -b F64 -O -L sub $scratchDIR/era5-land_lakes_icecover_end_2014_2018_5year.nc $scratchDIR/era5-land_lakes_icecover_end_2001_2005_5year.nc $outDIR/signals/era5-land_lakes_icecover_end_signal_2001_2018.nc

rm $scratchDIR/era5-land_lakes_icecover_end_2001_2005_5year.nc
rm $scratchDIR/era5-land_lakes_icecover_end_2014_2018_5year.nc
rm $scratchDIR/icecover_end_2001_2018_dummy.nc

# ==============================================================================
# DURATION
# ==============================================================================


#marker for stderr ice dur
echo ' '
echo 'ICE DURATION CALC'
echo ' '


for i in $(seq 2001 2017); do

    # ice duration
    cdo -b F64 -L timsum -seldate,$i-10-01T00:00:00,$(($i+1))-09-31T00:00:00 $scratchDIR/icecover_daily_2001_2019.nc $scratchDIR/dummy_duration_$i.nc

done


cdo -b F64 mergetime $scratchDIR/dummy_duration_*.nc $scratchDIR/icecover_duration_2001_2018_dummy.nc


rm $scratchDIR/dummy_duration_*.nc


cdo -b F64 -O -L setctomiss,0 -setreftime,2001-01-01,00:00:00,1years -settaxis,2001-01-01,00:00:00,1years -setattribute,iceduration@long_name='Days of lake ice cover' -setname,'iceduration' -setunit,"days" $scratchDIR/icecover_duration_2001_2018_dummy.nc $outDIR/era5-land_lakes_icecover_duration_2001_2018.nc


# signal (first 5 years)
cdo -b F64 -O -L timmean -seldate,2001-01-01T00:00:00,2005-12-31T00:00:00 $outDIR/era5-land_lakes_icecover_duration_2001_2018.nc $scratchDIR/era5-land_lakes_icecover_dur_2001_2005_5year.nc


# signal (last 5 years)
cdo -b F64 -O -L timmean -seldate,2014-01-01T00:00:00,2018-12-31T00:00:00 $outDIR/era5-land_lakes_icecover_duration_2001_2018.nc $scratchDIR/era5-land_lakes_icecover_dur_2014_2018_5year.nc


#signal (diff)
cdo -b F64 -O -L sub $scratchDIR/era5-land_lakes_icecover_dur_2014_2018_5year.nc $scratchDIR/era5-land_lakes_icecover_dur_2001_2005_5year.nc $outDIR/signals/era5-land_lakes_icecover_dur_signal_2001_2018.nc


rm $scratchDIR/era5-land_lakes_icecover_dur_2001_2005_5year.nc
rm $scratchDIR/era5-land_lakes_icecover_dur_2014_2018_5year.nc
rm $scratchDIR/icecover_duration_2001_2018_dummy.nc

# ==============================================================================
# GLOBAL MEANS
# ==============================================================================

#ice start fldmeans
cdo -b F64 fldmean $outDIR/era5-land_lakes_icecover_start_2001_2018.nc $outDIR/fldmean/era5-land_lakes_icecover_start_global_fldmean_2001_2018.nc


#ice end fldmeans
cdo -b F64 fldmean $outDIR/era5-land_lakes_icecover_end_2001_2018.nc $outDIR/fldmean/era5-land_lakes_icecover_end_global_fldmean_2001_2018.nc


#ice duration fldmeans
cdo -b F64 fldmean $outDIR/era5-land_lakes_icecover_duration_2001_2018.nc $outDIR/fldmean/era5-land_lakes_icecover_duration_global_fldmean_2001_2018.nc

# ==============================================================================
# TEMPORAL MEANS
# ==============================================================================

#ice start timmeans
cdo -b F64 timmean $outDIR/era5-land_lakes_icecover_start_2001_2018.nc $outDIR/timmean/era5-land_lakes_icecover_start_global_timmean_2001_2018.nc


#ice end timmeans
cdo -b F64 timmean $outDIR/era5-land_lakes_icecover_end_2001_2018.nc $outDIR/timmean/era5-land_lakes_icecover_end_global_timmean_2001_2018.nc


#ice duration timmeans
cdo -b F64 timmean $outDIR/era5-land_lakes_icecover_duration_2001_2018.nc $outDIR/timmean/era5-land_lakes_icecover_duration_global_timmean_2001_2018.nc

# ==============================================================================
# CLEANUP
# ==============================================================================

rm $scratchDIR/icecover_daily_2001_2019.nc
