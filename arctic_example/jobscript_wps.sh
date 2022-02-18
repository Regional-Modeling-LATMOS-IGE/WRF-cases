#!/bin/bash
#-------- Set up and run WPS for an Arctic example run  --------
#
# Shaddy Ahmed, 18/02/2022
#

# Resources used
#PBS -l "nodes=1:ppn=1"
#PBS -l vmem=32G
#PBS -l mem=32G
#PBS -q week
#PBS -j eo


#-------- Input --------
CASENAME='WRF_ARCTIC_EXAMPLE'

# Directory containing the WPS executables and inputs
WPS_SRC_DIR="/home/sahmed/WPS/WPSV4.1"

# Simulation start year and month
yys=2009
mms=03
dds=16
hhs=00
# Simulation end year, month, day, hour
yye=2009
mme=03
dde=24
hhe=00

# Name of the WPS namelist file
NAMELIST="namelist.wps.example"

# Select the input data. (This option can be removed if using
# different input data)
#   1=ERA-INTERIM reanalysis 2=NCEP/FNL analysis
INPUT_DATA_SELECT=2

#-------- Parameters --------
# Output directory
OUTDIR_ROOT="/scratchu/sahmed/WRFChem_OUTPUT"

# Directory containing the GRIB file inputs for ungrib
# (This is currently set up for ciclad)
if ((INPUT_DATA_SELECT==1 )); then
  GRIB_DIR="/data/marelle/met_data/"
elif ((INPUT_DATA_SELECT==2 )); then
  GRIB_DIR="/data/onishi/FNL/ds083.2/"
else
  echo "Error, INPUT_DATA_SELECT=$INPUT_DATA_SELECT is not recognized"
fi


#-------- Set up job environment --------
cd $PBS_O_WORKDIR

# Load modules used for WRFChem compilation
module purge   # clear any inherited modules
module load openmpi/1.6.5-ifort
module load hdf5/1.8.14-ifort
module load netcdf4/4.3.3.1-ifort
NETCDF_ROOT='/opt/netcdf43/ifort'
NETCDF=$NETCDF_ROOT
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$NETCDF_ROOT/lib"
# Must set large stack size (unlimited for simplicity)
ulimit -s unlimited
# Set ulimit also to unlimited (probably not necessary)
ulimit unlimited

# Set run start and end date
date_s="$yys-$mms-$dds"
date_e="$yye-$mme-$dde"


#-------- Set up WPS input and output directories & files  --------
# Directory containing WPS output (i.e. met_em files)
# Make output directory
WPSDIR="${OUTDIR_ROOT}/met_em_${CASENAME}_$(date -d "$date_e - 1 day" "+%Y")"
if [ -d $WPSDIR ]
then
  echo "Warning: directory $WPSDIR already exists, overwriting"
  rm -rf "$WPSDIR/"*
else
  mkdir "$WPSDIR"
fi

# Also create a temporary run directory
SCRATCH="$WPSDIR.$PBS_JOBID"
mkdir $SCRATCH
cd $SCRATCH
echo "Running on $SCRATCH"
cp "$PBS_O_WORKDIR/"* "$SCRATCH/"

# Save this slurm script to the output directory
cp $0 "$WPSDIR/jobscript_wps.sh"

#  Prepare the WPS namelist
cp $NAMELIST namelist.wps
sed -i "4s/YYYY/${yys}/g" namelist.wps
sed -i "4s/MM/${mms}/g" namelist.wps
sed -i "4s/DD/${dds}/g" namelist.wps
sed -i "5s/YYYY/${yye}/g" namelist.wps
sed -i "5s/MM/${mme}/g" namelist.wps
sed -i "5s/DD/${dde}/g" namelist.wps


#-------- Run geogrid --------
echo "-------- Running geogrid.exe --------"
mkdir geogrid
ln -sf "$PBS_O_WORKDIR/geogrid/GEOGRID.TBL" geogrid/GEOGRID.TBL
cp "$WPS_SRC_DIR/geogrid.exe" .
mpirun ./geogrid.exe
# Clean up
rm -f geogrid.exe
rm -rf geogrid


#-------- Run ungrib --------
echo "-------- Running ungrib.exe --------"
# Create a directory containing links to the grib files of interest  
mkdir grib_links

# Create links to the GRIB files in grib_links/ 
date_ungrib=$(date +"%Y%m%d" -d "$date_s")
while (( $(date -d "$date_ungrib" "+%s") <= $(date -d "$date_e" "+%s") )); do
  # Year for this date
  yy_ungrib=${date_ungrib:0:4}

  # ERA-interim input
  if (( INPUT_DATA_SELECT==1 )); then
    ln -sf "$GRIB_DIR/ERAI/ERA-Int_grib1_"$(date +"%Y" -d "$date_ungrib")"/ei.oper."*"pl"*"$(date +"%Y%m%d" -d "$date_ungrib")"* grib_links/
    ln -sf "$GRIB_DIR/ERAI/ERA-Int_grib1_"$(date +"%Y" -d "$date_ungrib")"/ei.oper."*"sfc"*"$(date +"%Y%m%d" -d "$date_ungrib")"* grib_links/
  # FNL input
  elif (( INPUT_DATA_SELECT==2 )); then
    ln -sf "$GRIB_DIR/FNL$(date +"%Y" -d "$date_ungrib")/fnl_$(date +"%Y%m%d" -d "$date_ungrib")"* grib_links/
  fi
  # Go to the next date to ungrib
  date_ungrib=$(date +"%Y%m%d" -d "$date_ungrib + 1 day");
done

# Create links with link_grib.csh, ungrib with ungrib.exe
ls -ltrh grib_links
cp "$WPS_SRC_DIR/link_grib.csh" .
cp "$WPS_SRC_DIR/ungrib.exe" .

# ERA-interim input
if (( INPUT_DATA_SELECT==1 )); then
  cp "$WPS_SRC_DIR/ungrib/Variable_Tables/Vtable.ERA-interim.pl" Vtable
  sed -i 's/_FILE_ungrib_/FILE/g' namelist.wps
  ./link_grib.csh grib_links/ei
  ./ungrib.exe
elif (( INPUT_DATA_SELECT==2 )); then
# Ungrib for FNL
  cp "$WPS_SRC_DIR/ungrib/Variable_Tables/Vtable.GFS" Vtable
  sed -i 's/_FILE_ungrib_/FILE/g' namelist.wps
  ./link_grib.csh grib_links/fnl
  ./ungrib.exe
fi
ls -ltrh

# Clean up
rm -f link_grib.csh ungrib.exe GRIBFILE* Vtable
rm -rf grib_links


#-------- Run metgrid --------
echo "-------- Running metgrid.exe --------"
cp "$WPS_SRC_DIR/util/avg_tsfc.exe" .
cp "$WPS_SRC_DIR/metgrid.exe" .

mkdir metgrid
ln -sf "$PBS_O_WORKDIR/metgrid/METGRID.TBL" metgrid/METGRID.TBL

# In order to use the daily averaged skin temperature for lakes, tavgsfc (thus also metgrid) 
# should be run once per day
date_s_met=$(date +"%Y%m%d" -d "$date_s")
# Loop on run days
while (( $(date -d "$date_s_met +1 day" "+%s") <= $(date -d "$date_e" "+%s") )); do
  date_e_met=$(date +"%Y%m%d" -d "$date_s_met + 1 day");
  echo "$date_s_met $date_e_met"
  # Start and end years/months/days for this metgrid/tavg run
  yys_met=${date_s_met:0:4}
  mms_met=${date_s_met:4:2}
  dds_met=${date_s_met:6:2}
  yye_met=${date_e_met:0:4}
  mme_met=${date_e_met:4:2}
  dde_met=${date_e_met:6:2}
  # Prepare the namelist
  cp -f $NAMELIST namelist.wps
  sed -i "4s/YYYY/${yys_met}/g" namelist.wps
  sed -i "4s/MM/${mms_met}/g" namelist.wps
  sed -i "4s/DD/${dds_met}/g" namelist.wps
  sed -i "5s/YYYY/${yye_met}/g" namelist.wps
  sed -i "5s/MM/${mme_met}/g" namelist.wps
  sed -i "5s/DD/${dde_met}/g" namelist.wps
  sed -i "s/'_FILE_metgrid_'/'FILE'/" namelist.wps
  # Run avg_tsfc and metgrid
  ./avg_tsfc.exe
  mpirun ./metgrid.exe
  date_s_met=$date_e_met
done # While date < end date
# Clean up
rm -f avg_tsfc.exe metgrid.exe FILE* PFILE* TAVGSFC
rm -rf metgrid


#-------- Clean up --------
mv met_em* "$WPSDIR/"
mv *.log "$WPSDIR/"
rm -rf "$SCRATCH"


echo "-------- Finished running WPS! --------"
