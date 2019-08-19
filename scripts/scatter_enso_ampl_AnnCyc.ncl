;This script was used to block out some figures to populate a research publication on ENSO
;It makes full use of the programs in cvdp_data.functions.ncl to plot figures solely from the output data of cvdp (without needing recomputation).
; It makes 1 table (showing simulations used) and many figures. 

;load some functions
load "data_scripts/cvdp_data.functions.ncl"

mode_ts_name="nino34"
mode_sst_pattern_name="nino34_spacomp_sst_djf1"
mode_tas_pattern_name="nino34_spacomp_tas_djf1"
mode_pr_pattern_name="nino34_spacomp_pr_djf1"
troppac_region=(/(/-25.,25./),(/100.,280./)/);lat and lons of the edge of the plots (/(/latS,latN/),(/lonW,lonE/)/)
teleconnect_region=(/(/-45.,45./),(/40.,300./)/);lat and lons of the edge of the plots (/(/latS,latN/),(/lonW,lonE/)/)
index_region1=(/(/-5.,5./),(/140.,180./)/);lat and lons of the edge of first index box (only used for scatter plot)
index_region2=(/(/-5.,5./),(/210.,270./)/);lat and lons of the edge of second index box (only used for scatter plot, ignored if missing!)

expts=(/"piControl","historical","midHolocene","lgm","lig127k","1pctCO2","abrupt4xCO2"/)
expts_color=(/"grey60","black","darkgreen","dodgerblue4","yellowgreen","firebrick","orangered2"/)
gcms_all=(/"AWI-ESM","bcc-csm1-1","BCC-CSM2-MR","BCC-ESM1","CCSM4","CCSM4-r2","CESM2","CNRM-CM5","CNRM-CM6-1","CNRM-ESM2-1","COSMOS-ASO","CSIRO-Mk3-6-0","CSIRO-Mk3L-1-2","EC-EARTH-2-2","FGOALS-g2","FGOALS-s2","GFDL-CM4","GISS-E2-1-G","GISS-E2-R-p2","GISS-E2-R","HadCM3","HadGEM2-CC","HadGEM2-ES","HadGEM3-GC31","IPSL-CM5A-LR","IPSL-CM6A-LR","KCM1-2-2","MIROC6","MIROC-ESM","MPI-ESM-P-p2","MPI-ESM-P","MRI-CGCM3","MRI-ESM2-0"/)
isCMIP6=(/ True     ,False       ,True         ,True      ,False  ,False     ,True   ,False     ,True        ,True         ,False       ,False          ,False           ,False         ,False      ,False      ,True      ,True         ,False         ,False      ,False   ,False       ,False       ,True          ,False         ,True         ,False     ,True    ,False      ,False         ,False      ,False       ,True/)
gcms_subset=gcms_all(ind(isCMIP6))

;some plot switches
TS_NOT_TAS=True ;if True use SST rather TAS in the mean state figure
ADD_PRECIP_TO_PLOT=True ;if True, then adds the precipitation regression patterns to these plots
GCM_DICTIONARY=True; if True, will not print model names, but alphabetic look up from table
SCATTER_PCT_CHANGES=True ;if True, the scatterplots present the changes as percentages.
VERBOSE=False ;if True, provides a modicum of more information about whats goign on in the plots - used for debugging mainly.
OUTPUT_TYPE="pdf"; either "png" or "pdf"
USE_SUBSET_GCMS=False; if True then only use those GCMs that have done all the runs
INC_PREIND_wHIST=True; adds the preindustrial to all the plots including the Historical 
OVERLAY_PREIND=True; Adds contour line overlays of the piControl values (to help eye decide on locations of changes).

;Decide what plots to make
PLOT_HIST_MODE=False ;if True, plot the ENSO spatial pattern the C20 Reanalysis and the Historical Simulations 
PLOT_TAS_HIST=True;if True, plot the mean DJF & JJA temperature changes across the ensemble and their biases
PLOT_PR_HIST=True ;if True, plot the mean DJF & JJA precipiation changes across the ensemble and their biases
PLOT_TAS_ANOM=True ;if True, plot the mean DJF & JJA temperature changes across the ensemble and their biases
PLOT_PR_ANOM=False ;if True, plot the mean DJF & JJA precipiation changes across the ensemble and their biases
PLOT_PR_TELE_HIST=True ;if True, plot the precipitation patterns associated with the ATL3 and AMM indices in the C20 Reanalysis and the Historical Simulations 
PLOT_MIDH=True ;if True, for the midHolocene plot the ensemble mean change in ATL3, AMM, and SASD pattern and (with amplitude up top)
PLOT_LGM=False ;if True, for the LGM plot the ensemble mean change in ATL3, AMM, and SASD pattern and (with amplitude up top)
PLOT_FUTURE=True ;if True, for the 1pctCO2 run plot the ensemble mean change in ATL3, AMM, and SASD pattern and (with amplitude up top)
PLOT_TS=False ;if True, this spews out a series of timeseries (more for inspection than publication)
PRINT_TABLE=True ;if True, create a table (in LaTeX format) showing the simulations used 
BARCHART=False ;if True, plot some barcharts showing how the amplitude (i.e. stddev of timeseries) changes
BARCHART_EXPT=2 ;Sets which experiment the barchart is created for (as index of expts array above)
PLOT_MODE_SCATTER=False ;if True, create a scatterplot of the change in MODE amplitude vs the change in mean SST.

;;;;;;;;;;;
;;Process the GCM choices
;;;;;

paper_str="plots/possible_enso_plots_"
data_dir="/data/p2f/cvdp_data/"
if GCM_DICTIONARY then
  gcm_dict=createGCMsNameDictionary(data_dir,expts,mode_ts_name)
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Plot the historical ensemble mean ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if PLOT_HIST_MODE then
  ;Find some standard deviation for plot labelling
  RightStrings=new(3,string)
  fname_obs=find_files_wVar(data_dir,"C20-Reanalysis",mode_ts_name)
  RightStrings(0)=sprintf("%5.2f",stat_ts_var(fname_obs,mode_ts_name,"stddev",False))
  fnames_hist=find_files_wVar(data_dir,expts(1),mode_ts_name)
  stddevs=new(dimsizes(fnames_hist),float)
  do mod_i=0,dimsizes(fnames_hist)-1
    stddevs(mod_i)=stat_ts_var(fnames_hist(mod_i),mode_ts_name,"stddev",False)
  end do
  RightStrings(1)=sprintf("%5.2f",avg(stddevs))
  delete(stddevs)
  if INC_PREIND_wHIST then
    fnames_preind=find_files_wVar(data_dir,expts(0),mode_ts_name)
    stddevs=new(dimsizes(fnames_preind),float)
    do mod_i=0,dimsizes(fnames_preind)-1
      stddevs(mod_i)=stat_ts_var(fnames_preind(mod_i),mode_ts_name,"stddev",False)
    end do
    RightStrings(2)=sprintf("%5.2f",avg(stddevs))
  end if
  
  opt=True
  ;opt@gsnRightString="~F33~s~F21~="+RightStrings+"~F35~J~F21~C" 
  opt@gsnRightString=RightStrings+"~F35~J~F21~C"
  opt@gsnLeftString=(/"a","b","c"/)
  opt@lbLabelBarOn=True
  opt@mpProjection="CylindricalEqualArea"
  opt@gsnStringFontHeightF=0.03
  opt@lbLabelFontHeightF=0.018
  opt@mpLimitMode="LatLon"
  opt@mpCenterLonF=180.
  opt@mpMinLonF=troppac_region(1,0)
  opt@mpMaxLonF=troppac_region(1,1)
  opt@mpMinLatF=troppac_region(0,0)
  opt@mpMaxLatF=troppac_region(0,1)
  opt@lbLabelBarOn=False
  opt@cnMinLevelValF = -3.
  opt@cnMaxLevelValF = 3.
  opt@cnLevelSpacingF = 0.25
  opt@cnLevelSelectionMode = "ManualLevels"
  opt_pan=True
  opt_pan@lbTitleString="El Nino SST composite (~F35~J~F21~C)"
  opt_pan@lbTitleFontHeightF=0.02
  opt_pan@lbLabelFontHeightF=0.016
  opt_pan@gsnPanelLabelBar=True
  opt_pan@lbTitlePosition="Bottom"
  plotname=paper_str+"hist_mode"
  plotname@filetype=OUTPUT_TYPE
  plotname@VERBOSE=VERBOSE
  if INC_PREIND_wHIST then
    plotCVDPcomparisonMaps(data_dir,(/"C20-Reanalysis",expts(1),expts(0)/),mode_sst_pattern_name,\
          plotname,opt,opt_pan)
  else
    plotCVDPcomparisonMaps(data_dir,(/"C20-Reanalysis",expts(1)/),mode_sst_pattern_name,\
          plotname,opt,opt_pan)
  end if
  delete([/RightStrings,fname_obs,fnames_hist,opt,opt_pan/])
end if;PLOT_HIST_MODE

if PLOT_TAS_HIST then
  ;Rather than immediately sending the plot to a file, this plot first opens a wks and panels within it. 
  if TS_NOT_TAS then
    wks=gsn_open_wks(OUTPUT_TYPE,paper_str+"ts_hist")
    djf_field="sst_spatialmean_djf"
    jja_field="sst_spatialmean_jja"
  else
    wks=gsn_open_wks(OUTPUT_TYPE,paper_str+"tas_hist")
    djf_field="tas_spatialmean_djf"
    jja_field="tas_spatialmean_jja"
  end if
  wks@VERBOSE=VERBOSE
  opt=True
  opt@cnLevelSelectionMode = "ManualLevels"   
  if TS_NOT_TAS then
    opt@cnMinLevelValF       = 15
    opt@cnMaxLevelValF       = 30
  else
    opt@cnMinLevelValF       = 10
    opt@cnMaxLevelValF       = 35
  end if
  opt@cnLevelSpacingF = 1
  opt@cnFillPalette="WhiteBlueGreenYellowRed"
  opt@mpProjection="CylindricalEqualArea"
  opt@gsnStringFontHeightF=0.03
  opt@lbLabelFontHeightF=0.018
  opt@mpLimitMode="LatLon"
  opt@mpMinLonF=troppac_region(1,0)
  opt@mpMaxLonF=troppac_region(1,1)
  opt@mpMinLatF=troppac_region(0,0)
  opt@mpMaxLatF=troppac_region(0,1)
  opt@mpCenterLonF=180.
  opt@gsnLeftString=(/"a","b"/)
  opt@tiMainString=""
  opt@gsnCenterString=""
  opt@lbLabelBarOn=False
  opt_pan=True
  opt_pan@lbTitleOn=False
  opt_pan@lbOrientation = "vertical"
  opt_pan@gsnPanelLabelBar=True
  if INC_PREIND_wHIST then
    opt_pan@gsnPanelBottom=0.66
  else
    opt_pan@gsnPanelBottom=0.5
  end if
  opt_pan@gsnFrame=False
  opt_pan@lbLabelFontHeightF=0.016
  if TS_NOT_TAS then
    opt@gsnRightString="HadISST "+(/"DJF","JJA"/)
    plotCVDPcomparisonMaps(data_dir,"HadISST",(/djf_field,jja_field/),wks,opt,opt_pan)
  else
    opt@gsnRightString="C20-Reanalysis"+(/"DJF","JJA"/)
    plotCVDPcomparisonMaps(data_dir,"C20-Reanalysis",(/djf_field,jja_field/),wks,opt,opt_pan)
  end if
  opt@cnFillPalette="CBR_coldhot"
  opt@cnLevelSelectionMode = "ExplicitLevels"   
  opt@cnLevels=(/-5.,-3.,-2.,-1.,-0.5,0.5,1.,2.,3.,5./)
  opt_pan@lbTitleString="Temperature Difference (oC)"
  opt@gsnLeftString=(/"c","d"/)
  opt@gsnRightString="historical "+(/"DJF","JJA"/)
  opt@CONSISTENCY=True ;Turn on Stippling
  if INC_PREIND_wHIST then
    opt_pan@gsnPanelBottom=0.33
    opt_pan@gsnPanelTop=0.66
  else
    opt_pan@gsnPanelBottom=0.0
    opt_pan@gsnPanelTop=0.5
  end if
  opt_pan@dims=(/1,2/)
  if TS_NOT_TAS then
    plotDiffEnsMnMaps(data_dir,expts(1),"HadISST",(/djf_field,jja_field/),wks,opt,opt_pan)
  else
    plotDiffEnsMnMaps(data_dir,expts(1),"C20-Reanalysis",(/djf_field,jja_field/),wks,opt,opt_pan)
  end if
  if INC_PREIND_wHIST then
    opt@cnFillPalette="CBR_coldhot"
    opt@cnLevelSelectionMode = "ExplicitLevels"   
    opt@cnLevels=(/-5.,-3.,-2.,-1.,-0.5,0.5,1.,2.,3.,5./)
    opt_pan@lbTitleString="Temperature Difference (oC)"
    opt@gsnLeftString=(/"c","d"/)
    opt@gsnRightString="piControl "+(/"DJF","JJA"/)
    opt@CONSISTENCY=True ;Turn on Stippling
    opt_pan@gsnPanelBottom=0.0
    opt_pan@gsnPanelTop=0.33
    opt_pan@dims=(/1,2/)
    if TS_NOT_TAS then
      plotDiffEnsMnMaps(data_dir,expts(0),"HadISST",(/djf_field,jja_field/),wks,opt,opt_pan)
    else
      plotDiffEnsMnMaps(data_dir,expts(0),"C20-Reanalysis",(/djf_field,jja_field/),wks,opt,opt_pan)
    end if
  end if
  frame(wks)
  delete(wks)
  delete([/opt,opt_pan/])
end if;PLOT_TAS_HIST

if PLOT_TAS_ANOM then
  ;Rather than immediately sending the plot to a file, this plot first opens a wks and panels within it. 
  if TS_NOT_TAS then
    wks=gsn_open_wks(OUTPUT_TYPE,paper_str+"ts_mean")
    djf_field="sst_spatialmean_djf"
    jja_field="sst_spatialmean_jja"
  else
    wks=gsn_open_wks(OUTPUT_TYPE,paper_str+"tas_mean")
    djf_field="tas_spatialmean_djf"
    jja_field="tas_spatialmean_jja"
  end if
  wks@VERBOSE=VERBOSE
  opt=True
  opt@cnFillPalette="CBR_coldhot"
  opt@cnLevelSelectionMode = "ExplicitLevels"   
  opt@cnLevels=(/-5.,-3.,-2.,-1.,-0.5,0.5,1.,2.,3.,5./)
  opt@mpProjection="CylindricalEqualArea"
  opt@mpLimitMode="LatLon"
  opt@mpMinLonF=troppac_region(1,0)
  opt@mpMaxLonF=troppac_region(1,1)
  opt@mpMinLatF=troppac_region(0,0)
  opt@mpMaxLatF=troppac_region(0,1)
  opt@gsnLeftString=(/"a","b"/)
  opt@gsnRightString="Mid-Holocene "+(/"DJF","JJA"/)
  opt@gsnStringFontHeightF=0.03
  opt@lbLabelFontHeightF=0.018
  opt@tiMainString=""
  opt@gsnCenterString=""
  opt@lbLabelBarOn=False
  opt@CONSISTENCY=True ;Turn on Stippling
  opt@OVERLAY_CONTROL=OVERLAY_PREIND
  opt@OVERLAY_CONTROL_MANUALLEVS=(/20,32,1/);ie 0:12:2 mm/day
  opt_pan=True
  opt_pan@lbTitleOn=False
  opt_pan@lbTitleString="Temperature Difference (oC)"
  opt_pan@lbOrientation = "vertical"
  opt_pan@gsnPanelLabelBar=True
  opt_pan@gsnPanelBottom=0.66
  opt_pan@lbLabelFontHeightF=0.016
  opt_pan@gsnFrame=False
  opt_pan@dims=(/1,2/)
  plotDiffEnsMnMaps(data_dir,expts(2),expts(0),(/djf_field,jja_field/),wks,opt,opt_pan)
  opt@gsnLeftString=(/"c","d"/)
  opt@gsnRightString="LGM "+(/"DJF","JJA"/)
  opt@CONSISTENCY=True ;Turn on Stippling (note procedure treats opt and in/out and this attribute is deleted within
  opt@OVERLAY_CONTROL=OVERLAY_PREIND
  opt@OVERLAY_CONTROL_MANUALLEVS=(/20,32,1/);ie 0:12:2 mm/day
  opt_pan@gsnPanelBottom=0.33
  opt_pan@gsnPanelTop=0.66
  plotDiffEnsMnMaps(data_dir,expts(3),expts(0),(/djf_field,jja_field/),wks,opt,opt_pan)
  opt@gsnLeftString=(/"e","f"/)
  opt@gsnRightString="1% CO2 "+(/"DJF","JJA"/)
  opt@CONSISTENCY=True ;Turn on Stippling
  opt@OVERLAY_CONTROL=OVERLAY_PREIND
  opt@OVERLAY_CONTROL_MANUALLEVS=(/20,32,1/);ie 0:12:2 mm/day
  opt_pan@gsnPanelBottom=0.0
  opt_pan@gsnPanelTop=0.33
  plotDiffEnsMnMaps(data_dir,expts(4),expts(0),(/djf_field,jja_field/),wks,opt,opt_pan)
  frame(wks)
  delete(wks)
  delete([/opt,opt_pan/])
end if;PLOT_TAS_ANOM

if PLOT_PR_HIST then
  wks=gsn_open_wks(OUTPUT_TYPE,paper_str+"pr_hist")
  wks@VERBOSE=VERBOSE
  opt=True
  opt@cnLevelSelectionMode = "ManualLevels"   
  opt@cnMinLevelValF       = 0
  opt@cnMaxLevelValF       = 10
  opt@cnLevelSpacingF = 1.
  opt@cnFillPalette="CBR_wet"
  opt@mpProjection="CylindricalEqualArea"
  opt@mpLimitMode="LatLon"
  opt@mpMinLonF=troppac_region(1,0)
  opt@mpMaxLonF=troppac_region(1,1)
  opt@mpMinLatF=troppac_region(0,0)
  opt@mpMaxLatF=troppac_region(0,1)
  opt@mpCenterLonF=180.
  opt@gsnLeftString=(/"a","b"/)
  opt@gsnRightString="GPCP "+(/"DJF","JJA"/)
  opt@gsnStringFontHeightF=0.03
  opt@tiMainString=""
  opt@gsnCenterString=""
  opt@lbLabelBarOn=False
  opt_pan=True
  opt_pan@lbTitleOn=False
  opt_pan@lbOrientation = "vertical"
  opt_pan@gsnPanelLabelBar=True
  opt_pan@lbLabelFontHeightF=0.016
  if INC_PREIND_wHIST then
    opt_pan@gsnPanelBottom=0.66
  else
    opt_pan@gsnPanelBottom=0.5
  end if
  opt_pan@gsnFrame=False
  plotCVDPcomparisonMaps(data_dir,"GPCP",(/"pr_spatialmean_djf","pr_spatialmean_jja"/),wks,opt,opt_pan)
  opt@cnFillPalette="CBR_drywet"
  opt@cnLevelSelectionMode = "ExplicitLevels"   
  opt@cnLevels=(/-5.,-2.,-1.,-0.5,-0.1,0.1,0.5,1.,2.,5./)
  opt_pan@lbTitleString="Precip. Difference (mm/day)"
  opt@gsnLeftString=(/"c","d"/)
  opt@gsnRightString="historical "+(/"DJF","JJA"/)
  opt@CONSISTENCY=True ;Turn on Stippling
  if INC_PREIND_wHIST then
    opt_pan@gsnPanelTop=0.66
    opt_pan@gsnPanelBottom=0.33
  else
    opt_pan@gsnPanelBottom=0.0
    opt_pan@gsnPanelTop=0.5
  end if
  opt_pan@dims=(/1,2/)
  plotDiffEnsMnMaps(data_dir,expts(1),"GPCP",(/"pr_spatialmean_djf","pr_spatialmean_jja"/),wks,opt,opt_pan)
  if INC_PREIND_wHIST then
    opt@cnFillPalette="CBR_drywet"
    opt@cnLevelSelectionMode = "ExplicitLevels"   
    opt@cnLevels=(/-5.,-2.,-1.,-0.5,-0.1,0.1,0.5,1.,2.,5./)
    opt_pan@lbTitleString="Precip. Difference (mm/day)"
    opt@gsnLeftString=(/"e","f"/)
    opt@gsnRightString="piControl "+(/"DJF","JJA"/)
    opt@CONSISTENCY=True ;Turn on Stippling
    opt_pan@gsnPanelBottom=0.0
    opt_pan@gsnPanelTop=0.33
    opt_pan@dims=(/1,2/)
    plotDiffEnsMnMaps(data_dir,expts(0),"GPCP",(/"pr_spatialmean_djf","pr_spatialmean_jja"/),wks,opt,opt_pan)
  end if
  frame(wks)
  delete(wks)
  delete([/opt,opt_pan/])
end if;PLOT_PR_HIST

if PLOT_PR_ANOM then
  wks=gsn_open_wks(OUTPUT_TYPE,paper_str+"pr_mean")
  wks@VERBOSE=VERBOSE
  opt=True
  opt@mpProjection="CylindricalEqualArea"
  opt@mpLimitMode="LatLon"
  opt@mpCenterLonF=-180
  opt@mpMinLonF=troppac_region(1,0)
  opt@mpMaxLonF=troppac_region(1,1)
  opt@mpMinLatF=troppac_region(0,0)
  opt@mpMaxLatF=troppac_region(0,1)
  opt@tiMainString=""
  opt@gsnCenterString=""
  opt@lbLabelBarOn=False
  opt@cnFillPalette="CBR_drywet"
  opt@cnLevelSelectionMode = "ExplicitLevels"   
  opt@cnLevels=(/-5.,-2.,-1.,-0.5,-0.1,0.1,0.5,1.,2.,5./)
  opt@gsnStringFontHeightF=0.03
  opt@CONSISTENCY=True ;Turn on stippling
  opt@OVERLAY_CONTROL=OVERLAY_PREIND
  opt@OVERLAY_CONTROL_MANUALLEVS=(/0,12,2/);ie 0:12:2 mm/day
  opt_pan=True
  opt_pan@lbTitleOn=False
  opt_pan@lbOrientation = "vertical"
  opt_pan@gsnPanelLabelBar=True
  opt_pan@gsnFrame=False
  opt_pan@lbTitleString="Precip. Difference (mm/day)"
  opt_pan@lbLabelFontHeightF=0.016
  opt_pan@dims=(/1,2/)
  opt@gsnLeftString=(/"a","b"/)
  opt@gsnRightString="Mid-Holocene "+(/"DJF","JJA"/)
  opt_pan@gsnPanelBottom=0.0
  opt_pan@gsnPanelTop=0.2
  plotDiffEnsMnMaps(data_dir,expts(2),expts(0),(/"pr_spatialmean_djf","pr_spatialmean_jja"/),wks,opt,opt_pan)
  opt@gsnLeftString=(/"c","d"/)
  opt@gsnRightString="LGM "+(/"DJF","JJA"/)
  opt@CONSISTENCY=True ;Turn on Stippling (note procedure treats opt and in/out and this attribute is deteled within
  opt@OVERLAY_CONTROL=OVERLAY_PREIND
  opt_pan@gsnPanelBottom=0.2
  opt_pan@gsnPanelTop=0.4
  plotDiffEnsMnMaps(data_dir,expts(3),expts(0),(/"pr_spatialmean_djf","pr_spatialmean_jja"/),wks,opt,opt_pan)
  opt@gsnLeftString=(/"e","f"/)
  opt@gsnRightString="LIG "+(/"DJF","JJA"/)
  opt@CONSISTENCY=True ;Turn on Stippling (note procedure treats opt and in/out and this attribute is deteled within
  opt@OVERLAY_CONTROL=OVERLAY_PREIND
  opt_pan@gsnPanelBottom=0.4
  opt_pan@gsnPanelTop=0.6
  plotDiffEnsMnMaps(data_dir,expts(4),expts(0),(/"pr_spatialmean_djf","pr_spatialmean_jja"/),wks,opt,opt_pan)
  opt@gsnLeftString=(/"g","h"/)
  opt@gsnRightString="1% CO2 "+(/"DJF","JJA"/)
  opt@CONSISTENCY=True ;Turn on Stippling (note procedure treats opt and in/out and this attribute is deteled within
  opt@OVERLAY_CONTROL=OVERLAY_PREIND
  opt_pan@gsnPanelBottom=0.6
  opt_pan@gsnPanelTop=0.8
  plotDiffEnsMnMaps(data_dir,expts(5),expts(0),(/"pr_spatialmean_djf","pr_spatialmean_jja"/),wks,opt,opt_pan)
  opt@gsnLeftString=(/"i","j"/)
  opt@gsnRightString="Abrupt 4xCO2 "+(/"DJF","JJA"/)
  opt@CONSISTENCY=True ;Turn on Stippling (note procedure treats opt and in/out and this attribute is deteled within
  opt@OVERLAY_CONTROL=OVERLAY_PREIND
  opt_pan@gsnPanelBottom=0.8
  opt_pan@gsnPanelTop=1.
  plotDiffEnsMnMaps(data_dir,expts(6),expts(0),(/"pr_spatialmean_djf","pr_spatialmean_jja"/),wks,opt,opt_pan)
  frame(wks)
  delete(wks)
  delete([/opt,opt_pan/])
end if;PLOT_PR_ANOM

if PLOT_PR_TELE_HIST then
  if VERBOSE then
    print("Plotting precipitation regressions")
  end if
  plotname=paper_str+"piControl_precip_regress"
  plotname@filetype=OUTPUT_TYPE
  plotname@VERBOSE=VERBOSE
  opt=True
  opt@mpProjection="CylindricalEqualArea"
  opt@mpLimitMode="LatLon"
  opt@mpMinLonF=teleconnect_region(1,0)
  opt@mpMaxLonF=teleconnect_region(1,1)
  opt@mpMinLatF=teleconnect_region(0,0)
  opt@mpMaxLatF=teleconnect_region(0,1)
  opt@tiMainString=""
  opt@mpCenterLonF=180.
  opt@gsnCenterString=""
  opt@lbLabelBarOn=False
  opt@gsnStringFontHeightF=0.04
  opt@gsnLeftString=(/"a","b","c"/)
  opt@gsnRightString=(/"Reanalysis","historical","piControl"/)
  opt@cnFillPalette="CBR_drywet"
  opt@cnLevelSelectionMode = "ExplicitLevels"   
  opt@cnLevels=(/-2.,-1.,-0.5,-0.2,-0.1,0.1,0.2,0.5,1.,2./)
  opt_pan=True
  opt_pan@lbTitleOn=True
  opt_pan@gsnPanelLabelBar=True
  opt_pan@lbTitleString="Precip. regression (mm/day/~F35~J~F21~C)"
  opt_pan@lbLabelFontHeightF=0.016
  plotCVDPcomparisonMaps(data_dir,(/"C20-Reanalysis",expts(0),expts(1)/),mode_pr_pattern_name,plotname,opt,opt_pan)
  delete(opt)
end if;PLOT_PR_TELE_HIST

if any((/PLOT_MIDH,PLOT_LGM,PLOT_FUTURE/)) then
  plots_to_make=ind((/PLOT_MIDH,PLOT_LGM,PLOT_FUTURE/))
  do i=0,dimsizes(plots_to_make)-1
    opt=True
    opt@CONSISTENCY=True
    opt@OVERLAY_CONTROL=OVERLAY_PREIND
    opt@OVERLAY_CONTROL_MANUALLEVS=(/-1.,1.,0.2/)
    opt@mpProjection="CylindricalEqualArea"
    opt@mpLimitMode="LatLon"
    opt@lbLabelBarOn=False
    opt@mpMinLonF=teleconnect_region(1,0)
    opt@mpMaxLonF=teleconnect_region(1,1)
    opt@mpMinLatF=teleconnect_region(0,0)
    opt@mpMaxLatF=teleconnect_region(0,1)
    opt@mpCenterLonF=180.
    opt@gsnCenterString=""
    opt@lbTitleFontHeightF=0.016
    opt@lbLabelFontHeightF=0.016
    optpan=True
    optpan@lbTitleFontHeightF=0.01
    optpan@lbLabelFontHeightF=0.016
    if ADD_PRECIP_TO_PLOT then
      wks=gsn_open_wks(OUTPUT_TYPE,paper_str+"pr_reg_"+expts(plots_to_make(i)+2))
      wks@VERBOSE=VERBOSE
      opt@gsnStringFontHeightF=0.04
      opt@gsnLeftString=(/"a"/)
      opt@gsnCenterString=""
      opt@tiMainString=""
      optpan@gsnPanelRight=0.5
      optpan@gsnFrame=False
      optpan@gsnPanelLabelBar=True
      optpan@lbTitleString="~F35~J~F21~C/~F35~J~F21~C"
      opt@cnMinLevelValF = -3.
      opt@cnMaxLevelValF = 3.
      opt@cnLevelSpacingF = 0.25
      opt@cnLevelSelectionMode = "ManualLevels"
      plotDiffEnsMnMaps(data_dir,expts(plots_to_make(i)+2),expts(0),mode_tas_pattern_name,wks,opt,optpan)
      opt@gsnLeftString=(/"b"/)
      opt@cnFillPalette="CBR_drywet"
      opt@cnLevelSelectionMode = "ExplicitLevels"   
      delete(opt@cnLevels)
      opt@cnLevels=(/-0.5,-0.3,-0.1,-0.05,0.05,0.1,0.3,0.5/)
      optpan@gsnFrame=True
      optpan@gsnPanelLabelBar=True
      optpan@lbTitleString="mm/day/~F35~J~F21~C"
      optpan@lbLabelFontHeightF=0.016
      optpan@gsnPanelRight=1.0
      optpan@gsnPanelLeft=0.5      
      plotDiffEnsMnMaps(data_dir,expts(plots_to_make(i)+2),expts(0),mode_pr_pattern_name,wks,opt,optpan)
      delete([/wks,opt,optpan/])
    else
      plotname=paper_str+expts(plots_to_make(i)+2)
      plotname@filetype=OUTPUT_TYPE
      plotname@VERBOSE=VERBOSE
      opt@gsnLeftString=(/" "/)
      plotDiffEnsMnMaps(data_dir,expts(plots_to_make(i)+2),expts(0),mode_tas_pattern_name,plotname,opt,optpan)
    end if
  end do
end if;PLOT_MIDH,PLOT_LGM,PLOT_FUTURE

if PLOT_TS then
  ts_opt=True
  ts_opt@RUN_STDDEV=True
  opt_res=True
  opt_res@tiYAxisString=mode_ts_name+" stddev"
  opt_res@tiXAxisString=""
  opt_res@tiMainString="C20-Reanalysis"
  plotEnsTimeseries(data_dir,"C20-Reanalysis",mode_ts_name,ts_opt,paper_str+"C20-Reanalysis_runstddev",opt_res,False)
  opt_res@tiMainString="Historical Simulations"
  plotEnsTimeseries(data_dir,"historical",mode_ts_name,ts_opt,paper_str+"historical_runstddev",opt_res,False)
  opt_res@tiMainString="1%CO2 Simulations"
  plotEnsTimeseries(data_dir,"1pctCO2",mode_ts_name,ts_opt,paper_str+"1pctCO2_runstddev",opt_res,False)
  delete(ts_opt@RUN_STDDEV)
  opt_res@tiYAxisString=mode_ts_name
  opt_res@tiMainString="past1000"
  plotEnsTimeseries(data_dir,"past1000",mode_ts_name,ts_opt,paper_str+"past100_runstddev",opt_res,False)
end if;PLOT_TS

if PRINT_TABLE then
  if GCM_DICTIONARY then
    createTableGCMsExptsYears(data_dir,expts,mode_ts_name,gcm_dict,"tex",paper_str+mode_ts_name+"_table.tex")
  else
    createTableGCMsExptsYears(data_dir,expts,mode_ts_name,False,"tex",paper_str+mode_ts_name+"_table.tex")
  end if
end if ;PRINT_TABLE

if BARCHART then
  fnames_both=find_pair_files_wVar(data_dir,expts(BARCHART_EXPT),expts(0),mode_ts_name)
  n_models=dimsizes(fnames_both(:,0))
  mode_sds=new((/n_models,3/),float)
  gcm_names=new(n_models,string)
  do i=0,n_models-1
    a_nopath=str_get_field(fnames_both(i,0),str_fields_count(fnames_both(i,0),"/"),"/")
    gcm_names(i)=str_get_field(str_sub_str(a_nopath,"_"+expts(BARCHART_EXPT),":"),1,":")
    mode_sds(i,0)=(/stat_ts_var(fnames_both(i,0),mode_ts_name,"stddev",False)/)
    mode_sds(i,1)=(/stat_ts_var(fnames_both(i,1),mode_ts_name,"stddev",False)/)
  end do
  mode_sds(:,2)=(mode_sds(:,0)-mode_sds(:,1))/mode_sds(:,1)*100.
  print("Ensemble mean change in "+expts(BARCHART_EXPT)+" = "+avg(mode_sds(:,2))+"%") 

  plot_res = True
  plot_res@trYMinF = 0.
  plot_res@vpWidthF = 0.9
  plot_res@vpHeightF = 0.33
  plot_res@gsnDraw = False
  plot_res@gsnFrame=False
  plot_res@gsnYRefLine = 0
  plot_res@gsnXYBarChart = True
  plot_res@tiMainString = " "
  plot_res@gsnRightString = ""
  plot_res@tiXAxisString = " "
  plot_res@tmYMajorGrid = False
  plot_res@tmXTOn = False
  plot_res@tmXBMode = "Explicit"
  plot_res@tmXBValues = ispan(1,n_models,1)
  if GCM_DICTIONARY then
    gcm_letters=translateGCMsNameDictionary(gcm_names,gcm_dict,False)
    plot_res@tmXBLabels = gcm_letters
    plot_res@tmXBLabelFontHeightF = 0.018
    plot_res@tmEqualizeXYSizes=True
  else
    ;strip off final ensemble member digit
    do i=0,n_models-1
      gcm_names(i)=str_get_field(gcm_names(i),str_fields_count(gcm_names(i),"_")-1,"_")
    end do
    plot_res@tmXBLabels = gcm_names
    plot_res@tmXBLabelFontHeightF = 0.012
  end if
  plot_res@tmXBLabelDirection="Down"
  plot_res@trXMinF = 0.5
  plot_res@trXMaxF = n_models+0.5
  plot_res@gsnXYBarChartBarWidth = 0.4
  left_locations=fspan(0.5,n_models-0.5,n_models)+0.3
  right_locations=left_locations+0.4
  
  wks = gsn_open_wks(OUTPUT_TYPE,paper_str+expts(BARCHART_EXPT)+"_barchart")
  plot_res@tiYAxisString = mode_ts_name+" ~F33~s~F21~ (~F35~J~F21~C)"
  plot_res@gsnXYBarChartColors=expts_color(BARCHART_EXPT)
  mode_baseplot = gsn_csm_xy(wks,left_locations,mode_sds(:,0),plot_res)
  plot_res@gsnXYBarChartColors=expts_color(0)
  mode_oplot = gsn_csm_xy(wks,right_locations,mode_sds(:,1),plot_res)
  overlay(mode_baseplot,mode_oplot)

  plot_res@tiYAxisString = "Change in ~F33~s~F21~ (%)"
  plot_res@gsnXYBarChartColors="orange2"
  plot_res@trYMaxF = max(fabs(mode_sds(:,2)))
  plot_res@trYMinF = -max(fabs(mode_sds(:,2)))
  diff_baseplot = gsn_csm_xy(wks,left_locations,mode_sds(:,2),plot_res)

  resP=True
  resP@gsnMaximize=True
  if .not.GCM_DICTIONARY then
    resP@gsnPanelYWhiteSpacePercent = 20.0
  end if
  gsn_panel(wks,(/mode_baseplot,diff_baseplot/),(/2,1/),resP)
  delete([/wks,resP,plot_res,mode_baseplot,diff_baseplot/])
  delete([/mode_oplot,fnames_both/])
end if ;BARCHART

if PLOT_MODE_SCATTER then
  fnames_pictl=find_files_wVar(data_dir,"piControl",mode_ts_name)
  num_pictl=dimsizes(fnames_pictl)
  d_stddev=new(num_pictl*3,float);array to hold variability change
  d_index=new(num_pictl*3,float);array to hold mean state change
  ts_opt=True
  mean_field="sst_spatialmean_ann"
  ts_1pctCO2=ts_opt
  ts_1pctCO2@renorm_climo=True
  ts_1pctCO2@subset=True
  ts_1pctCO2@subset_syear=-39
  ts_1pctCO2@subset_eyear=0
  ts_1pctCO2@renorm_climo_syear=-39
  ts_1pctCO2@renorm_climo_eyear=0
  
  ;collect all the data
  do expt_i=0,2
    if expts(expt_i+2).eq."1pctCO2" then
      ts_a=ts_1pctCO2
    else
      ts_a=ts_opt
    end if
    fnames_both=find_pair_files_wVar(data_dir,expts(expt_i+2),"piControl",mode_ts_name)
    do gcm_i=0,dimsizes(fnames_both(:,0))-1
      sd_a=stat_ts_var(fnames_both(gcm_i,0),mode_ts_name,"stddev",ts_a)
      sd_b=stat_ts_var(fnames_both(gcm_i,1),mode_ts_name,"stddev",ts_opt)
      region1_a=extract_latlon_areastat(fnames_both(gcm_i,0),mean_field,index_region1(0,:),index_region1(1,:),"mean")
      region1_b=extract_latlon_areastat(fnames_both(gcm_i,1),mean_field,index_region1(0,:),index_region1(1,:),"mean")
      if all(ismissing(index_region2)) then
        if SCATTER_PCT_CHANGES then
          d_stddev(expt_i*num_pictl+gcm_i)=100.*(sd_a-sd_b)/sd_b
          d_index(expt_i*num_pictl+gcm_i)=100.*(region1_a-region1_b)/(region1_b)
        else
          d_stddev(expt_i*num_pictl+gcm_i)=sd_a-sd_b
          d_index(expt_i*num_pictl+gcm_i)=region1_a-region1_b
        end if
        delete([/sd_a,sd_b,region1_a,region1_b/])
      else
        region2_a=extract_latlon_areastat(fnames_both(gcm_i,0),mean_field,index_region2(0,:),index_region2(1,:),"mean")
        region2_b=extract_latlon_areastat(fnames_both(gcm_i,1),mean_field,index_region2(0,:),index_region2(1,:),"mean")
        if SCATTER_PCT_CHANGES then
          d_stddev(expt_i*num_pictl+gcm_i)=100.*(sd_a-sd_b)/sd_b
          d_index(expt_i*num_pictl+gcm_i)=100.*((region1_a-region2_a)-(region1_b-region2_b))/(region1_b-region2_b)
        else
          d_stddev(expt_i*num_pictl+gcm_i)=sd_a-sd_b
          d_index(expt_i*num_pictl+gcm_i)=(region1_a-region2_a)-(region1_b-region2_b)
        end if
        delete([/sd_a,sd_b,region1_a,region2_a,region1_b,region2_b/])
      end if
    end do
    delete(fnames_both)
  end do

  ;create the scatter plot
  wks = gsn_open_wks(OUTPUT_TYPE,paper_str+mode_ts_name+"_scatterplot")
  res                   = True                     ; plot mods desired
  res@gsnDraw = False
  res@gsnFrame = False                     ; plot mods desired
  res@tiMainString      = " "           ; add title
  res@xyMarkLineModes   = "Markers"                ; choose which have markers
  res@xyMarkers         =  16                      ; choose type of marker  
  res@xyMonoMarkerColor = True
  res@xyMarkerSizeF     = 0.01                     ; Marker size (default 0.01)
  res@gsnYRefLine=0.0
  res@gsnXRefLine=0.0
  res@tmLabelAutoStride = True                     ; nice tick mark labels
  if SCATTER_PCT_CHANGES then
    res@tiYAxisString   = mode_ts_name+" Amplitude Change (%)"
    res@tiXAxisString   = mode_ts_name+" Mean Change (%)"
  else
    res@tiYAxisString   = mode_ts_name+" Amplitude Change"
    res@tiXAxisString   = mode_ts_name+" Mean Change"
  end if
  res@trYMaxF=max(d_stddev)
  res@trYMinF=min(d_stddev)
  res@trXMaxF=max(d_index)
  res@trXMinF=min(d_index)
  
  res@xyMarkerColor =  expts_color(2) 
  plot  = gsn_csm_xy (wks,d_index(0:num_pictl-1),d_stddev(0:num_pictl-1),res) ; create plot
  res@xyMarkerColor =  expts_color(3) 
  oplot1  = gsn_csm_xy (wks,d_index(num_pictl:2*num_pictl-1),d_stddev(num_pictl:2*num_pictl-1),res)
  res@xyMarkerColor =  expts_color(4) 
  oplot2  = gsn_csm_xy (wks,d_index(2*num_pictl:3*num_pictl-1),d_stddev(2*num_pictl:3*num_pictl-1),res)
  overlay(plot,oplot1)
  overlay(plot,oplot2)
  draw(plot)
  frame(wks)
  delete(wks)
end if ;PLOT_MODE_SCATTER
