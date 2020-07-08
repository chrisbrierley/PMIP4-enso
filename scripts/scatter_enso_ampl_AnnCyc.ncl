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
VERBOSE=True ;if True, provides a modicum of more information about whats going on in the plots - used for debugging mainly.
SCATTER_PCT_CHANGES=True ;if True, the scatterplots present the changes as percentages.
OUTPUT_TYPE="pdf"; either "png" or "pdf"
GCM_DICTIONARY=False; if True, will not print model names, but alphabetic look up from table
troppac_region=(/(/-25.,25./),(/100.,280./)/);lat and lons of the edge of the plots (/(/latS,latN/),(/lonW,lonE/)/)
expts=(/"piControl","historical","midHolocene","lgm","lig127k","1pctCO2","abrupt4xCO2"/)
expts_color=(/"grey60","black","darkgreen","dodgerblue4","yellowgreen","firebrick","orangered2"/)
n_expts=dimsizes(expts)-2

;set up an array to hold the output data
fnames_pictl=find_files_wVar("piControl","nino34")
num_pictl=dimsizes(fnames_pictl)
d_stddev=new(num_pictl*n_expts,float);array to hold variability change
d_index=new(num_pictl*n_expts,float);array to hold mean state change

do expt_i=0,n_expts-1
  this_expt=expts(expt_i+2)
  fnames_both=find_pair_files_wVar(this_expt,"piControl","nino34")
  n_models=dimsizes(fnames_both(:,0))
  mode_sds=new((/n_models,3/),float)
  AnnCycAmp=new((/n_models,3/),float)
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
    mode_sds(i,0)=(/stat_ts_var(fnames_both(i,0),"nino34","stddev_bandpass_2-8yrs",True)/)
    mode_sds(i,1)=(/stat_ts_var(fnames_both(i,1),"nino34","stddev_bandpass_2-8yrs",False)/)
    if VERBOSE then
      print(gcm_names(i)+" in "+this_expt+" = NINO34 stddev of "+mode_sds(i,0)+" vs "+mode_sds(i,1)+" giving a ratio of "+\
      (mode_sds(i,0)-mode_sds(i,1))/mode_sds(i,1)*100.+"%") 
    end if
    AnnCycAmp(i,0)=(/stat_ts_var(fnames_both(i,0),"nino34","AnnCycAmp",True)/)
    AnnCycAmp(i,1)=(/stat_ts_var(fnames_both(i,1),"nino34","AnnCycAmp",False)/)
    if VERBOSE then
      print(gcm_names(i)+" in "+this_expt+" = Annual Cycle of "+AnnCycAmp(i,0)+" (vs "+AnnCycAmp(i,1)+")"+" giving a ratio of "+\
      (AnnCycAmp(i,0)-AnnCycAmp(i,1))/AnnCycAmp(i,1)*100.+"%") 
    end if
    if SCATTER_PCT_CHANGES then
      d_stddev(expt_i*num_pictl+i)=100.*(mode_sds(i,0)-mode_sds(i,1))/mode_sds(i,1)
      d_index(expt_i*num_pictl+i)=100.*(AnnCycAmp(i,0)-AnnCycAmp(i,1))/AnnCycAmp(i,1)
    else
      d_stddev(expt_i*num_pictl+gcm_i)=mode_sds(i,0)-mode_sds(i,1)
      d_index(expt_i*num_pictl+gcm_i)=AnnCycAmp(i,0)-AnnCycAmp(i,1)
    end if
    delete([/a_nopath/])
  end do
  delete([/fnames_both,mode_sds,AnnCycAmp,gcm_names,ts_opt/])
end do

;create the scatter plot
wks = gsn_open_wks(OUTPUT_TYPE,plots_dir+"scatter_enso_ampl_AnnCyc")
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
  res@tiYAxisString   = "ENSO Amplitude Change (%)"
  res@tiXAxisString   = "Annual Cycle Change (%)"
else
  res@tiYAxisString   = "ENSO Amplitude Change"
  res@tiXAxisString   = "Annual Cycle Change"
end if
res@trYMaxF=max(d_stddev)
res@trYMinF=min(d_stddev)
res@trXMaxF=max(d_index)
res@trXMinF=min(d_index)
  
;disappointingly the overlaying is not working, so we need a manual loop here...
res@xyMarkerColor =  expts_color(2)
plot = gsn_csm_xy(wks,d_index(0:num_pictl-1),d_stddev(0:num_pictl-1),res)
draw(plot)
if n_expts.gt.1 then
    res@xyMarkerColor =  expts_color(2+1) 
    plot1 = gsn_csm_xy(wks,d_index(1*num_pictl:(1+1)*num_pictl-1),d_stddev(1*num_pictl:(1+1)*num_pictl-1),res)
    draw(plot1)
    ;overlay(plot1,plot)
end if
if n_expts.gt.2 then
    res@xyMarkerColor =  expts_color(2+2) 
    plot2 = gsn_csm_xy(wks,d_index(2*num_pictl:(2+1)*num_pictl-1),d_stddev(2*num_pictl:(2+1)*num_pictl-1),res)
    draw(plot2)
    ;overlay(plot2,plot)
end if
if n_expts.gt.3 then
    res@xyMarkerColor =  expts_color(2+3) 
    plot3 = gsn_csm_xy(wks,d_index(3*num_pictl:(3+1)*num_pictl-1),d_stddev(3*num_pictl:(3+1)*num_pictl-1),res)
    draw(plot3)
    ;overlay(plot3,plot)
end if
if n_expts.gt.4 then
    res@xyMarkerColor =  expts_color(2+4) 
    plot4 = gsn_csm_xy(wks,d_index(4*num_pictl:(4+1)*num_pictl-1),d_stddev(4*num_pictl:(4+1)*num_pictl-1),res)
    draw(plot4)
    ;overlay(plot4,plot)
end if
if n_expts.gt.5 then
    res@xyMarkerColor =  expts_color(2+5) 
    plot5 = gsn_csm_xy(wks,d_index(5*num_pictl:(5+1)*num_pictl-1),d_stddev(5*num_pictl:(5+1)*num_pictl-1),res)
    draw(plot5)
    ;overlay(plot5,plot)
end if
if n_expts.gt.6 then
    res@xyMarkerColor =  expts_color(2+6) 
    plot6 = gsn_csm_xy(wks,d_index(6*num_pictl:(6+1)*num_pictl-1),d_stddev(6*num_pictl:(6+1)*num_pictl-1),res)
    draw(plot6)
    ;overlay(plot6,plot)
end if
if n_expts.gt.7 then
    res@xyMarkerColor =  expts_color(2+7) 
    plot7 = gsn_csm_xy(wks,d_index(7*num_pictl:(7+1)*num_pictl-1),d_stddev(7*num_pictl:(7+1)*num_pictl-1),res)
    draw(plot7)
    ;overlay(plot7,plot)
end if
if n_expts.gt.8 then
    res@xyMarkerColor =  expts_color(2+8) 
    plot8 = gsn_csm_xy(wks,d_index(8*num_pictl:(8+1)*num_pictl-1),d_stddev(8*num_pictl:(8+1)*num_pictl-1),res)
    draw(plot8)
    ;overlay(plot8,plot)
end if

frame(wks)
delete(wks)
