#!/bin/bash -l

# =======================================================================
# SUMMARY
# =======================================================================


# 03 2021

# Operations on C3S_511 ice depth files to calculate percentiles:
    # daily aggregation
    # mask for inland water bodies
    # timmin and max; then percentiles

    
# =======================================================================
# INITIALIZATION
# =======================================================================


# set output directory
outDIR=/theia/data/brussel/vo/000/bvo00012/vsc10116/era5-land/spqb/03_2021

# user wrk directory
wrkDIR=/theia/data/brussel/vo/000/bvo00012/vsc10116/era5-land/proc/icedepth/percentile

# set mask directory (lakecover)
maskDIR=/theia/data/brussel/vo/000/bvo00012/vsc10116/era5-land/lakemask

# set starting directory
inDIR=/theia/data/brussel/vo/000/bvo00012/data/dataset/era5-land/lakes/icedepth/daily/settime
svDIR=/theia/data/brussel/vo/000/bvo00012/data/dataset/era5-land/lakes/icedepth/daily/settime

# percentiles
percents=('1' '5' '10' '50' '90' '95' '99')

# years
y1=1950
y2=1980


# ==============================================================================
# PROCESSING
# ==============================================================================


cd $inDIR
pwd

# if [ ! -e $svDIR/era5-land_lid_daily_${y1}_${y2}.nc ]; then
# 
#     starting file
#     cdo -b F64 mergetime era5-land_lid_daily_*.nc $svDIR/era5-land_lid_daily_${y1}_${y2}.nc;
#     
# fi

if [[ ! -e "$svDIR/era5-land_lid_daily_${y1}_${y2}.nc" ]]; then

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

    # starting file
    cdo -b F64 mergetime era5-land_lid_daily_*.nc "$svDIR/era5-land_lid_daily_${y1}_${y2}.nc";
    
fi

# bounds
cdo timmin $svDIR/era5-land_lid_daily_${y1}_${y2}.nc $wrkDIR/minfile.nc;
cdo timmax $svDIR/era5-land_lid_daily_${y1}_${y2}.nc $wrkDIR/maxfile.nc;


# ==============================================================================
# PERCENTILES
# ==============================================================================


for perc in "${percents[@]}"; do

    cdo -b F64 -O -L timpctl,$((${perc}+0)) $svDIR/era5-land_lid_daily_${y1}_${y2}.nc $wrkDIR/minfile.nc $wrkDIR/maxfile.nc $outDIR/era5-land_lid_percentile_${perc}_${y1}_${y2}.nc;

done

