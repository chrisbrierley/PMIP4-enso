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
expts=(/"piControl","historical","midHolocene-cal-adj","lgm-cal-adj","lig127k-cal-adj","1pctCO2","abrupt4xCO2"/)
expts_color=(/"grey60","black","darkgreen","dodgerblue4","yellowgreen","firebrick","orangered2"/)
plot_letters=(/(/"a","b"/),(/"c","d"/),(/"e","f"/),(/"g","h"/),(/"i","j"/),(/"k","l"/)/)
CONSISTENCY=True
OVERLAY_PREIND=True
OVERLAY_PREIND_MANUALLEV=(/0,12,2/);ie 0:12:2 mm/day

djf_field="nino34_spacomp_pr_djf1"
jja_field="nino34_spacomp_pr_jja0"


wks=gsn_open_wks(OUTPUT_TYPE,plots_dir+"enso_changes_tele_pr")
wks@VERBOSE=VERBOSE
opt=True
  opt@mpProjection="CylindricalEqualArea"
  opt@mpCenterLonF=180.
  opt@lbLabelBarOn=False
  opt@tiMainString=""
  opt@gsnCenterString=""
  opt@cnFillPalette="CBR_drywet"
  opt@cnLevelSelectionMode = "ExplicitLevels"   
  opt@cnLevels=(/-5.,-2.,-1.,-0.5,-0.1,0.1,0.5,1.,2.,5./)
  opt@gsnStringFontHeightF=0.03
  opt@CONSISTENCY=CONSISTENCY ;Turn on stippling
  opt@OVERLAY_CONTROL=OVERLAY_PREIND
  opt@OVERLAY_CONTROL_MANUALLEVS=OVERLAY_PREIND_MANUALLEV
opt_pan=True
  opt_pan@lbTitleOn=False
  opt_pan@lbOrientation = "vertical"
  opt_pan@gsnPanelLabelBar=True
  opt_pan@gsnFrame=False
  opt_pan@lbTitleString="Precip. Difference (mm/day)"
  opt_pan@lbLabelFontHeightF=0.016
  opt_pan@dims=(/1,2/)

n_expts=dimsizes(expts)-2
do i=0,n_expts-1
  opt@gsnLeftString=plot_letters(i,:)
  opt@gsnRightString=expts(i+2)+(/" DJF"," JJA"/)
  opt_pan@gsnPanelBottom=tofloat(i)/n_expts
  opt_pan@gsnPanelTop=tofloat(i+1)/n_expts
  plotDiffEnsMnMaps(expts(i+2),expts(0),(/djf_field,jja_field/),wks,opt,opt_pan)
end do

frame(wks)
delete(wks)
delete([/opt,opt_pan/])