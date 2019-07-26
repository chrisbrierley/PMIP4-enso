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

## Responsibilities
# The paper current paper outline, and who is responsible for the various sections
1. Introduction & Literature Review
  * Led by Soon-Il, with support from Sam and Jo
2. Methods
  * Led by Chris with support from Charlie and Sam
3. Model Evaluation
  * Led by Sam, with support from Qiong and Soon-Il
4. Mean state changes
  * Led by Vittoria (LIG) with support from Charlie (midHolocene), Qiong (LGM), Jo (Future)
5. Teleconnection pattern changes
  * Led by Jo with support from Vittoria and Chris
6. ENSO Diversity (if required) 
  * Led by Sam, with support from Chris and Soon-Il
7. Discussion & Mechanisms
  * Led by Soon-Il with support from Qiong and Jo
8. Conclusions
  * Led by Qiong with support from all
