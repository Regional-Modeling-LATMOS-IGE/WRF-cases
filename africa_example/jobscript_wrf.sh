#!/bin/bash
#-------- Set up and run real.exe and wrf.exe --------
#
# Léo CLAUZEL, 09/03/2022
#

# Resources used
#PBS -l "nodes=1:ppn=4"
#PBS -l vmem=32G
#PBS -l mem=32G
#PBS -q day
#PBS -j oe


#-------- Input -------
#WRF version
WRF_V='WRF_4.3.3'
# Root directory with the compiled WRF executables (main/wrf.exe and main/real.exe)
WRF_SRC_DIR="/home/lclauzel/WRF_setup/WRF/$WRF_V"

# Root directory for WRF output
OUT_DIR="/scratchu/lclauzel/WRF_output"
#Give a name to the work case
CASENAME="africa_example"
#Directory for this test output
WRF_OUT_DIR="${OUT_DIR}/${CASENAME}"

# Namelist file (must be in the same directory as this job script)
NAMELIST="namelist.input.africa"

#-------- Set up job environment --------
JOB_DIR=$PBS_O_WORKDIR
cd $JOB_DIR

# Load modules used for WRFChem compilation
module purge   # clear any inherited modules
module load openmpi/1.6.5-ifort
module load hdf5/1.8.14-ifort
module load netcdf4/4.3.3.1-ifort
NETCDF_ROOT='/opt/netcdf43/ifort'
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$NETCDF_ROOT/lib"
ulimit -s unlimited
ulimit unlimited

#-------- Run real, WRF  --------
# Copy the WRF run directory (contains auxilliary files etc.) and the REAL &
# WRF executables to $SCRATCH/
cp "$WRF_SRC_DIR/run/"* $WRF_OUT_DIR

#  Prepare the WRF namelist
cp "$JOB_DIR/$NAMELIST" "$WRF_OUT_DIR/"namelist.input

cd $WRF_OUT_DIR
#-------- Run real.exe  --------
mpirun real.exe

#-------- Run wrf.exe  --------
mpirun wrf.exe

