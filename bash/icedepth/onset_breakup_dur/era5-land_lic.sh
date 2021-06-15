#!/bin/bash -l


# =======================================================================
# SUMMARY
# =======================================================================


# 03 2021

# Operations on C3S_511 ice depth files:
    # daily aggregation & file merging
    # calculation of ice start/end/duration and timmeans
    # fldmeans of ice start/end/duration
    # signals between two 10-year means

    
# =======================================================================
# INITIALIZATION
# =======================================================================


# set output directory
outDIR=/theia/data/brussel/vo/000/bvo00012/vsc10116/era5-land/spqb/03_2021

# user scratch directory
wrkDIR=/theia/data/brussel/vo/000/bvo00012/vsc10116/era5-land/proc/icecover

# set mask directory (lakecover)
maskDIR=/theia/data/brussel/vo/000/bvo00012/vsc10116/era5-land/lakemask

# directory for ice_on=1 daily file
icDIR=/theia/data/brussel/vo/000/bvo00012/data/dataset/era5-land/lakes/icecover/daily

# set starting directory
inDIR=/theia/data/brussel/vo/000/bvo00012/data/dataset/era5-land/lakes/icecover/daily

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


# ==============================================================================
# DAILY MEANS + MASK
# ==============================================================================

# if [ ! -e $icDIR/era5-land_lic_daily_${y1}_${y2}.nc ]; then
# 
#     cdo -b F64 mergetime era5-land_lic_daily_*.nc $icDIR/era5-land_lic_daily_${y1}_${y2}.nc
# 
# fi

if [[ ! -e "$icDIR/era5-land_lic_daily_${y1}_${y2}.nc" ]]; then

    files=()
    for y in $(seq $y1 $y2); do
        for f in era5-land_lic_daily_*.nc; do
            if [[ "$f" == "era5-land_lic_daily_${y}.nc" ]]; then
                files[${#files[@]}]="${f}"
            fi
        done
    done
    
    # starting file
    cdo -b F64 -O \
        mergetime \
        $(echo "${files[@]}") \
        era5-land_lic_daily_${y1}_${y2}.nc

    cdo -b F64 -O mergetime era5-land_lic_daily_*.nc $icDIR/era5-land_lic_daily_${y1}_${y2}.nc

fi



# ==============================================================================
# ICE START
# ==============================================================================


# select October to December for 1st to 2nd-last year
cdo -b F64 -O -L setctomiss,0 -muldoy -selmon,10/12 -seldate,$y1-01-01T00:00:00,$y2-01-01T00:00:00 $icDIR/era5-land_lic_daily_${y1}_${y2}.nc $wrkDIR/step3_a.nc
# select January to September for 2nd to last year (lag by 365)
cdo -b F64 -O -L addc,365 -setctomiss,0 -muldoy -selmon,1/9 -seldate,$(($y1+1))-01-01T00:00:00,$y2-12-31T00:00:00 $icDIR/era5-land_lic_daily_${y1}_${y2}.nc $wrkDIR/step3_b.nc
# merge selections
cdo -b F64 mergetime $wrkDIR/step3_a.nc $wrkDIR/step3_b.nc $wrkDIR/step4.nc

rm $wrkDIR/step3_a.nc
rm $wrkDIR/step3_b.nc

for i in $(seq $y1 $(($y2-1))); do

    cdo -b F64 -O -L timmin -seldate,$i-10-01T00:00:00,$(($i+1))-09-31T00:00:00 $wrkDIR/step4.nc $wrkDIR/step4_$i.nc

done

cdo -b F64 -O mergetime $wrkDIR/step4_*.nc $wrkDIR/step5.nc

# set attributes
cdo -b F64 -O -L setreftime,$y1-01-01,00:00:00,1years -settaxis,$y1-01-01,00:00:00,1years -setattribute,icestart@long_name='First day of lake ice cover' -setname,'icestart' -setunit,"day of hydrological year" $wrkDIR/step5.nc $outDIR/era5-land_icestart_${y1}_${y2}.nc

rm $wrkDIR/step4.nc
rm $wrkDIR/step4_*.nc
rm $wrkDIR/step5.nc

# take fldmean
cdo -b F64 -O fldmean $outDIR/era5-land_icestart_${y1}_${y2}.nc $outDIR/era5-land_icestart_fldmean_${y1}_${y2}.nc
# signal (first 10 years)
cdo -b F64 -O -L timmean -seldate,${y1}-01-01T00:00:00,$(($y1+${len}))-12-31T00:00:00 $outDIR/era5-land_icestart_${y1}_${y2}.nc $wrkDIR/era5-land_icestart_${y1}_$(($y1+${len}))_10year.nc
# signal (last 10 years)
cdo -b F64 -O -L timmean -seldate,$(($y2-${len}))-01-01T00:00:00,${y2}-12-31T00:00:00 $outDIR/era5-land_icestart_${y1}_${y2}.nc $wrkDIR/era5-land_icestart_$(($y2-${len}))_${y2}_10year.nc
#signal (diff)
cdo -b F64 -O sub $wrkDIR/era5-land_icestart_$(($y2-${len}))_${y2}_10year.nc $wrkDIR/era5-land_icestart_${y1}_$(($y1+${len}))_10year.nc $outDIR/era5-land_icestart_signals_${y1}_${y2}.nc

# rm $wrkDIR/era5-land_icestart_${y1}_1990_10year.nc
# rm $wrkDIR/era5-land_icestart_2010_${y2}_10year.nc


# ==============================================================================
# ICE END
# ==============================================================================


# select September to December for 1st to 2nd-last year
cdo -b F64 -O -L setctomiss,0 -muldoy -selmon,9/12 -seldate,$y1-01-01T00:00:00,$y2-01-01T00:00:00 $icDIR/era5-land_lic_daily_${y1}_${y2}.nc $wrkDIR/step3_a.nc
# select January to August for 2nd to last year (lag by 365)
cdo -b F64 -O -L addc,365 -setctomiss,0 -muldoy -selmon,1/8 -seldate,$(($y1+1))-01-01T00:00:00,$y2-12-31T00:00:00 $icDIR/era5-land_lic_daily_${y1}_${y2}.nc $wrkDIR/step3_b.nc
# merge selections
cdo -b F64 mergetime $wrkDIR/step3_a.nc $wrkDIR/step3_b.nc $wrkDIR/step4.nc

rm $wrkDIR/step3_a.nc
rm $wrkDIR/step3_b.nc

for i in $(seq $y1 $(($y2-1))); do

    cdo -b F64 -O -L timmax -seldate,$i-09-01T00:00:00,$(($i+1))-08-31T00:00:00 $wrkDIR/step4.nc $wrkDIR/step4_$i.nc

done

cdo -b F64 -O mergetime $wrkDIR/step4_*.nc $wrkDIR/step5.nc

# set attributes
cdo -b F64 -O -L setreftime,$y1-01-01,00:00:00,1years -settaxis,$y1-01-01,00:00:00,1years -setattribute,iceend@long_name='Last day of lake ice cover' -setname,'iceend' -setunit,'day of hydrological year' $wrkDIR/step5.nc $outDIR/era5-land_iceend_${y1}_${y2}.nc

rm $wrkDIR/step4.nc
rm $wrkDIR/step4_*.nc
rm $wrkDIR/step5.nc

# take fldmean
cdo -b F64 -O fldmean $outDIR/era5-land_iceend_${y1}_${y2}.nc $outDIR/era5-land_iceend_fldmean_${y1}_${y2}.nc
# signal (first 10 years)
cdo -b F64 -O -L timmean -seldate,${y1}-01-01T00:00:00,$(($y1+${len}))-12-31T00:00:00 $outDIR/era5-land_iceend_${y1}_${y2}.nc $wrkDIR/era5-land_iceend_${y1}_$(($y1+${len}))_10year.nc
# signal (last 10 years)
cdo -b F64 -O -L timmean -seldate,$(($y2-${len}))-01-01T00:00:00,${y2}-12-31T00:00:00 $outDIR/era5-land_iceend_${y1}_${y2}.nc $wrkDIR/era5-land_iceend_$(($y2-${len}))_${y2}_10year.nc
#signal (diff)
cdo -b F64 -O sub $wrkDIR/era5-land_iceend_$(($y2-${len}))_${y2}_10year.nc $wrkDIR/era5-land_iceend_${y1}_$(($y1+${len}))_10year.nc $outDIR/era5-land_iceend_signals_${y1}_${y2}.nc

# rm $wrkDIR/era5-land_iceend_${y1}_1990_10year.nc
# rm $wrkDIR/era5-land_iceend_2010_${y2}_10year.nc


# ==============================================================================
# DURATION
# ==============================================================================


for i in $(seq $y1 $(($y2-1))); do

    cdo -b F64 -O -L timsum -seldate,$i-10-01T00:00:00,$(($i+1))-09-31T00:00:00 $icDIR/era5-land_lic_daily_${y1}_${y2}.nc $wrkDIR/step4_$i.nc

done

cdo -b F64 -O mergetime $wrkDIR/step4_*.nc $wrkDIR/step5.nc

# set attributes
cdo -b F64 -O -L setreftime,$y1-01-01,00:00:00,1years -settaxis,$y1-01-01,00:00:00,1years -setattribute,icedur@long_name='Duration of lake ice cover (timsum)' -setname,'icedur' -setunit,'days' $wrkDIR/step5.nc $outDIR/era5-land_icedur_${y1}_${y2}.nc

rm $wrkDIR/step4.nc
rm $wrkDIR/step4_*.nc
rm $wrkDIR/step5.nc

# take fldmean
cdo -b F64 fldmean $outDIR/era5-land_icedur_${y1}_${y2}.nc $outDIR/era5-land_icedur_fldmean_${y1}_${y2}.nc
# signal (first 10 years)
cdo -b F64 -O -L timmean -seldate,${y1}-01-01T00:00:00,$(($y1+${len}))-12-31T00:00:00 $outDIR/era5-land_icedur_${y1}_${y2}.nc $wrkDIR/era5-land_icedur_${y1}_$(($y1+${len}))_10year.nc
# signal (last 10 years)
cdo -b F64 -O -L timmean -seldate,$(($y2-${len}))-01-01T00:00:00,${y2}-12-31T00:00:00 $outDIR/era5-land_icedur_${y1}_${y2}.nc $wrkDIR/era5-land_icedur_$(($y2-${len}))_${y2}_10year.nc
#signal (diff)
cdo -b F64 -O sub $wrkDIR/era5-land_icedur_$(($y2-${len}))_${y2}_10year.nc $wrkDIR/era5-land_icedur_${y1}_$(($y1+${len}))_10year.nc $outDIR/era5-land_icedur_signals_${y1}_${y2}.nc


# rm $wrkDIR/era5-land_icedur_${y1}_1990_10year.nc
# rm $wrkDIR/era5-land_icedur_2010_${y2}_10year.nc


# ==============================================================================
# TEMPORAL MEANS
# ==============================================================================


#ice start timmeans
cdo -b F64 timmean $outDIR/era5-land_icestart_${y1}_${y2}.nc $outDIR/era5-land_icestart_timmean_${y1}_${y2}.nc
#ice end timmeans
cdo -b F64 timmean $outDIR/era5-land_iceend_${y1}_${y2}.nc $outDIR/era5-land_iceend_timmean_${y1}_${y2}.nc
#ice duration timmeans
cdo -b F64 timmean $outDIR/era5-land_icedur_${y1}_${y2}.nc $outDIR/era5-land_icedur_timmean_${y1}_${y2}.nc




