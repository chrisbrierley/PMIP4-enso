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
OUTPUT_TYPE="png"; either "png" or "pdf"
GCM_DICTIONARY=False; if True, will not print model names, but alphabetic look up from table
troppac_region=(/(/-25.,25./),(/100.,280./)/);lat and lons of the edge of the plots (/(/latS,latN/),(/lonW,lonE/)/)
expts=(/"piControl","historical","midHolocene","lgm","lig127k","1pctCO2","abrupt4xCO2"/)
expts_color=(/"grey60","black","darkgreen","dodgerblue4","yellowgreen","firebrick","orangered2"/)
n_expts=dimsizes(expts)-2

do expt_i=0,n_expts-1
  this_expt=expts(expt_i+2)
  fnames_both=find_pair_files_wVar(this_expt,"piControl","nino34")
  n_models=dimsizes(fnames_both(:,0))
  mode_sds=new((/n_models,3/),float)
  gcm_names=new(n_models,string)
  ts_opt=True
  ts_opt@NO_EXIT_ON_ERROR=True
  if any(this_expt.eq.(/"1pctCO2","abrupt4xCO2","rcp26","rcp85"/)) then
    ts_opt@subset=True
    ts_opt@subset_syear=-50
    ts_opt@subset_eyear=0
    ;ts_opt@renorm_climo=False
    ;ts_opt@renorm_climo_syear=-30
    ;ts_opt@renorm_climo_eyear=0
    ts_opt@DETREND=False
  end if

  do i=0,n_models-1
    a_nopath=str_get_field(fnames_both(i,0),str_fields_count(fnames_both(i,0),"/"),"/")
    gcm_names(i)=str_get_field(str_sub_str(a_nopath,"_"+this_expt,":"),1,":")
    mode_sds(i,0)=(/stat_ts_var(fnames_both(i,0),"nino34_runstddev","mean",True)/)
    mode_sds(i,1)=(/stat_ts_var(fnames_both(i,1),"nino34_runstddev","mean",False)/)
    if VERBOSE then
      print(gcm_names(i)+" in "+this_expt+" = "+mode_sds(i,0)+" & "+mode_sds(i,1)+" giving a ratio of "+\
      (mode_sds(i,0)-mode_sds(i,1))/mode_sds(i,1)*100.+"%") 
    end if
  end do
  mode_sds(:,2)=(mode_sds(:,0)-mode_sds(:,1))/mode_sds(:,1)*100.
  print("Ensemble mean change in "+this_expt+" = "+avg(mode_sds(:,2))+"%") 
  

  plot_res = True
  plot_res@trYMinF = 0.
  plot_res@vpWidthF = 0.9
  plot_res@vpHeightF = 0.33
  plot_res@gsnDraw = False
  plot_res@gsnFrame=False
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
    plot_res@tmXBLabels = gcm_names
    plot_res@tmXBLabelFontHeightF = 0.012
  end if
  plot_res@tmXBLabelDirection="Down"
  plot_res@trXMinF = 0.5
  plot_res@trXMaxF = n_models+0.5
  plot_res@trYMinF = 0.0
  plot_res@trYMaxF = 1.5
  plot_res@gsnYRefLine=0.
  plot_res@gsnXYBarChartBarWidth = 0.4
  left_locations=fspan(0.5,n_models-0.5,n_models)+0.3
  right_locations=left_locations+0.4
  
  wks = gsn_open_wks(OUTPUT_TYPE,plots_dir+this_expt+"_enso_amplitude_change")
  plot_res@tiYAxisString = "nino34"+" ~F33~s~F21~ (~F35~J~F21~C)"
  plot_res@gsnXYBarChartColors=expts_color(expt_i+2)
  mode_baseplot = gsn_csm_xy(wks,left_locations,mode_sds(:,0),plot_res)
  plot_res@gsnXYBarChartColors=expts_color(0)
  mode_oplot = gsn_csm_xy(wks,right_locations,mode_sds(:,1),plot_res)
  overlay(mode_baseplot,mode_oplot)

  plot_res@tiYAxisString = "Change in ~F33~s~F21~ (%)"
  plot_res@gsnXYBarChartColors="orange2"
  plot_res@trYMaxF = 50.
  plot_res@trYMinF = -50.
  diff_baseplot = gsn_csm_xy(wks,left_locations,mode_sds(:,2),plot_res)

  resP=True
  resP@gsnMaximize=True
  if .not.GCM_DICTIONARY then
    resP@gsnPanelYWhiteSpacePercent = 20.0
  end if
  gsn_panel(wks,(/mode_baseplot,diff_baseplot/),(/2,1/),resP)
  delete([/wks,resP,plot_res,mode_baseplot,diff_baseplot,ts_opt/])
  delete([/mode_oplot,fnames_both,n_models,mode_sds,gcm_names,left_locations,right_locations/])
end do ;BARCHART