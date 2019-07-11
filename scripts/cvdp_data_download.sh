#!/bin/bash
#This file will download/update the input netcdf files that haave been created from running CVDP on PMIP4 

cd ../data
wget http://www2.geog.ucl.ac.uk/~ucfaccb/PMIPVarData/data/PMIP4_enso_data.tar.gz
tar -xvf PMIP4_enso_data.tar.gz