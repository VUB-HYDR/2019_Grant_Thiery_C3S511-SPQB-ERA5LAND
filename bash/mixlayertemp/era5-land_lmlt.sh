#!/bin/bash -l

# =======================================================================
# SUMMARY
# =======================================================================


# March 04 2021

# Operations on ERA5 mixed layer temperature files:
    # masking for inland water bodies
    # selection of seasonal averages: 1) temporal average (spatial plots per season) and 2) global/annual means (time series per season)
    # global/annual means on monthly series for time series
    # seasonal signals (between two 5-year means)

    
# =======================================================================
# INITIALIZATION
# =======================================================================


# set output directory
outDIR=/theia/data/brussel/vo/000/bvo00012/vsc10116/era5-land/spqb/03_2021

# user scratch directory
wrkDIR=/theia/data/brussel/vo/000/bvo00012/vsc10116/era5-land/proc/mixlayertemp

# set mask directory (lakecover)
maskDIR=/theia/data/brussel/vo/000/bvo00012/vsc10116/era5-land/lakemask

# set starting directory
inDIR=/theia/data/brussel/vo/000/bvo00012/data/dataset/era5-land/lakes/mixlayertemp/monthly

# seasons
seasons=('DJF' 'MAM' 'JJA' 'SON')

# years
y1=1981
y2=2020

# (len+1) year window for future and baseline periods
len=9


# ==============================================================================
# PROCESSING
# ==============================================================================

cd $inDIR
pwd

# if [ ! -e era5-land_lmlt_monthly_${y1}_${y2}.nc ]; then
# 
#     cdo -b F64 mergetime era5-land_lmlt_monthly_*.nc era5-land_lmlt_monthly_${y1}_${y2}.nc
# 
# fi

if [[ ! -e "era5-land_lmlt_monthly_${y1}_${y2}.nc" ]]; then

    files=()
    for y in $(seq $y1 $y2); do
        for f in era5-land_lmlt_monthly_*.nc; do
            if [[ "$f" == "era5-land_lmlt_monthly_${y}.nc" ]]; then
                files[${#files[@]}]="${f}"
            fi
        done
    done

    # merge files for m
    cdo -b F64 -O \
        mergetime \
        $(echo "${files[@]}") \
        "era5-land_lmlt_monthly_${y1}_${y2}.nc"
fi

cdo ifthen $maskDIR/era5-land_lakes_lc.nc era5-land_lmlt_monthly_${y1}_${y2}.nc era5-land_lmlt_monthly_masked_${y1}_${y2}.nc

# seasonal files to operate on
cdo -b F64 -O -L yearmean -selmon,12,1,2 era5-land_lmlt_monthly_masked_${y1}_${y2}.nc $wrkDIR/lmlt_DJF_${y1}_${y2}.nc
cdo -b F64 -O -L yearmean -selmon,3/5 era5-land_lmlt_monthly_masked_${y1}_${y2}.nc $wrkDIR/lmlt_MAM_${y1}_${y2}.nc
cdo -b F64 -O -L yearmean -selmon,6/8 era5-land_lmlt_monthly_masked_${y1}_${y2}.nc $wrkDIR/lmlt_JJA_${y1}_${y2}.nc
cdo -b F64 -O -L yearmean -selmon,9/11 era5-land_lmlt_monthly_masked_${y1}_${y2}.nc $wrkDIR/lmlt_SON_${y1}_${y2}.nc


# global annual mean time series
cdo -b F64 -O -L fldmean -yearmonmean era5-land_lmlt_monthly_masked_${y1}_${y2}.nc $outDIR/era5-land_lmlt_global_annual_fldmean_${y1}_${y2}.nc


for season in "${seasons[@]}"; do

    # global mean time series for seasons
    cdo -b F64 -O fldmean $wrkDIR/lmlt_${season}_${y1}_${y2}.nc $outDIR/era5-land_lmlt_${season}_global_fldmean_${y1}_${y2}_v2.nc

    temporal mean for seasonal average maps
    cdo -b F64 -O timmean $wrkDIR/lmlt_${season}_${y1}_${y2}.nc $outDIR/era5-land_lmlt_${season}_timmean_${y1}_${y2}.nc

    signal for seasonal average maps (first "len+1" years)
    cdo -b F64 -O -L timmean -seldate,${y1}-01-01T00:00:00,$(($y1+${len}))-12-31T00:00:00 $wrkDIR/lmlt_${season}_${y1}_${y2}.nc $wrkDIR/lmlt_${season}_10year_start.nc

    signal for seasonal average maps (last "len+1" years)
    cdo -b F64 -O -L timmean -seldate,$(($y2-${len}))-01-01T00:00:00,${y2}-12-31T00:00:00 $wrkDIR/lmlt_${season}_${y1}_${y2}.nc $wrkDIR/lmlt_${season}_10year_end.nc

    signal for seasonal average maps (diff)
    cdo -b F64 -O -L sub $wrkDIR/lmlt_${season}_10year_end.nc $wrkDIR/lmlt_${season}_10year_start.nc $outDIR/era5-land_lmlt_${season}_signal_${y1}_${y2}.nc

#     remove temporary files per season
#     rm $wrkDIR/lmlt_${season}_10year_end.nc
#     rm $wrkDIR/lmlt_${season}_10year_start.nc

done


