#!/bin/bash
#This file will download/update the input netcdf files that haave been created from running CVDP on PMIP4 

#move to data directory
this_dir=`basename $PWD`
if [ $this_dir == "scripts" ]
then 
  cd ../data
else
  cd data
fi

wget http://www2.geog.ucl.ac.uk/~ucfaccb/PMIPVarData/data/PMIP4_cvdp_enso.tar.gz
tar -xvf PMIP4_cvdp_enso.tar.gz