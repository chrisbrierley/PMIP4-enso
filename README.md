# PMIP4-enso
# Simulated past changes in the El Nino-Southern Oscillation
A collaborative effort of the past2future variability working group of the Palaeoclimate Modelling Intercomparison Project

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/chrisbrierley/PMIP4-enso/master)

This repository supports a manuscript in Climate of the Past, which will be available at [https://doi.org/10.5194/cp-2019-155](https://doi.org/10.5194/cp-2019-155).

This manuscript and repository should be referenced as:
  - "Brown, J. R., Brierley, C. M., An, S.-I., Guarino, M.-V., Stevenson, S., Williams, C. J. R., Zhang, Q., Zhao, A., Braconnot, P., Brady, E. C., Chandan, D., D'Agostino, R., Guo, C., LeGrande, A. N., Lohmann, G., Morozova, P. A., Ohgaito, R., O'ishi, R., Otto-Bliesner, B., Peltier, W. R., Shi, X., Sime, L., Volodin, E. M., Zhang, Z., and Zheng, W.: Comparison of past and future simulations of ENSO in CMIP5/PMIP3 and CMIP6/PMIP4 models, Clim. Past., https://doi.org/10.5194/cp-2019-155, accepted, 2020.





## Repo structure
This repository holds only the analysis code to investigate ENSO. It does not contain either the data or plots, rather a container for holding them. It is anticipated that users will create a local copy of this and then download/create the images. The main language for this repository is NCL. 
  - data/ contains the netcdf output from running NCARs Climate Variability Diagnsotics Package. Running scripts/download_cvdp_enso_data.sh will populate this directory.
  - scripts/ contains separate programs to make each possible figure, along other miscellaneous tasks
  - plots/ is currently empty, but would contain the output of other diagnostics

Note: to run the NCL scripts use the command `ncl scriptname.ncl`. You will need NCL>6.4, which be installed the necessary environment for this repository with `conda create --name pmip4-enso --file environment.yml` and activated with `source activate pmip4-enso`.
