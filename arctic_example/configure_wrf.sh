#!/bin/sh
# Script for configuring WRF on ciclad

# To use: 
# source this_script.sh
# Select ifort+icc(dmpar), and basic nesting

# Then to compile WRF: 
# nohup ./compile em_real 2>&1 > compile.log &

WRFDIR=$PWD

# Remove everything before git commit
# ./clean -a
# git checkout test/em_real/wind-turbine-1.tbl; rm -rf Registry/registry.irr_diag chem/KPP/inc/racm_esrlsorg_aqchem/ chem/KPP/inc/racmsorg_aqchem/ chem/KPP/kpp/kpp-2.1/bin/ chem/KPP/kpp/kpp-2.1/cflags chem/KPP/util/wkc/registry_kpp chem/KPP/util/wkc/tuv_kpp chem/Makefile.temp chem/Makefile_org compile.log run/namelist.input.backup.*

# Load the modules needed for WRF compilation
module purge
module load openmpi/1.6.5-ifort
module load hdf5/1.8.14-ifort
module load netcdf4/4.3.3.1-ifort
NETCDF_ROOT='/opt/netcdf43/ifort'
OPENMPI_ROOT='/usr/lib64/openmpi/1.6.5-ifort'
HDF5_ROOT='/opt/hdf5/1.8.14'

# Set the environment variables needed for WRF compilation
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$NETCDF_ROOT/lib"
export NETCDF="$NETCDF_ROOT"
export NETCDF_LIB="$NETCDF_ROOT/lib"
export NETCDF_INC="$NETCDF_ROOT/include"
export CFLAGS="-I$OPENMPI_ROOT/include -m64"
export LDFLAGS="-L$OPENMPI_ROOT/lib -lmpi"
export PHDF5="$HDF5_ROOT"
export JASPERLIB="/usr/lib64"
export JASPERINC="/usr/include/jasper"
export YACC="/home/onishi/tools/bin/yacc -d"
export FLEX_LIB_DIR="/home/onishi/tools/lib"

# Set the WRF switches for WRF-Chem compilation
export WRF_EM_CORE=1
export WRF_NMM_CORE=0
export WRF_CHEM=0
export WRF_KPP=0
export WRFIO_NCD_LARGE_FILE_SUPPORT=1

# # Correct this code in KPP (from Tatsuo Onishi, LATMOS)
# cd $WRFDIR/chem/KPP/kpp/kpp-2.1/src/
# flex scan.l
# sed -i '
# 1 i \
# #define INITIAL 0 \
# #define CMD_STATE 1 \
# #define INC_STATE 2 \
# #define MOD_STATE 3 \
# #define INT_STATE 4 \
# #define PRM_STATE 5 \
# #define DSP_STATE 6 \
# #define SSP_STATE 7 \
# #define INI_STATE 8 \
# #define EQN_STATE 9 \
# #define EQNTAG_STATE 10 \
# #define RATE_STATE 11 \
# #define LMP_STATE 12 \
# #define CR_IGNORE 13 \
# #define SC_IGNORE 14 \
# #define ATM_STATE 15 \
# #define LKT_STATE 16 \
# #define INL_STATE 17 \
# #define MNI_STATE 18 \
# #define TPT_STATE 19 \
# #define USE_STATE 20 \
# #define COMMENT 21 \
# #define COMMENT2 22 \
# #define EQN_ID 23 \
# #define INL_CODE 24 
# ' $WRFDIR/chem/KPP/kpp/kpp-2.1/src/lex.yy.c
# sed -i 's/\-ll //g' $WRFDIR/chem/KPP/kpp/kpp-2.1/src/Makefile
# sed -i 's/integr_edit.exe $(MECH)/\.\/integr_edit.exe $(MECH)/g' $WRFDIR/chem/KPP/util/write_decomp/Makefile
# sed -i '/I_really_want_to_output_grib2_from_WRF/s/FALSE/TRUE/g' $WRFDIR/arch/Config_new.pl

# Run WRF configure
cd $WRFDIR
./configure


