#!/bin/bash
# This script will create a .tar.gz file containing the data and put it on a sensible web-location for downloading.
# Written by Chris Brierley and only to be used by Chris.

#first define a litte function to say whether a netcdf file has required variables
# define a function to test whether the contents of the netcdf file is a regular lat,lon) file
function hasENSOvars {
  hasENSOvars_DIR=$1
  hasENSOvars_filename=$2
  hasENSOvars_nino34_vars=`ncdump -h $hasENSOvars_DIR/$hasENSOvars_filename | grep float | grep nino34 | cut -d\( -f1 | cut -d\  -f2`
  if [[ $hasENSOvars_nino34_vars == *"nino34_spacomp_pr_djf1"* ]] && [[ $hasENSOvars_nino34_vars == *"nino34_spacomp_tas_djf1"* ]] && [[ $hasENSOvars_nino34_vars == *"nino34_spacomp_sst_djf1"* ]]
  then
    return 1
  else
    return 0
  fi
}  

function hasPPTvars {
  hasPPTvars_DIR=$1
  hasPPTvars_filename=$2
  hasPPTvars_nino34_vars=`ncdump -h $hasPPTvars_DIR/$hasPPTvars_filename | grep float | grep nino34 | cut -d\( -f1 | cut -d\  -f2`
  if [[ $hasPPTvars_nino34_vars == *"nino34_spacomp_elnino_ppt_djf1"* ]]; then
    return 1
  else
    return 0
  fi
}  

function hasPRvars {
  hasPRvars_DIR=$1
  hasPRvars_filename=$2
  hasPRvars_nino34_vars=`ncdump -h $hasPRvars_DIR/$hasPRvars_filename | grep float | grep nino34 | cut -d\( -f1 | cut -d\  -f2`
  if [[ $hasPRvars_nino34_vars == *"nino34_spacomp_elnino_pr_djf1"* ]]; then
    return 1
  else
    return 0
  fi
}  

CVDP_DATA_DIR="/home/p2f-v/public_html/PMIPVarData/cvdp_data"
REPO_DATA_DIR=`pwd`"/../data" #relative to here
nino_vars="nino12,nino3,nino34,nino34_autocorrelation,nino34_hov_elnino,nino34_hov_lanina,nino34_monthly_stddev,nino34_runstddev,nino34_spectra,nino34_wavelet_power,nino34_wavelet_significance,nino4,nino34_spacomp_pr_djf1,nino34_spacomp_pr_jja0,nino34_spacomp_pr_mam1,nino34_spacomp_pr_son0,nino34_spacomp_sst_djf1,nino34_spacomp_sst_jja0,nino34_spacomp_sst_mam1,nino34_spacomp_sst_son0,nino34_spacomp_tas_djf1,nino34_spacomp_tas_jja0,nino34_spacomp_tas_mam1,nino34_spacomp_tas_son0"
nino_extra_vars="nino34_spacomp_elnino_pr_son0,nino34_spacomp_elnino_sst_djf1,nino34_spacomp_elnino_sst_jja0,nino34_spacomp_elnino_sst_mam1,nino34_spacomp_elnino_sst_son0,nino34_spacomp_elnino_tas_djf1,nino34_spacomp_elnino_tas_jja0,nino34_spacomp_elnino_tas_mam1,nino34_spacomp_elnino_tas_son0,nino34_spacomp_lanina_pr_djf1,nino34_spacomp_lanina_pr_jja0,nino34_spacomp_lanina_pr_mam1,nino34_spacomp_lanina_pr_son0,nino34_spacomp_lanina_sst_djf1,nino34_spacomp_lanina_sst_jja0,nino34_spacomp_lanina_sst_mam1,nino34_spacomp_lanina_sst_son0,nino34_spacomp_lanina_tas_djf1,nino34_spacomp_lanina_tas_jja0,nino34_spacomp_lanina_tas_mam1,nino34_spacomp_lanina_tas_son0"
mean_vars="pr_spatialmean_ann,pr_spatialmean_djf,pr_spatialmean_jja,pr_spatialmean_mam,pr_spatialmean_son,pr_spatialstddev_ann,pr_spatialstddev_djf,pr_spatialstddev_jja,pr_spatialstddev_mam,pr_spatialstddev_son,sst_spatialmean_ann,sst_spatialmean_djf,sst_spatialmean_jja,sst_spatialmean_mam,sst_spatialmean_son,sst_spatialstddev_ann,sst_spatialstddev_djf,sst_spatialstddev_jja,sst_spatialstddev_mam,sst_spatialstddev_son,tas_spatialmean_ann,tas_spatialmean_djf,tas_spatialmean_jja,tas_spatialmean_mam,tas_spatialmean_son,tas_spatialstddev_ann,tas_spatialstddev_djf,tas_spatialstddev_jja,tas_spatialstddev_mam,tas_spatialstddev_son"

cd $CVDP_DATA_DIR
ncfiles=`ls *{piControl,historical,midHolocene-cal-adj,lgm-cal-adj,lig127k-cal-adj,1pctCO2,abrupt4xCO2}.cvdp_data.*-*.nc`
echo $ncfiles
cd $REPO_DATA_DIR
for ncfile in $ncfiles
do
  echo working on $ncfile
  hasENSOvars $CVDP_DATA_DIR $ncfile
  if [ $? == 1 ]; then
    ncks -O -v $nino_vars $CVDP_DATA_DIR/$ncfile $ncfile
    ncap2 -A -s 'nino34_spacomp_sst_ann=0.25f*(nino34_spacomp_sst_jja0+nino34_spacomp_sst_son0+nino34_spacomp_sst_djf1+nino34_spacomp_sst_mam1)' $ncfile $ncfile
    ncks -A -v $mean_vars $CVDP_DATA_DIR/$ncfile $ncfile
    hasPPTvars $CVDP_DATA_DIR $ncfile
    if [ $? == 1 ]; then
      echo "hasPPTvars"
      cp $CVDP_DATA_DIR/$ncfile tmp_$ncfile
      #ncrename -O -v nino34_spacomp_elnino_ppt_djf1,nino34_spacomp_elnino_pr_djf1 -v nino34_spacomp_elnino_ppt_jja0,nino34_spacomp_elnino_pr_jja0 -v nino34_spacomp_elnino_ppt_mam1,nino34_spacomp_elnino_pr_mam1 -v nino34_spacomp_elnino_ppt_son0,nino34_spacomp_elnino_pr_son0 -v nino34_spacomp_lanina_ppt_djf1,nino34_spacomp_lanina_pr_djf1 -v nino34_spacomp_lanina_ppt_jja0,nino34_spacomp_lanina_pr_jja0 -v nino34_spacomp_lanina_ppt_mam1,nino34_spacomp_lanina_pr_mam1 -v nino34_spacomp_lanina_ppt_son0,nino34_spacomp_lanina_pr_son0 tmp_$ncfile      
      ncks -A -v $nino_extra_vars tmp_$ncfile $ncfile
      rm tmp_$ncfile
    else
      hasPRvars $CVDP_DATA_DIR $ncfile
      if [ $? == 1 ]; then
        ncks -A -v $nino_extra_vars $CVDP_DATA_DIR/$ncfile $ncfile
      else
        echo "Missing lanina and elnino spatial composites"
      fi
    fi
  fi 
done
rename cvdp_data cvdp_enso *.nc
#plus a couple of obs datasets
ncks -O -v pr_spatialmean_ann,pr_spatialmean_djf,pr_spatialmean_jja,pr_spatialmean_mam,pr_spatialmean_son,\
pr_spatialstddev_ann,pr_spatialstddev_djf,pr_spatialstddev_jja,pr_spatialstddev_mam,pr_spatialstddev_son \
  $CVDP_DATA_DIR/GPCP.cvdp_data.1979-2019.nc GPCP.cvdp_enso.1979-2019.nc

ncks -O -v sst_spatialmean_ann,sst_spatialmean_djf,sst_spatialmean_jja,sst_spatialmean_mam,sst_spatialmean_son,\
sst_spatialstddev_ann,sst_spatialstddev_djf,sst_spatialstddev_jja,sst_spatialstddev_mam,sst_spatialstddev_son,\
nino12,nino3,nino34,nino34_autocorrelation,nino34_hov_elnino,nino34_hov_lanina,nino34_monthly_stddev,nino34_runstddev,\
nino34_spectra,nino34_wavelet_power,nino34_wavelet_significance,nino4 \
  $CVDP_DATA_DIR/HadISST.cvdp_data.1870-2016.nc HadISST.cvdp_enso.1870-2016.nc
ncks -A -v nino34_spacomp_sst_djf1,nino34_spacomp_sst_jja0,nino34_spacomp_sst_mam1,nino34_spacomp_sst_son0 \
  $CVDP_DATA_DIR/C20-Reanalysis.cvdp_data.1871-2012.nc HadISST.cvdp_enso.1870-2016.nc
ncap2 -A -s 'nino34_spacomp_sst_ann=0.25f*(nino34_spacomp_sst_jja0+nino34_spacomp_sst_son0+nino34_spacomp_sst_djf1+nino34_spacomp_sst_mam1)' \
  HadISST.cvdp_enso.1870-2016.nc HadISST.cvdp_enso.1870-2016.nc

ncks -O -v sst_spatialmean_ann,sst_spatialmean_djf,sst_spatialmean_jja,sst_spatialmean_mam,sst_spatialmean_son,\
sst_spatialstddev_ann,sst_spatialstddev_djf,sst_spatialstddev_jja,sst_spatialstddev_mam,sst_spatialstddev_son,\
nino12,nino3,nino34,nino34_autocorrelation,nino34_hov_elnino,nino34_hov_lanina,nino34_monthly_stddev,nino34_runstddev,\
nino34_spacomp_pr_djf1,nino34_spacomp_pr_jja0,nino34_spacomp_pr_mam1,nino34_spacomp_pr_son0,\
nino34_spacomp_tas_djf1,nino34_spacomp_tas_jja0,nino34_spacomp_tas_mam1,nino34_spacomp_tas_son0,\
nino34_spacomp_sst_djf1,nino34_spacomp_sst_jja0,nino34_spacomp_sst_mam1,nino34_spacomp_sst_son0,\
nino34_spectra,nino34_wavelet_power,nino34_wavelet_significance,nino4,nino34_spacomp_elnino_pr_djf1,\
nino34_spacomp_elnino_pr_jja0,nino34_spacomp_elnino_pr_mam1,nino34_spacomp_elnino_pr_son0,nino34_spacomp_elnino_sst_djf1,\
nino34_spacomp_elnino_sst_jja0,nino34_spacomp_elnino_sst_mam1,nino34_spacomp_elnino_sst_son0,nino34_spacomp_elnino_tas_djf1,\
nino34_spacomp_elnino_tas_jja0,nino34_spacomp_elnino_tas_mam1,nino34_spacomp_elnino_tas_son0,nino34_spacomp_lanina_pr_djf1,\
nino34_spacomp_lanina_pr_jja0,nino34_spacomp_lanina_pr_mam1,nino34_spacomp_lanina_pr_son0,nino34_spacomp_lanina_sst_djf1,\
nino34_spacomp_lanina_sst_jja0,nino34_spacomp_lanina_sst_mam1,nino34_spacomp_lanina_sst_son0,nino34_spacomp_lanina_tas_djf1,\
nino34_spacomp_lanina_tas_jja0,nino34_spacomp_lanina_tas_mam1,nino34_spacomp_lanina_tas_son0 \
  $CVDP_DATA_DIR/C20-Reanalysis.cvdp_data.1871-2012.nc C20-Reanalysis.cvdp_enso.1871-2012.nc
ncap2 -A -s 'nino34_spacomp_sst_ann=0.25f*(nino34_spacomp_sst_jja0+nino34_spacomp_sst_son0+nino34_spacomp_sst_djf1+nino34_spacomp_sst_mam1)' \
  C20-Reanalysis.cvdp_enso.1871-2012.nc C20-Reanalysis.cvdp_enso.1871-2012.nc
ncap2 -A -s 'nino34_spacomp_pr_ann=0.25f*(nino34_spacomp_pr_jja0+nino34_spacomp_pr_son0+nino34_spacomp_pr_djf1+nino34_spacomp_pr_mam1)' \
  C20-Reanalysis.cvdp_enso.1871-2012.nc C20-Reanalysis.cvdp_enso.1871-2012.nc
ncap2 -A -s 'nino34_spacomp_tas_ann=0.25f*(nino34_spacomp_tas_jja0+nino34_spacomp_tas_son0+nino34_spacomp_tas_djf1+nino34_spacomp_tas_mam1)' \
  C20-Reanalysis.cvdp_enso.1871-2012.nc C20-Reanalysis.cvdp_enso.1871-2012.nc

#Remove duplicates
#rm bcc-csm1*nc
#rm UofT*.nc 

#make a .tar.gz archive
rm PMIP4_cvdp_enso.tar.gz
tar -czf PMIP4_cvdp_enso.tar.gz *.cvdp_enso.*-*.nc
cp PMIP4_cvdp_enso.tar.gz ~/public_html/PMIPVarData/data/PMIP4_cvdp_enso.tar.gz
