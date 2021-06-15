#!/bin/bash -l


# =======================================================================
# SUMMARY
# =======================================================================


# April 6th

# Operations on ERA5 mixlayertemp files:
    # daily aggregation
    # masking for inland water bodies
    # timmin and max; then percentiles

    
# =======================================================================
# INITIALIZATION
# =======================================================================


# set output directory
outDIR=/theia/data/brussel/vo/000/bvo00012/vsc10116/era5-land/spqb/03_2021

# user scratch directory
mkdir -p /theia/data/brussel/vo/000/bvo00012/vsc10116/era5-land/proc/mixlayertemp/percentile
wrkDIR=/theia/data/brussel/vo/000/bvo00012/vsc10116/era5-land/proc/mixlayertemp/percentile

# set mask directory (lakecover)
maskDIR=/theia/data/brussel/vo/000/bvo00012/vsc10116/era5-land/lakemask

# set starting directory
inDIR=/theia/data/brussel/vo/000/bvo00012/data/dataset/era5-land/lakes/mixlayertemp/daily

# years
y1=1981
y2=2020

# percents
percents=('1' '5' '10' '50' '90' '95' '99')


# ==============================================================================
# PROCESSING
# ==============================================================================


cd $inDIR
pwd

# if [ ! -e era5-land_lmlt_daily_${y1}_${y2}.nc ]; then
# 
#     cdo -b F64 mergetime era5-land_lmlt_daily_*.nc era5-land_lmlt_daily_${y1}_${y2}.nc
# 
# fi

if [[ ! -e "era5-land_lmlt_daily_${y1}_${y2}.nc" ]]; then

    files=()
    for y in $(seq $y1 $y2); do
        for f in era5-land_lmlt_daily_*.nc; do
            if [[ "$f" == era5-land_lmlt_daily_${y}.nc ]]; then
                files[${#files[@]}]="${f}"
            fi
        done
    done

    # starting file
    cdo -b F64 -O \
        mergetime \
        $(echo "${files[@]}") \
        era5-land_lmlt_daily_${y1}_${y2}.nc
fi


# ==============================================================================
# PERCENTILE BOUNDS
# ==============================================================================


cdo timmin era5-land_lmlt_daily_${y1}_${y2}.nc $wrkDIR/minfile.nc
cdo timmax era5-land_lmlt_daily_${y1}_${y2}.nc $wrkDIR/maxfile.nc


# ==============================================================================
# PERCENTILES
# ==============================================================================



for perc in "${percents[@]}"; do

    cdo -b F64 -O -L timpctl,$((${perc}+0)) era5-land_lmlt_daily_${y1}_${y2}.nc $wrkDIR/minfile.nc $wrkDIR/maxfile.nc $outDIR/era5-land_lakes_mixlayertemp_percentile_${perc}.nc

done

# rm $wrkDIR/minfile.nc
# rm $wrkDIR/maxfile.nc
