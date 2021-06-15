#!/bin/bash -l


# =======================================================================
# SUMMARY
# =======================================================================


# 03 2021

# Operations on 6-hourly C3S_511 ice depth files:
    # mask inland water bodies
    # fieldmeans and timmeans on different months
    # signals on different months

    
# =======================================================================
# INITIALIZATION
# =======================================================================


# set output directory
outDIR=/theia/data/brussel/vo/000/bvo00012/vsc10116/era5-land/spqb/03_2021

# user wrk directory
wrkDIR=/theia/data/brussel/vo/000/bvo00012/vsc10116/era5-land/proc/icedepth

# set mask directory (lakecover)
maskDIR=/theia/data/brussel/vo/000/bvo00012/vsc10116/era5-land/lakemask

# directory for monthly series
mkdir -p /theia/data/brussel/vo/000/bvo00012/data/dataset/era5-land/lakes/icedepth/monthly
svDIR=/theia/data/brussel/vo/000/bvo00012/data/dataset/era5-land/lakes/icedepth/monthly

# set starting directory
inDIR=/theia/data/brussel/vo/000/bvo00012/data/dataset/era5-land/lakes/icedepth/daily/settime

# months
months=('JAN' 'FEB' 'MAR' 'APR' 'MAY' 'JUN' 'JUL' 'AUG' 'SEP' 'OCT' 'NOV' 'DEC')

# years
y1=1950
y2=1980

# (len+1) year window for future and baseline periods
len=4


# ==============================================================================
# PROCESSING
# ==============================================================================


cd $inDIR
pwd

#marker for stderr new beginning
echo ' '
echo 'SCRIPT START'
echo ' '

# if [[ ! -e era5-land_lid_daily_${y1}_${y2}.nc && ! -e $svDIR/era5-land_lid_monthly_${y1}_${y2}.nc ]]; then
# 
#     starting file
#     cdo -b F64 -O mergetime era5-land_lid_daily_*.nc era5-land_lid_daily_${y1}_${y2}.nc
#     
#     prep start file to day res
#     cdo -b F64 -O -L setreftime,${y1}-01-01,00:00:00,1months -settaxis,${y1}-01-01,00:00:00,1months -monmean era5-land_lid_daily_${y1}_${y2}.nc $svDIR/era5-land_lid_monthly_${y1}_${y2}.nc
#     
# fi

if [[ ! -e "era5-land_lid_daily_${y1}_${y2}.nc" && ! -e "$svDIR/era5-land_lid_monthly_${y1}_${y2}.nc" ]]; then

    files=()
    for y in $(seq $y1 $y2); do
        for f in era5-land_lid_daily_*.nc; do
            if [[ "$f" == "era5-land_lid_daily_${y}.nc" ]]; then
                files[${#files[@]}]="${f}"
            fi
        done
    done
    
    # starting file
    cdo -b F64 -O \
        mergetime \
        $(echo "${files[@]}") \
        era5-land_lid_daily_${y1}_${y2}.nc
        
    cdo -b F64 -O -L setreftime,${y1}-01-01,00:00:00,1months -settaxis,${y1}-01-01,00:00:00,1months -monmean era5-land_lid_daily_${y1}_${y2}.nc $svDIR/era5-land_lid_monthly_${y1}_${y2}.nc
fi



# ==============================================================================
# TIMMEANS & FLDMEANS
# ==============================================================================


cdo ifthen $maskDIR/era5-land_lc.nc $svDIR/era5-land_lid_monthly_${y1}_${y2}.nc $svDIR/era5-land_lid_monthly_masked_${y1}_${y2}.nc


for i in $(seq 0 11); do

    cdo -b F64 -O -L timmean -selmon,$(($i+1)) $svDIR/era5-land_lid_monthly_${y1}_${y2}.nc $outDIR/era5-land_lakes_icedepth_timmean_${months[$i]}_${y1}_${y2}.nc
    cdo -b F64 -O -L fldmean -selmon,$(($i+1)) $svDIR/era5-land_lid_monthly_masked_${y1}_${y2}.nc $outDIR/era5-land_lakes_icedepth_fldmean_${months[$i]}_${y1}_${y2}.nc

done


# ==============================================================================
# SIGNALS
# ==============================================================================


for i in $(seq 0 11); do

    # signal (first 10 years)
    cdo -b F64 -O -L timmean -selmon,$(($i+1)) -seldate,${y1}-01-01T00:00:00,$(($y1+${len}))-12-31T00:00:00 $svDIR/era5-land_lid_monthly_${y1}_${y2}.nc $wrkDIR/era5-land_lakes_icedepth_${months[$i]}_${y1}_$(($y1+${len}))_10year.nc

    # signal (last 10 years)
    cdo -b F64 -O -L timmean -selmon,$(($i+1)) -seldate,$(($y2-${len}))-01-01T00:00:00,${y2}-12-31T00:00:00 $svDIR/era5-land_lid_monthly_${y1}_${y2}.nc $wrkDIR/era5-land_lakes_icedepth_${months[$i]}_$(($y2-${len}))_${y2}_10year.nc

    #signal (diff)
    cdo -b F64 -O -L sub $wrkDIR/era5-land_lakes_icedepth_${months[$i]}_$(($y2-${len}))_${y2}_10year.nc $wrkDIR/era5-land_lakes_icedepth_${months[$i]}_${y1}_$(($y1+${len}))_10year.nc $outDIR/era5-land_lakes_icedepth_signal_${months[$i]}_${y1}_${y2}.nc

done

