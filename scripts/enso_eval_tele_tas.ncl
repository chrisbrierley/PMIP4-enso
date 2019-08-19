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
expts=(/"piControl","historical","midHolocene","lgm","lig127k","1pctCO2","abrupt4xCO2"/)
expts_color=(/"grey60","black","darkgreen","dodgerblue4","yellowgreen","firebrick","orangered2"/)

djf_field="nino34_spacomp_tas_djf1"
jja_field="nino34_spacomp_tas_jja0"


wks=gsn_open_wks(OUTPUT_TYPE,plots_dir+"enso_eval_tele_tas")
wks@VERBOSE=VERBOSE
opt=True
  opt@cnLevelSelectionMode = "ManualLevels"   
  opt@cnMinLevelValF       = -2.5
  opt@cnMaxLevelValF       = 2.5
  opt@cnLevelSpacingF = 0.25
  cmap = read_colormap_file("MPL_RdBu")
  opt@cnFillPalette = cmap(::-1,:)     ; reverse color map
  opt@mpProjection="CylindricalEqualArea"
  opt@mpCenterLonF=180.
  opt@gsnLeftString=(/"a","b"/)
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
opt@gsnRightString="C20-Reanalysis "+(/"DJF","JJA"/)
plotCVDPcomparisonMaps("C20-Reanalysis",(/djf_field,jja_field/),wks,opt,opt_pan)
opt@gsnLeftString=(/"c","d"/)
opt@gsnRightString="historical "+(/"DJF","JJA"/)
if INC_PREIND_wHIST then
  opt_pan@gsnPanelTop=0.66
  opt_pan@gsnPanelBottom=0.33
else
  opt_pan@gsnPanelBottom=0.0
  opt_pan@gsnPanelTop=0.5
end if
opt_pan@dims=(/1,2/)
plotCVDPcomparisonMaps("historical",(/djf_field,jja_field/),wks,opt,opt_pan)
if INC_PREIND_wHIST then
    opt@gsnLeftString=(/"e","f"/)
    opt@gsnRightString="piControl "+(/"DJF","JJA"/)
    opt_pan@gsnPanelBottom=0.0
    opt_pan@gsnPanelTop=0.33
    opt_pan@dims=(/1,2/)
    plotCVDPcomparisonMaps("piControl",(/djf_field,jja_field/),wks,opt,opt_pan)
end if
frame(wks)
delete(wks)
delete([/opt,opt_pan/])