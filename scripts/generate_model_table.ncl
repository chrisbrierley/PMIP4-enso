;This script was used to block out some figures to populate a research publication on ENSO
;It makes full use of the programs in cvdp_data.functions.ncl to plot figures solely from the output data of cvdp (without needing recomputation).
; It makes 1 table (showing simulations used) and many figures. 

;load some functions
present_dir=systemfunc("pwd")
if ismissing(str_match_ind(present_dir,"scripts")) then
  loadscript("./scripts/cvdp_enso.functions.ncl")
else
  loadscript("./cvdp_enso.functions.ncl")
end if

GCM_DICTIONARY=False; if True, will not print model names, but alphabetic look up from table
if GCM_DICTIONARY then
  gcm_dict=createGCMsNameDictionary(expts,"nino34")
end if

if ismissing(str_match_ind(present_dir,"scripts")) then
  plots_dir=present_dir+"/plots/"
else
  plots_dir=present_dir+"/../plots/"
end if

expts=(/"piControl","historical","midHolocene-cal-adj","lgm-cal-adj","lig127k-cal-adj","1pctCO2","abrupt4xCO2"/)
if GCM_DICTIONARY then
  createTableGCMsExptsYears(expts,"nino34",gcm_dict,"tex",plots_dir+"model_table.tex")
else
  createTableGCMsExptsYears(expts,"nino34",False,"tex",plots_dir+"model_table.tex")
end if