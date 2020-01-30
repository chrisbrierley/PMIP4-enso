# PMIP4-enso
# Simulated past changes in the El Nino-Southern Oscillation
A collaborative effort of the past2future variability working group of the Palaeoclimate Modelling Intercomparison Project

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/chrisbrierley/PMIP4-enso/master)

A manuscript based on this repository has been submitted to Climate of the Past. I will be probably be available as a discusison paper from [https://www.clim-past-discuss.net/cp-2019-155](https://www.clim-past-discuss.net/cp-2019-155).

This manuscript and repository should be referenced as:
  - "Comparison of past and future simulations of ENSO in CMIP5/PMIP3 and CMIP6/PMIP4 models” by Josephine R. Brown, Chris M. Brierley, Soon-Il An, Maria-Vittoria Guarino, Samantha Stevenson, Charles J. R. Williams, Qiong Zhang, Anni Zhao, Pascale Braconnot, Esther C. Brady, Deepak Chandan, Roberta D'Agostino, Chuncheng Guo, Allegra N. LeGrande, Gerrit Lohmann, Polina A. Morozova, Rumi Ohgaito, Ryouta O'ishi, Bette Otto-Bliesner, W. Richard Peltier, Xiaoxu Shi, Louise Sime, Evgeny M. Volodin, Zhongshi Zhang, and Weipeng Zheng





## Repo structure
This repository holds only the analysis code to investigate ENSO. It does not contain either the data or plots, rather a container for holding. It is anticipated that users will create alocal copy of this and then download/create the images. The main language for this repository is NCL.
  - data/ contains the netcdf output from running NCARs Climate Variability Diagnsotics Package
  - scripts/ contains separate programs to make each possible figure, along other miscellaneous tasks
  - plots/ is currently empty, but would contain the output of other diagnostics

Note: to run the NCL scripts use the command `ncl scriptname.ncl`. You will need NCL>6.4, which be installed the necessary environment for this repository with `conda create --name pmip4-enso --file environment.yml` and activated with `source activate pmip4-enso`.
