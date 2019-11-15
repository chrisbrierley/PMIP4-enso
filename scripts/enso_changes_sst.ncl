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
OUTPUT_TYPE="pdf"; either "png" or "pdf"
INC_PREIND_wHIST=True; adds the preindustrial to all the plots including the Historical 
troppac_region=(/(/-25.,25./),(/100.,280./)/);lat and lons of the edge of the plots (/(/latS,latN/),(/lonW,lonE/)/)
expts=(/"piControl","historical","midHolocene-cal-adj","lgm-cal-adj","lig127k-cal-adj","1pctCO2","abrupt4xCO2"/)
expts_color=(/"grey60","black","darkgreen","dodgerblue4","yellowgreen","firebrick","orangered2"/)
plot_letters=(/"a","b","c","d","e","f","g","h","i","j","k","l"/)
CONSISTENCY=True
OVERLAY_PREIND=True
OVERLAY_PREIND_MANUALLEV=(/-3,3,0.5/);ie 0:12:2 mm/day

  djf_field="sst_spatialmean_djf"
  jja_field="sst_spatialmean_jja"


wks=gsn_open_wks(OUTPUT_TYPE,plots_dir+"enso_changes_sst")
wks@VERBOSE=VERBOSE
opt=True
  opt@mpProjection="CylindricalEqualArea"
  opt@mpLimitMode="LatLon"
  opt@mpMinLonF=troppac_region(1,0)
  opt@mpMaxLonF=troppac_region(1,1)
  opt@mpMinLatF=troppac_region(0,0)
  opt@mpMaxLatF=troppac_region(0,1)
  opt@mpCenterLonF=180.
  opt@lbLabelBarOn=False
  opt@tiMainString=""
  opt@gsnCenterString=""
  opt@cnFillPalette="CBR_coldhot"
  opt@cnLevelSelectionMode = "ExplicitLevels"   
  opt@cnLevels=(/-1.5,-1.,-0.5,-0.25,-0.1,0.1,0.25,0.5,1.,1.5/)
  opt@gsnStringFontHeightF=0.03
  opt@CONSISTENCY=CONSISTENCY ;Turn on stippling
  opt@OVERLAY_CONTROL=OVERLAY_PREIND
  opt@OVERLAY_CONTROL_MANUALLEVS=OVERLAY_PREIND_MANUALLEV
  opt@NORMALISE=True
  opt@name_to_normalise_by="composited_avg_ampl"
opt_pan=True
  opt_pan@gsnFrame=False
  ;opt_pan@lbTitleString="ENSO Composite SST (oC)"
  opt_pan@lbTitleOn=False
  opt_pan@gsnPanelLabelBar=False

n_expts=dimsizes(expts)-2
do i=0,n_expts-1
  opt@gsnLeftString=plot_letters(i)
  opt@gsnRightString=expts(i+2)
  opt_pan@gsnPanelTop=1.0-0.92*(tofloat(i)/n_expts)
  opt_pan@gsnPanelBottom=1.0-0.92*(tofloat(i+1)/n_expts)
  if i.eq.(n_expts-1) then
    ;opt_pan@lbTitleOn=True
    opt_pan@gsnPanelLabelBar=True
    opt_pan@gsnPanelBottom=0.0
  end if
  plotDiffEnsMnMaps(expts(i+2),expts(0),"nino34_spacomp_sst_ann",wks,opt,opt_pan)
end do

frame(wks)
delete(wks)
delete([/opt,opt_pan/])