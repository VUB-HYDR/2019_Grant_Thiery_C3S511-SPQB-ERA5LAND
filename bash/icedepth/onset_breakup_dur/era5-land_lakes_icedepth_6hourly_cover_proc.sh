#!/bin/bash -l

# =======================================================================
# SUMMARY
# =======================================================================

# Operations on C3S_511 ice depth files:
    # daily aggregation & file merging
    # calculation of ice start/end/duration and timmeans
    # fldmeans of ice start/end/duration
    # signals between two 10-year means

# =======================================================================
# INITIALIZATION
# =======================================================================

# set output directory
outDIR=/theia/data/brussel/101/vsc10116/C3S_511/era5-land_v2/icedepth/cover

# user scratch directory
scratchDIR=/theia/scratch/projects/climate/users/lgrant/era5-land/proc/icecover

# set mask directory (lakecover)
maskDIR=/theia/scratch/projects/climate/data/dataset/era5-land/lakes/lakecover

# set starting directory
inDIR=/theia/scratch/projects/climate/data/dataset/era5-land/lakes/icedepth

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

    cdo -b F64 -O -L setreftime,1981-01-01,00:00:00,1days -settaxis,$((${YEAR:0:4}+0))-01-01,00:00:00,1days -gtc,0.0001 -daymin era5-land_lakes_icedepth_6hourly_${YEAR}.nc $scratchDIR/startfile_${YEAR}.nc

done

cdo -b F64 mergetime $scratchDIR/startfile_*.nc $scratchDIR/icecover_1981_2019_unmasked.nc

rm $scratchDIR/startfile_*.nc

# mask starting file
cdo ifthen $maskDIR/era5-land_lakemask.nc $scratchDIR/icecover_1981_2019_unmasked.nc $scratchDIR/icecover_daily_1981_2019.nc

rm $scratchDIR/icecover_1981_2019_unmasked.nc

# ==============================================================================
# ICE START
# ==============================================================================

#marker for stderr ice start
echo ' '
echo 'ICE START CALC'
echo ' '


# select October to December for 1st to 2nd-last year
cdo -b F64 -O -L setctomiss,0 -muldoy -selmon,10/12 -seldate,1981-01-01T00:00:00,2019-01-01T00:00:00 $scratchDIR/icecover_daily_1981_2019.nc $scratchDIR/icecover_daily_1981_2019_part1.nc


# select January to September for 2nd to last year (lag by 365)
cdo -b F64 -O -L addc,365 -setctomiss,0 -muldoy -selmon,1/9 -seldate,1982-01-01T00:00:00,2019-12-31T00:00:00 $scratchDIR/icecover_daily_1981_2019.nc $scratchDIR/icecover_daily_1981_2019_part2.nc


# merge selections
cdo -b F64 mergetime $scratchDIR/icecover_daily_1981_2019_part1.nc $scratchDIR/icecover_daily_1981_2019_part2.nc $scratchDIR/dummy_final.nc


rm $scratchDIR/icecover_daily_1981_2019_part*.nc


for i in $(seq 1981 2018); do

    # ice start
    cdo -b F64 -O -L timmin -seldate,$i-10-01T00:00:00,$(($i+1))-09-31T00:00:00 $scratchDIR/dummy_final.nc $scratchDIR/dummy_start_$i.nc

done


rm $scratchDIR/dummy_final.nc


cdo -b F64 -O mergetime $scratchDIR/dummy_start_*.nc $scratchDIR/icecover_start_1981_2019_dummy.nc


rm $scratchDIR/dummy_start_*.nc


cdo -b F64 -O -L setreftime,1981-01-01,00:00:00,1years -settaxis,1981-01-01,00:00:00,1years -setattribute,icestart@long_name='First day of lake ice cover' -setname,'icestart' -setunit,"day of hydrological year" $scratchDIR/icecover_start_1981_2019_dummy.nc $outDIR/era5-land_lakes_icecover_start_1981_2019.nc


# signal (first 10 years)
cdo -b F64 -O -L timmean -seldate,1981-01-01T00:00:00,1990-12-31T00:00:00 $outDIR/era5-land_lakes_icecover_start_1981_2019.nc $scratchDIR/era5-land_lakes_icecover_start_1981_1990_10year.nc


# signal (last 10 years)
cdo -b F64 -O -L timmean -seldate,2010-01-01T00:00:00,2019-12-31T00:00:00 $outDIR/era5-land_lakes_icecover_start_1981_2019.nc $scratchDIR/era5-land_lakes_icecover_start_2010_2019_10year.nc


#signal (diff)
cdo -b F64 -O -L sub $scratchDIR/era5-land_lakes_icecover_start_2010_2019_10year.nc $scratchDIR/era5-land_lakes_icecover_start_1981_1990_10year.nc $outDIR/signals/era5-land_lakes_icecover_start_signals_1981_2019.nc


rm $scratchDIR/era5-land_lakes_icecover_start_1981_1990_10year.nc
rm $scratchDIR/era5-land_lakes_icecover_start_2010_2019_10year.nc
rm $scratchDIR/icecover_start_1981_2019_dummy.nc

# ==============================================================================
# ICE END
# ==============================================================================

#marker for stderr ice end
echo ' '
echo 'ICE END CALC'
echo ' '


# select September to December for 1st to 2nd-last year
cdo -b F64 -O -L setctomiss,0 -muldoy -selmon,9/12 -seldate,1981-01-01T00:00:00,2019-01-01T00:00:00 $scratchDIR/icecover_daily_1981_2019.nc $scratchDIR/icecover_daily_1981_2019_part1.nc


# select January to August for 2nd to last year (lag by 365)
cdo -b F64 -O -L addc,365 -setctomiss,0 -muldoy -selmon,1/8 -seldate,1982-01-01T00:00:00,2019-12-31T00:00:00 $scratchDIR/icecover_daily_1981_2019.nc $scratchDIR/icecover_daily_1981_2019_part2.nc


# merge selections
cdo -b F64 mergetime $scratchDIR/icecover_daily_1981_2019_part1.nc $scratchDIR/icecover_daily_1981_2019_part2.nc $scratchDIR/dummy_final.nc


rm $scratchDIR/icecover_daily_1981_2019_part*.nc


for i in $(seq 1981 2017); do

    # ice end
    cdo -b F64 -O -L timmax -seldate,$i-09-01T00:00:00,$(($i+1))-08-31T00:00:00 $scratchDIR/dummy_final.nc $scratchDIR/dummy_end_$i.nc

done


rm $scratchDIR/dummy_final.nc


cdo -b F64 -O mergetime $scratchDIR/dummy_end_*.nc $scratchDIR/icecover_end_1981_2019_dummy.nc


rm $scratchDIR/dummy_end_*.nc


cdo -b F64 -O -L setreftime,1981-01-01,00:00:00,1years -settaxis,1981-01-01,00:00:00,1years -setattribute,iceend@long_name='Last day of lake ice cover' -setname,'iceend' -setunit,"day of hydrological year" $scratchDIR/icecover_end_1981_2019_dummy.nc $outDIR/era5-land_lakes_icecover_end_1981_2019.nc


# signal (first 5 years)
cdo -b F64 -O -L timmean -seldate,1981-01-01T00:00:00,1990-12-31T00:00:00 $outDIR/era5-land_lakes_icecover_end_1981_2019.nc $scratchDIR/era5-land_lakes_icecover_end_1981_1990_10year.nc


# signal (last 5 years)
cdo -b F64 -O -L timmean -seldate,2010-01-01T00:00:00,2019-12-31T00:00:00 $outDIR/era5-land_lakes_icecover_end_1981_2019.nc $scratchDIR/era5-land_lakes_icecover_end_2010_2019_10year.nc


#signal (diff)
cdo -b F64 -O -L sub $scratchDIR/era5-land_lakes_icecover_end_2010_2019_10year.nc $scratchDIR/era5-land_lakes_icecover_end_1981_1990_10year.nc $outDIR/signals/era5-land_lakes_icecover_end_signal_1981_2019.nc

rm $scratchDIR/era5-land_lakes_icecover_end_1981_1990_10year.nc
rm $scratchDIR/era5-land_lakes_icecover_end_2010_2019_10year.nc
rm $scratchDIR/icecover_end_1981_2019_dummy.nc

# ==============================================================================
# DURATION
# ==============================================================================


#marker for stderr ice dur
echo ' '
echo 'ICE DURATION CALC'
echo ' '


for i in $(seq 1981 2018); do

    # ice duration
    cdo -b F64 -L timsum -seldate,$i-10-01T00:00:00,$(($i+1))-09-31T00:00:00 $scratchDIR/icecover_daily_1981_2019.nc $scratchDIR/dummy_duration_$i.nc

done


cdo -b F64 mergetime $scratchDIR/dummy_duration_*.nc $scratchDIR/icecover_duration_1981_2019_dummy.nc


rm $scratchDIR/dummy_duration_*.nc


cdo -b F64 -O -L setctomiss,0 -setreftime,1981-01-01,00:00:00,1years -settaxis,1981-01-01,00:00:00,1years -setattribute,iceduration@long_name='Days of lake ice cover' -setname,'iceduration' -setunit,"days" $scratchDIR/icecover_duration_1981_2019_dummy.nc $outDIR/era5-land_lakes_icecover_duration_1981_2019.nc


# signal (first 10 years)
cdo -b F64 -O -L timmean -seldate,1981-01-01T00:00:00,1990-12-31T00:00:00 $outDIR/era5-land_lakes_icecover_duration_1981_2019.nc $scratchDIR/era5-land_lakes_icecover_dur_1981_1990_10year.nc


# signal (last 10 years)
cdo -b F64 -O -L timmean -seldate,2010-01-01T00:00:00,2019-12-31T00:00:00 $outDIR/era5-land_lakes_icecover_duration_1981_2019.nc $scratchDIR/era5-land_lakes_icecover_dur_2010_2019_10year.nc


#signal (diff)
cdo -b F64 -O -L sub $scratchDIR/era5-land_lakes_icecover_dur_2010_2019_10year.nc $scratchDIR/era5-land_lakes_icecover_dur_1981_1990_10year.nc $outDIR/signals/era5-land_lakes_icecover_dur_signal_1981_2019.nc


rm $scratchDIR/era5-land_lakes_icecover_dur_1981_1990_10year.nc
rm $scratchDIR/era5-land_lakes_icecover_dur_2010_2019_10year.nc
rm $scratchDIR/icecover_duration_1981_2019_dummy.nc

# ==============================================================================
# GLOBAL MEANS
# ==============================================================================

#ice start fldmeans
cdo -b F64 fldmean $outDIR/era5-land_lakes_icecover_start_1981_2019.nc $outDIR/fldmean/era5-land_lakes_icecover_start_global_fldmean_1981_2019.nc


#ice end fldmeans
cdo -b F64 fldmean $outDIR/era5-land_lakes_icecover_end_1981_2019.nc $outDIR/fldmean/era5-land_lakes_icecover_end_global_fldmean_1981_2019.nc


#ice duration fldmeans
cdo -b F64 fldmean $outDIR/era5-land_lakes_icecover_duration_1981_2019.nc $outDIR/fldmean/era5-land_lakes_icecover_duration_global_fldmean_1981_2019.nc

# ==============================================================================
# TEMPORAL MEANS
# ==============================================================================

#ice start timmeans
cdo -b F64 timmean $outDIR/era5-land_lakes_icecover_start_1981_2019.nc $outDIR/timmean/era5-land_lakes_icecover_start_global_timmean_1981_2019.nc


#ice end timmeans
cdo -b F64 timmean $outDIR/era5-land_lakes_icecover_end_1981_2019.nc $outDIR/timmean/era5-land_lakes_icecover_end_global_timmean_1981_2019.nc


#ice duration timmeans
cdo -b F64 timmean $outDIR/era5-land_lakes_icecover_duration_1981_2019.nc $outDIR/timmean/era5-land_lakes_icecover_duration_global_timmean_1981_2019.nc

# ==============================================================================
# CLEANUP
# ==============================================================================

rm $scratchDIR/icecover_daily_1981_2019.nc
