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
SCATTER_PCT_CHANGES=False ;if True, the scatterplots present the changes as percentages.
OUTPUT_TYPE="pdf"; either "png" or "pdf"
GCM_DICTIONARY=False; if True, will not print model names, but alphabetic look up from table
troppac_region=(/(/-25.,25./),(/100.,280./)/);lat and lons of the edge of the plots (/(/latS,latN/),(/lonW,lonE/)/)
expts=(/"piControl","historical","midHolocene","lgm","lig127k","1pctCO2","abrupt4xCO2"/)
expts_color=(/"grey60","black","darkgreen","dodgerblue4","yellowgreen","firebrick","orangered2"/)
n_expts=dimsizes(expts)-2

;set up an array to hold the output data
fnames_pictl=find_files_wVar("piControl","nino34")
num_pictl=dimsizes(fnames_pictl)
d_enso_tele_pr=new(num_pictl*n_expts,float);array to hold variability change
d_MeridSSTGrad=new(num_pictl*n_expts,float);array to hold mean state change

do expt_i=0,n_expts-1
  this_expt=expts(expt_i+2)
  fnames_both=find_pair_files_wVar(this_expt,"piControl","nino34")
  n_models=dimsizes(fnames_both(:,0))
  enso_tele_pr=new((/n_models,3/),float)
  MeridSSTGrad=new((/n_models,3/),float)
  gcm_names=new(n_models,string)

  do i=0,n_models-1
    a_nopath=str_get_field(fnames_both(i,0),str_fields_count(fnames_both(i,0),"/"),"/")
    gcm_names(i)=str_get_field(str_sub_str(a_nopath,"_"+this_expt,":"),1,":")
    Y=extract_latlon_areastat(fnames_both(i,0),"nino34_spacomp_pr_djf1",\
      (/-5.,5./),(/210.,270./),"mean")
    enso_tele_pr(i,0)=(/Y/Y@composited_avg_ampl/)
    Y=extract_latlon_areastat(fnames_both(i,1),"nino34_spacomp_pr_djf1",\
      (/-5.,5./),(/210.,270./),"mean")
    enso_tele_pr(i,1)=(/Y/Y@composited_avg_ampl/)
    delete(Y)
    if VERBOSE then
      print(gcm_names(i)+" in "+this_expt+" = "+enso_tele_pr(i,0)+" & "+enso_tele_pr(i,1)+" giving a ratio of "+\
      (enso_tele_pr(i,0)-enso_tele_pr(i,1))/enso_tele_pr(i,1)*100.+"%") 
    end if
    X1=extract_latlon_areastat(fnames_both(i,0),"sst_spatialmean_djf",(/5.,10./),(/210.,270./),"mean")
    X2=extract_latlon_areastat(fnames_both(i,0),"sst_spatialmean_djf",(/-2.5,2.5/),(/210.,270./),"mean")
    MeridSSTGrad(i,0)=(/X1-X2/)
    X1=extract_latlon_areastat(fnames_both(i,1),"sst_spatialmean_djf",(/5.,10./),(/210.,270./),"mean")
    X2=extract_latlon_areastat(fnames_both(i,1),"sst_spatialmean_djf",(/-2.5,2.5/),(/210.,270./),"mean")
    MeridSSTGrad(i,1)=(/X1-X2/)
    delete([/X1,X2/])
    if VERBOSE then
      print(gcm_names(i)+" in "+this_expt+" = Merid SST Grad of "+MeridSSTGrad(i,0)+" (vs "+MeridSSTGrad(i,1)+")") 
    end if
    if SCATTER_PCT_CHANGES then
      d_enso_tele_pr(expt_i*num_pictl+i)=100.*(enso_tele_pr(i,0)-enso_tele_pr(i,1))/enso_tele_pr(i,1)
      d_MeridSSTGrad(expt_i*num_pictl+i)=100.*(MeridSSTGrad(i,0)-MeridSSTGrad(i,1))/MeridSSTGrad(i,1)
    else
      d_enso_tele_pr(expt_i*num_pictl+i)=enso_tele_pr(i,0)-enso_tele_pr(i,1)
      d_MeridSSTGrad(expt_i*num_pictl+i)=MeridSSTGrad(i,0)-MeridSSTGrad(i,1)
    end if
    delete([/a_nopath/])
  end do
  delete([/fnames_both,enso_tele_pr,MeridSSTGrad,gcm_names/])
end do

;create the scatter plot
wks = gsn_open_wks(OUTPUT_TYPE,plots_dir+"scatter_enso_tele_pr_vs_MeridSSTGrad")
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
  res@tiYAxisString   = "Change in Nino3 Rainfall (%)"
  res@tiXAxisString   = "Change in Meridional SST Gradient (%)"
else
  res@tiYAxisString   = "Nino3 Composite Rainfall (mm/day/oC)"
  res@tiXAxisString   = "Meridional SST Gradient Change (oC)"
end if
res@trYMaxF=max(d_enso_tele_pr)
res@trYMinF=min(d_enso_tele_pr)
res@trXMaxF=max(d_MeridSSTGrad)
res@trXMinF=min(d_MeridSSTGrad)
  
;disappointingly the overlaying is not working, so we need a manual loop here...
res@xyMarkerColor =  expts_color(2)
plot = gsn_csm_xy(wks,d_MeridSSTGrad(0:num_pictl-1),d_enso_tele_pr(0:num_pictl-1),res)
draw(plot)
if n_expts.gt.1 then
    res@xyMarkerColor =  expts_color(2+1) 
    plot1 = gsn_csm_xy(wks,d_MeridSSTGrad(1*num_pictl:(1+1)*num_pictl-1),d_enso_tele_pr(1*num_pictl:(1+1)*num_pictl-1),res)
    draw(plot1)
    ;overlay(plot1,plot)
end if
if n_expts.gt.2 then
    res@xyMarkerColor =  expts_color(2+2) 
    plot2 = gsn_csm_xy(wks,d_MeridSSTGrad(2*num_pictl:(2+1)*num_pictl-1),d_enso_tele_pr(2*num_pictl:(2+1)*num_pictl-1),res)
    draw(plot2)
    ;overlay(plot2,plot)
end if
if n_expts.gt.3 then
    res@xyMarkerColor =  expts_color(2+3) 
    plot3 = gsn_csm_xy(wks,d_MeridSSTGrad(3*num_pictl:(3+1)*num_pictl-1),d_enso_tele_pr(3*num_pictl:(3+1)*num_pictl-1),res)
    draw(plot3)
    ;overlay(plot3,plot)
end if
if n_expts.gt.4 then
    res@xyMarkerColor =  expts_color(2+4) 
    plot4 = gsn_csm_xy(wks,d_MeridSSTGrad(4*num_pictl:(4+1)*num_pictl-1),d_enso_tele_pr(4*num_pictl:(4+1)*num_pictl-1),res)
    draw(plot4)
    ;overlay(plot4,plot)
end if
if n_expts.gt.5 then
    res@xyMarkerColor =  expts_color(2+5) 
    plot5 = gsn_csm_xy(wks,d_MeridSSTGrad(5*num_pictl:(5+1)*num_pictl-1),d_enso_tele_pr(5*num_pictl:(5+1)*num_pictl-1),res)
    draw(plot5)
    ;overlay(plot5,plot)
end if
if n_expts.gt.6 then
    res@xyMarkerColor =  expts_color(2+6) 
    plot6 = gsn_csm_xy(wks,d_MeridSSTGrad(6*num_pictl:(6+1)*num_pictl-1),d_enso_tele_pr(6*num_pictl:(6+1)*num_pictl-1),res)
    draw(plot6)
    ;overlay(plot6,plot)
end if
if n_expts.gt.7 then
    res@xyMarkerColor =  expts_color(2+7) 
    plot7 = gsn_csm_xy(wks,d_MeridSSTGrad(7*num_pictl:(7+1)*num_pictl-1),d_enso_tele_pr(7*num_pictl:(7+1)*num_pictl-1),res)
    draw(plot7)
    ;overlay(plot7,plot)
end if
if n_expts.gt.8 then
    res@xyMarkerColor =  expts_color(2+8) 
    plot8 = gsn_csm_xy(wks,d_MeridSSTGrad(8*num_pictl:(8+1)*num_pictl-1),d_enso_tele_pr(8*num_pictl:(8+1)*num_pictl-1),res)
    draw(plot8)
    ;overlay(plot8,plot)
end if

frame(wks)
delete(wks)
