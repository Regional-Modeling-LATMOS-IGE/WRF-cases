#-------- Set everything for WPS compilation --------

# To use: 
# source this_script.sh
# Select intel compiler (dmpar)

# Then to compile WPS: 
# nohup ./compile 2>&1 > compile.log &
# or:
# ./compile 2>&1 | tee compile.log

# Load the modules needed for WPS compilation
module purge
module load openmpi/1.6.5-ifort
module load netcdf4/4.3.3.1-ifort
NETCDF_ROOT='/opt/netcdf43/ifort'

# Set the environment variables needed for WPS compilation
export NETCDF=$NETCDF_ROOT
export NETCDF_LIB=$NETCDF_ROOT/lib
export NETCDF_INC=$NETCDF_ROOT/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NETCDF_LIB
export WRFIO_NCD_LARGE_FILE_SUPPORT=1
export JASPERLIB="/usr/lib64"
export JASPERINC="/usr/include/jasper"
# I think there are errors when using $MPI_LIB in geogrid/src/Makefile and
# metgrid/src/Makefile, unset this variable for now
# I think WPS expects a library file here, not a directory, but MPI_LIB is a
# link to the MPI lib/ directory. However I'm not sure what to replace it with
unset MPI_LIB

# Configure WPS - Pick dmpar, intel compiler (19)
./configure

echo "SET PATHS DONE"
echo "Do not forget to update the path to WRF, WRF_DIR, in configure.wps"

# Try to do this automatically
# sed -i 's/.*\(WRF_DIR.*=[ \t]\+\).*\.\.\/WRFV3/\1\.\.\/WRFChem4\.0/' configure.wps
