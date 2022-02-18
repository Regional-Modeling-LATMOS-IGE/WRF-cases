#!/bin/bash
#-------- Set up and run real.exe and wrf.exe for an Arctic example run  --------
#
# Shaddy Ahmed, 18/02/2022
#

# Resources used
#PBS -l "nodes=3:ppn=8"
#PBS -l vmem=32G
#PBS -l mem=32G
#PBS -q week
#PBS -j eo


#-------- Input --------
# Root directory with the compiled WRF executables (main/wrf.exe and main/real.exe)
WRFDIR='/scratchu/sahmed/WRFV4.1.2/'

# Root directory for WRF output
OUTDIR="/scratchu/sahmed/WRF_OUTPUT/WRF_EXAMPLE_RUN/"

# Namelist file (must be in the same directory as this job script)
NAMELIST="namelist.input.example"

# WPS directory with the metgrid files
WPSDIR="/data/sahmed/WRF_OUTPUT/METGRID_DUMP/"

#-------- Set up job environment --------
cd $PBS_O_WORKDIR

# Load modules used for WRFChem compilation
module purge   # clear any inherited modules
module load openmpi/1.6.5-ifort
module load hdf5/1.8.14-ifort
module load netcdf4/4.3.3.1-ifort
NETCDF_ROOT='/opt/netcdf43/ifort'
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$NETCDF_ROOT/lib"
# Must set large stack size (unlimited for simplicity)
ulimit -s unlimited
# Set ulimit also to unlimited (probably not necessary)
ulimit unlimited

#-------- Run real, WRF  --------
# Copy the WRF run directory (contains auxilliary files etc.) and the REAL &
# WRF executables to $SCRATCH/
cp "$WRFDIR/run/"* "$OUTDIR/"

# Copy met em files
ln -s "$WPSDIR/met_em"* "$OUTDIR/."

#  Prepare the WRF-Chem namelist
cp "$NAMELIST" "$OUTDIR/"namelist.input

# Copy files created by real.exe
##cp "$REALDIR/wrfbdy_d01" "$OUTDIR/."
##cp "$REALDIR/wrffdda_d01" "$OUTDIR/."
##cp "$REALDIR/wrfinput_d01" "$OUTDIR/."
##cp "$REALDIR/wrflowinp_d01" "$OUTDIR/."

cd $OUTDIR

#-------- Run real.exe  --------
mpirun real.exe

#-------- Run wrf.exe  --------
mpirun wrf.exe

