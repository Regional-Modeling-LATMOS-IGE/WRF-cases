#!/bin/bash
#-------- Set up and run WPS for the Africa example simulations--------
#
# Léo Clauzel, 18/02/2022
#

# Resources used
#PBS -l "nodes=1:ppn=1"
#PBS -l vmem=32G
#PBS -l mem=32G
#PBS -q short
#PBS -j oe

#------ Input --------
#WPS version
WPS_V='WPS_4.3.1'
#Give a name to the work case
CASENAME="africa_example"
#Job directory
JOB_DIR=$PBS_O_WORKDIR
# Directory containing the WPS executables and inputs
WPS_SRC_DIR="/home/lclauzel/WRF_setup/WPS/$WPS_V"
# Name of the WPS namelist file
NAMELIST="namelist.wps.africa"
# Output directory
OUT_DIR="/scratchu/lclauzel/WRF_output"

#-------- Set up job environment --------
cd $JOB_DIR
echo $JOB_DIR

# Load modules used for WRF compilation
module purge   # clear any inherited modules
module load openmpi/1.6.5-ifort
module load hdf5/1.8.14-ifort
module load netcdf4/4.3.3.1-ifort
NETCDF='/opt/netcdf43/ifort'
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$NETCDF/lib"
ulimit -s unlimited
ulimit unlimited

#-------- Set up WPS input and output directories & files  --------
# Directory containing WPS output (i.e. met_em files)
# Make output directory
WPS_OUT_DIR="${OUT_DIR}/${CASENAME}"
if [ -d $WPS_OUT_DIR ]
then
  echo "WARNING : directory '$WPS_OUT_DIR' already exists, may overwrite"
else
  mkdir $WPS_OUT_DIR
fi

# Save this SLURM script to the output directory
cp jobscript_wps.sh $WPS_OUT_DIR/jobscript_wps.sh

# Also create a temporary run directory
SCRATCH="${WPS_OUT_DIR}.job"
mkdir $SCRATCH
cd $SCRATCH
echo "Running on $SCRATCH"

#  Prepare the WPS namelist
cp $JOB_DIR/$NAMELIST $NAMELIST

#-------- Run geogrid -------
echo "-------- Running geogrid.exe --------"
mkdir geogrid
ln -sf "$WPS_SRC_DIR/geogrid/GEOGRID.TBL" geogrid/GEOGRID.TBL
cp "$WPS_SRC_DIR/geogrid.exe" .
cp $NAMELIST namelist.wps
mpirun geogrid.exe
# Clean up
rm -f geogrid.exe
rm -rf geogrid


#-------- Run ungrib --------
echo "-------- Running ungrib.exe for FILE --------"
# Create a directory containing links to the grib files of interest  
mkdir grib_links
GRIB_DIR_FILE="/data/lclauzel/DATA_WRF_Africa/*"
# Create links to the GRIB files in grib_links/ 
for f in $GRIB_DIR_FILE
do
    ln -sf "$f" grib_links/
done
# Create links with link_grib.csh, ungrib with ungrib.exe
ls -ltrh grib_links
cp "$WPS_SRC_DIR/link_grib.csh" .
cp "$WPS_SRC_DIR/ungrib.exe" .
cp "$WPS_SRC_DIR/ungrib/Variable_Tables/Vtable.ECMWF" Vtable
./link_grib.csh grib_links/*
mpirun ungrib.exe
ls -ltrh
# Clean up
rm -f link_grib.csh ungrib.exe GRIBFILE* Vtable
rm -rf grib_links

#-------- Run metgrid --------
echo "-------- Running metgrid.exe --------"
cp "$WPS_SRC_DIR/metgrid.exe" .
mkdir metgrid
ln -sf "$WPS_SRC_DIR/metgrid/METGRID.TBL" metgrid/METGRID.TBL
mpirun metgrid.exe
# Clean up
rm -f metgrid.exe FILE* PFILE* TAVGSFC
rm -rf metgrid

#-------- Clean up --------
mv met_em* "$WPS_OUT_DIR/"
mv *.log "$WPS_OUT_DIR/"
rm -rf "$SCRATCH"

echo "-------- Finished running WPS! --------"
