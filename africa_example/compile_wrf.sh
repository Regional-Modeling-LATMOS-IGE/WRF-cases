#!/bin/bash
#-------------------- Script to compile WRF code-----------------------------
# Léo Clauzel (leo.clauzel@univ-grenoble-alpes.fr)
#09.03.2022

# Resources used
#PBS -l nodes=1:ppn=1
#PBS -l mem=8gb
#PBS -l vmem=8gb
#PBS -q std
#PBS -j oe

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

#---Compile WRF---
DIR=$PBS_O_WORKDIR
cd $DIR/WRF/$WRF_V
./compile em_real 2>&1 | tee compile.log
cd $DIR
