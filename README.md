# PMIP4-enso
# Simulated past changes in the El Nino-Southern Oscillation
A collaborative effort of the past2future variability working group of the Palaeoclimate Modelling Intercomparison Project

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/chrisbrierley/PMIP4-enso/master)

## Repo structure
This repository holds only the analysis code to investigate ENSO. It does not contain either the data or plots, rather a container for holding. It is anticipated that users will create alocal copy of this and then download/create the images. The main language for this repository is NCL.
  - data/ contains the netcdf output from running NCARs Climate Variability Diagnsotics Package
  - scripts/ contains separate programs to make each possible figure, along other miscellaneous tasks
  - plots/ is currently empty, but would contain the output of other diagnostics

Note: to run the NCL scripts use the command `ncl scriptname.ncl`. You will need NCL>6.4, which be installed the necessary environment for this repository with `conda create --name pmip4-enso --file environment.yml` and activated with `source activate pmip4-enso`.
