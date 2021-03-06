;This script was used to block out some figures to populate a research publication on ENSO
;It makes full use of the programs in cvdp_data.functions.ncl to plot figures solely from the output data of cvdp (without needing recomputation).
; It makes 1 table (showing simulations used) and many figures. 

;load some functions
present_dir=systemfunc("pwd")
if ismissing(str_match_ind(present_dir,"scripts")) then
  loadscript("./scripts/cvdp_enso.functions.ncl")
  plots_dir=present_dir+"/plots/"
else
  loadscript("./cvdp_enso.functions.ncl")
  plots_dir=present_dir+"/../plots/"
end if


;some plot switches
VERBOSE=False ;if True, provides a modicum of more information about whats going on in the plots - used for debugging mainly.
TS_NOT_TAS=True ;if True use SST rather TAS in the mean state figure
OUTPUT_TYPE="pdf"; either "png" or "pdf"
INC_PREIND_wHIST=True; adds the preindustrial to all the plots including the Historical 
troppac_region=(/(/-25.,25./),(/100.,280./)/);lat and lons of the edge of the plots (/(/latS,latN/),(/lonW,lonE/)/)
expts=(/"piControl","historical","midHolocene","lgm","lig127k","1pctCO2","abrupt4xCO2"/)
expts_color=(/"grey60","black","darkgreen","dodgerblue4","yellowgreen","firebrick","orangered2"/)

if TS_NOT_TAS then
  djf_field="sst_spatialmean_djf"
  jja_field="sst_spatialmean_jja"
else
  djf_field="tas_spatialmean_djf"
  jja_field="tas_spatialmean_jja"
end if

wks=gsn_open_wks(OUTPUT_TYPE,plots_dir+"meanstate_eval_relativetemp")
wks@VERBOSE=VERBOSE
opt=True
  opt@cnFillPalette="CBR_coldhot"
  opt@cnLevelSelectionMode = "ExplicitLevels"   
  opt@cnLevels=(/-5.,-3.,-2.,-1.,-0.5,0.5,1.,2.,3.,5./)
  opt@cnLevelSpacingF = 1.
  opt@mpProjection="CylindricalEqualArea"
  opt@mpLimitMode="LatLon"
  opt@mpMinLonF=troppac_region(1,0)
  opt@mpMaxLonF=troppac_region(1,1)
  opt@mpMinLatF=troppac_region(0,0)
  opt@mpMaxLatF=troppac_region(0,1)
  opt@mpCenterLonF=180.
  opt@gsnLeftString=(/"a","b"/)
  opt@gsnStringFontHeightF=0.03
  opt@tiMainString=""
  opt@gsnCenterString=""
  opt@lbLabelBarOn=False
  opt@NORMALISE=True
  opt@name_to_normalise_by="relative_to_plot_area_average"
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
if TS_NOT_TAS then
  plotCVDPcomparisonMaps("HadISST",(/djf_field,jja_field/),wks,opt,opt_pan)
else
  plotCVDPcomparisonMaps("C20-Reanalysis",(/djf_field,jja_field/),wks,opt,opt_pan)
end if
  opt_pan@lbTitleString="Temperature Difference (oC)"
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
if TS_NOT_TAS then
  plotDiffEnsMnMaps("historical","HadISST",(/djf_field,jja_field/),wks,opt,opt_pan)
else
  plotDiffEnsMnMaps("historical","C20-Reanalysis",(/djf_field,jja_field/),wks,opt,opt_pan)
end if
if INC_PREIND_wHIST then
    opt@gsnLeftString=(/"e","f"/)
    opt@gsnRightString="piControl "+(/"DJF","JJA"/)
    opt@CONSISTENCY=True ;Turn on Stippling
    opt_pan@gsnPanelBottom=0.0
    opt_pan@gsnPanelTop=0.33
    opt_pan@dims=(/1,2/)
    if TS_NOT_TAS then
      plotDiffEnsMnMaps("piControl","HadISST",(/djf_field,jja_field/),wks,opt,opt_pan)
    else
      plotDiffEnsMnMaps("piControl","C20-Reanalysis",(/djf_field,jja_field/),wks,opt,opt_pan)
    end if
end if
frame(wks)
delete(wks)
delete([/opt,opt_pan/])