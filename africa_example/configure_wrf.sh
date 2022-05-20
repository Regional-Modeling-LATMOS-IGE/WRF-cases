#!/bin/bash
#-------- Set everything for WRF compilation --------
# Léo Clauzel (leo.clauzel@univ-grenoble-alpes.fr)
#09.03.2022

#---Select WRF version---
WRF_V='WRF_4.3.3'

#---Load module---
module purge
module load openmpi/1.6.5-ifort
module load netcdf4/4.3.3.1-ifort
module load hdf5/1.8.14-ifort
module list
echo "==> Module loading completed"
echo "****************************"

#---Export variable---
#Set environment variable
export NETCDF="/opt/netcdf43/ifort"
export NETCDF_LIB="$NETCDF/lib"
export NETCDF_INC="$NETCDF/include"
export OPENMPI='/usr/lib64/openmpi/1.6.5-ifort'
export JASPERLIB="/usr/lib64"
export JASPERINC="/usr/include/japser"
export LDFLAGS="-L$OPENMPI/lib -lmpi"
export CFLAGS="-I$OPENMPI/include -m64"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$NETCDF_LIB"

#UNIX Environment Settings
export WRF_EM_CORE=1
export WRF_NMM_CORE=0
export WRFIO_NCD_LARGE_FILE_SUPPORT=1
ulimit -s unlimited
ulimit unlimited
echo "==> Export variable and UNIX environment settings completed"
echo "*****************************"

#---Configure WRF---
echo "Select ifort+icc with dmpar (15), and basic nesting (1)"
DIR=$PWD
WRF_DIR="$DIR/WRF/$WRF_V"
cd $WRF_DIR
./configure
cd $DIR
echo "==> WRF configuration completed"
echo "*******************************"
