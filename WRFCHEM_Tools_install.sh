#!/bin/bash
# This script will install the WRFCHEM pre-processor tools.
# Information on these tools can be found here:
# https://www2.acom.ucar.edu/wrf-chem/wrf-chem-tools-community#download
#
# Addtional information on WRFCHEM can be found here:
# https://ruc.noaa.gov/wrf/wrf-chem/
#
# We ask users of the WRF-Chem preprocessor tools to include in any publications the following acknowledgement:
# "We acknowledge use of the WRF-Chem preprocessor tool {mozbc, fire_emiss, etc.} provided by the Atmospheric Chemistry Observations and Modeling Lab (ACOM) of NCAR."
#
#
# This script installs the WRFCHEM Tools with gfortran.





# Basic Package Management for WRF-CHEM Tools and Processors

sudo apt-get update
sudo apt-get upgrade
sudo apt install gcc gfortran g++ libtool automake autoconf make m4 default-jre default-jdk csh ksh git build-essential unzip mlocate byacc flex

#Directory Listings
export HOME=`cd;pwd`
mkdir $HOME/WRFCHEM
cd $HOME/WRFCHEM
mkdir Downloads
mkdir Libs
mkdir Libs/grib2
mkdir Libs/NETCDF
mkdir $HOME/WRFCHEM/WRF_CHEM_Tools
mkdir $HOME/WRFCHEM/WRF_CHEM_Tools/Libs
mkdir $HOME/WRFCHEM/WRF_CHEM_Tools/Libs/grib2
mkdir $HOME/WRFCHEM/WRF_CHEM_Tools/Libs/NETCDF
mkdir $HOME/WRFCHEM/WRF_CHEM_Tools/Downloads
mkdir $HOME/WRFCHEM/WRF_CHEM_Tools/mozbc
mkdir $HOME/WRFCHEM/WRF_CHEM_Tools/megan_bio_emiss
mkdir $HOME/WRFCHEM/WRF_CHEM_Tools/megan_bio_data
mkdir $HOME/WRFCHEM/WRF_CHEM_Tools/wes_coldens
mkdir $HOME/WRFCHEM/WRF_CHEM_Tools/ANTHRO_EMIS
mkdir $HOME/WRFCHEM/WRF_CHEM_Tools/EDGAR_HTAP
mkdir $HOME/WRFCHEM/WRF_CHEM_Tools/EPA_ANTHRO_EMIS
mkdir $HOME/WRFCHEM/WRF_CHEM_Tools/UBC
mkdir $HOME/WRFCHEM/WRF_CHEM_Tools/Aircraft
mkdir $HOME/WRFCHEM/WRF_CHEM_Tools/FINN



##############################Downloading Libraries############################
cd $HOME/WRFCHEM/WRF_CHEM_Tools/Downloads

wget -c -4 https://github.com/madler/zlib/archive/refs/tags/v1.2.12.tar.gz
wget -c -4 https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5-1_12_2.tar.gz
wget -c -4 https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.9.0.tar.gz
wget -c -4 https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v4.6.0.tar.gz
wget -c -4 https://download.sourceforge.net/libpng/libpng-1.6.37.tar.gz
wget -c -4 https://www.ece.uvic.ca/~frodo/jasper/software/jasper-1.900.1.zip



#############################Compilers############################
export DIR=$HOME/WRFCHEM/WRF_CHEM_Tools/Libs
export CC=gcc
export CXX=g++
export FC=gfortran
export F77=gfortran

#IF statement for GNU compiler issue
export GCC_VERSION=$(/usr/bin/gcc -dumpfullversion | awk '{print$1}')
export GFORTRAN_VERSION=$(/usr/bin/gfortran -dumpfullversion | awk '{print$1}')
export GPLUSPLUS_VERSION=$(/usr/bin/g++ -dumpfullversion | awk '{print$1}')

export GCC_VERSION_MAJOR_VERSION=$(echo $GCC_VERSION | awk -F. '{print $1}')
export GFORTRAN_VERSION_MAJOR_VERSION=$(echo $GFORTRAN_VERSION | awk -F. '{print $1}')
export GPLUSPLUS_VERSION_MAJOR_VERSION=$(echo $GPLUSPLUS_VERSION | awk -F. '{print $1}')

export version_10="10"

if [ $GCC_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GFORTRAN_VERSION_MAJOR_VERSION -ge $version_10 ] || [ $GPLUSPLUS_VERSION_MAJOR_VERSION -ge $version_10 ]
then
  export fallow_argument=-fallow-argument-mismatch 
  export boz_argument=-fallow-invalid-boz
else 
  export fallow_argument=
  export boz_argument=
fi


export FFLAGS=$fallow_argument
export FCFLAGS=$fallow_argument


echo "##########################################"
echo "FFLAGS = $FFLAGS"
echo "FCFLAGS = $FCFLAGS"
echo "##########################################"


#############################zlib############################
#Uncalling compilers due to comfigure issue with zlib1.2.12
#With CC & CXX definied ./configure uses different compiler Flags

cd $HOME/WRFCHEM/WRF_CHEM_Tools/Downloads
tar -xvzf v1.2.12.tar.gz
cd zlib-1.2.12/
CC= CXX= ./configure --prefix=$DIR/grib2
make
make install
#make check



#############################libpng############################
cd $HOME/WRFCHEM/WRF_CHEM_Tools/Downloads
export LDFLAGS=-L$DIR/grib2/lib
export CPPFLAGS=-I$DIR/grib2/include
tar -xvzf libpng-1.6.37.tar.gz
cd libpng-1.6.37/
./configure --prefix=$DIR/grib2
make
make install
#make check


#############################JasPer############################
cd $HOME/WRFCHEM/WRF_CHEM_Tools/Downloads
unzip jasper-1.900.1.zip
cd jasper-1.900.1/
autoreconf -i
./configure --prefix=$DIR/grib2
make
make install

export JASPERLIB=$DIR/grib2/lib
export JASPERINC=$DIR/grib2/include


#############################hdf5 library for netcdf4 functionality############################
cd $HOME/WRFCHEM/WRF_CHEM_Tools/Downloads
tar -xvzf hdf5-1_12_2.tar.gz
cd hdf5-hdf5-1_12_2
./configure --prefix=$DIR/grib2 --with-zlib=$DIR/grib2 --enable-hl --enable-fortran
make 
make install
#make check

export HDF5=$DIR/grib2
export LD_LIBRARY_PATH=$DIR/grib2/lib:$LD_LIBRARY_PATH

##############################Install NETCDF C Library############################
cd $HOME/WRFCHEM/WRF_CHEM_Tools/Downloads
tar -xzvf v4.9.0.tar.gz
cd netcdf-c-4.9.0/
export CPPFLAGS=-I$DIR/grib2/include 
export LDFLAGS=-L$DIR/grib2/lib
./configure --prefix=$DIR/NETCDF --disable-dap --enable-netcdf-4 --enable-netcdf4 --enable-shared 
make 
make install
#make check

export PATH=$DIR/NETCDF/bin:$PATH
export NETCDF=$DIR/NETCDF


##############################NetCDF fortran library############################
cd $HOME/WRFCHEM/WRF_CHEM_Tools/Downloads
tar -xvzf v4.6.0.tar.gz
cd netcdf-fortran-4.6.0/
export LD_LIBRARY_PATH=$DIR/NETCDF/lib:$LD_LIBRARY_PATH
export CPPFLAGS=-I$DIR/NETCDF/include 
export LDFLAGS=-L$DIR/NETCDF/lib
./configure --prefix=$DIR/NETCDF --enable-netcdf-4 --enable-netcdf4 --enable-shared
make 
make install
#make check





# Downloading WRF-CHEM Tools and untarring files
cd $HOME/WRFCHEM/WRF_CHEM_Tools/Downloads


wget -c https://www.acom.ucar.edu/wrf-chem/mozbc.tar
wget -c https://www.acom.ucar.edu/wrf-chem/UBC_inputs.tar
wget -c https://www.acom.ucar.edu//wrf-chem/megan_bio_emiss.tar
wget -c https://www.acom.ucar.edu/wrf-chem/megan.data.tar.gz
wget -c https://www.acom.ucar.edu/wrf-chem/wes-coldens.tar
wget -c https://www.acom.ucar.edu/wrf-chem/ANTHRO.tar
wget -c https://www.acom.ucar.edu/webt/wrf-chem/processors/EDGAR-HTAP.tgz
wget -c https://www.acom.ucar.edu/wrf-chem/EPA_ANTHRO_EMIS.tgz
wget -c https://www2.acom.ucar.edu/sites/default/files/wrf-chem/aircraft_preprocessor_files.tar

# Downloading FINN
wget -c https://www.acom.ucar.edu/Data/fire/data/finn2/FINNv2.4_MOD_MOZART_2020_c20210617.txt.gz
wget -c https://www.acom.ucar.edu/Data/fire/data/finn2/FINNv2.4_MOD_MOZART_2013_c20210617.txt.gz
wget -c https://www.acom.ucar.edu/Data/fire/data/finn2/FINNv2.4_MODVRS_MOZART_2019_c20210615.txt.gz
wget -c  https://www.acom.ucar.edu/Data/fire/data/fire_emis.tgz
wget -c  https://www.acom.ucar.edu/Data/fire/data/fire_emis_input.tar
wget -c https://www.acom.ucar.edu/Data/fire/data/TrashEmis.zip



echo ""
echo "Unpacking Mozbc."
tar -xvf mozbc.tar -C $HOME/WRFCHEM/WRF_CHEM_Tools/mozbc
echo ""
echo "Unpacking MEGAN Bio Emission."
tar -xvf megan_bio_emiss.tar -C $HOME/WRFCHEM/WRF_CHEM_Tools/megan_bio_emiss
echo ""
echo "Unpacking MEGAN Bio Emission Data."
tar -xzvf megan.data.tar.gz -C $HOME/WRFCHEM/WRF_CHEM_Tools/megan_bio_data
echo ""
echo "Unpacking Wes Coldens"
tar -xvf wes-coldens.tar -C $HOME/WRFCHEM/WRF_CHEM_Tools/wes_coldens
echo ""
echo "Unpacking Unpacking ANTHRO Emission."
tar -xvf ANTHRO.tar -C $HOME/WRFCHEM/WRF_CHEM_Tools/ANTHRO_EMIS
echo ""
echo "Unpacking EDGAR-HTAP."
tar -xzvf EDGAR-HTAP.tgz -C $HOME/WRFCHEM/WRF_CHEM_Tools/EDGAR_HTAP
echo ""
echo "Unpacking EPA ANTHRO Emission."
tar -xzvf EPA_ANTHRO_EMIS.tgz -C $HOME/WRFCHEM/WRF_CHEM_Tools/EPA_ANTHRO_EMIS
echo ""
echo "Unpacking Upper Boundary Conditions."
tar -xvf UBC_inputs.tar -C $HOME/WRFCHEM/WRF_CHEM_Tools/UBC
echo ""
echo "Unpacking Aircraft Preprocessor Files."
echo ""
tar -xvf aircraft_preprocessor_files.tar -C $HOME/WRFCHEM/WRF_CHEM_Tools/Aircraft
echo ""
echo "Unpacking Fire INventory from NCAR (FINN)"
tar -xzvf fire_emis.tgz -C $HOME/WRFCHEM/WRF_CHEM_Tools/FINN
tar -xvf fire_emis_input.tar 
tar -zxvf grass_from_img.nc.tgz -C $HOME/WRFCHEM/WRF_CHEM_Tools/FINN/grid_finn_fire_emis_v2020/src
tar -zxvf tempfor_from_img.nc.tgz -C $HOME/WRFCHEM/WRF_CHEM_Tools/FINN/grid_finn_fire_emis_v2020/src
tar -zxvf shrub_from_img.nc.tgz -C $HOME/WRFCHEM/WRF_CHEM_Tools/FINN/grid_finn_fire_emis_v2020/src
tar -zxvf tropfor_from_img.nc.tgz -C $HOME/WRFCHEM/WRF_CHEM_Tools/FINN/grid_finn_fire_emis_v2020/src

mv $HOME/WRFCHEM/WRF_CHEM_Tools/Downloads/FINNv2.4_MOD_MOZART_2020_c20210617.txt.gz $HOME/WRFCHEM/WRF_CHEM_Tools/FINN
mv $HOME/WRFCHEM/WRF_CHEM_Tools/Downloads/FINNv2.4_MOD_MOZART_2013_c20210617.txt.gz  $HOME/WRFCHEM/WRF_CHEM_Tools/FINN
mv $HOME/WRFCHEM/WRF_CHEM_Tools/Downloads/FINNv2.4_MODVRS_MOZART_2019_c20210615.txt.gz $HOME/WRFCHEM/WRF_CHEM_Tools/FINN

unzip TrashEmis.zip 
mv $HOME/WRFCHEM/WRF_CHEM_Tools/Downloads/ALL_Emiss_04282014.nc $HOME/WRFCHEM/WRF_CHEM_Tools/FINN/grid_finn_fire_emis_v2020/src

cd $HOME/WRFCHEM/WRF_CHEM_Tools/FINN

gunzip  FINNv2.4_MOD_MOZART_2020_c20210617.txt.gz 
gunzip  FINNv2.4_MOD_MOZART_2013_c20210617.txt.gz  
gunzip  FINNv2.4_MODVRS_MOZART_2019_c20210615.txt.gz
############################Installation of Mozbc #############################
# Recalling variables from install script to make sure the path is right

cd $HOME/WRFCHEM/WRF_CHEM_Tools/mozbc
chmod +x make_mozbc
export DIR=$HOME/WRFCHEM/Libs
export FC=gfortran
export NETCDF_DIR=$DIR/NETCDF
sed -i 's/"${ar_libs} -lnetcdff"/"-lnetcdff ${ar_libs}"/' make_mozbc
./make_mozbc


################## Information on Upper Boundary Conditions ###################

cd $HOME/WRFCHEM/WRF_CHEM_Tools/UBC/
wget -c https://www2.acom.ucar.edu/sites/default/files/wrf-chem/8A_2_Barth_WRFWorkshop_11.pdf


########################## MEGAN Bio Emission #################################
# Data for MEGAN Bio Emission located in
# $HOME/WRFCHEM/WRF_CHEM_Tools/megan_bio_data

cd $HOME/WRFCHEM/WRF_CHEM_Tools/megan_bio_emiss
chmod +x make_util
export DIR=$HOME/WRFCHEM/Libs
export FC=gfortran
export NETCDF_DIR=$DIR/NETCDF
sed -i 's/"${ar_libs} -lnetcdff"/"-lnetcdff ${ar_libs}"/' make_util
sed -i '8s/FFLAGS = --g/FFLAGS = --g $fallow_argument/' Makefile
sed -i '10s/FFLAGS = --g/FFLAGS = --g $fallow_argument/' Makefile
./make_util megan_bio_emiss 
./make_util megan_xform 
./make_util surfdata_xform


############################# Anthroprogenic Emissions #########################

cd $HOME/WRFCHEM/WRF_CHEM_Tools/ANTHRO_EMIS/ANTHRO/src
chmod +x make_anthro
export DIR=$HOME/WRFCHEM/Libs
export FC=gfortran
export NETCDF_DIR=$DIR/NETCDF
sed -i 's/"${ar_libs} -lnetcdff"/"-lnetcdff ${ar_libs}"/' make_anthro
sed -i '8s/FFLAGS = --g/FFLAGS = --g $fallow_argument/' Makefile
sed -i '10s/FFLAGS = --g/FFLAGS = --g $fallow_argument/' Makefile
./make_anthro

############################# EDGAR HTAP ######################################
#  This directory contains EDGAR-HTAP anthropogenic emission files for the
#  year 2010.  The files are in the MOZCART and MOZART-MOSAIC sub-directories.
#  The MOZCART files are intended to be used for the WRF MOZCART_KPP chemical  
#  option.  The MOZART-MOSAIC files are intended to be used with the following
#  WRF chemical options (See Readme in Folder

######################### EPA Anthroprogenic Emissions ########################
cd $HOME/WRFCHEM/WRF_CHEM_Tools/EPA_ANTHRO_EMIS/src
chmod +x make_anthro
export DIR=$HOME/WRFCHEM/Libs
export FC=gfortran
export NETCDF_DIR=$DIR/NETCDF
sed -i 's/"${ar_libs} -lnetcdff"/"-lnetcdff ${ar_libs}"/' make_anthro
./make_anthro

######################### Weseley EXO Coldens ##################################
cd $HOME/WRFCHEM/WRF_CHEM_Tools/wes_coldens
chmod +x make_util
export DIR=$HOME/WRFCHEM/Libs
export FC=gfortran
export NETCDF_DIR=$DIR/NETCDF
sed -i 's/"${ar_libs} -lnetcdff"/"-lnetcdff ${ar_libs}"/' make_util
./make_util wesely
./make_util exo_coldens


########################## Aircraft Emissions Preprocessor #####################
# This is an IDL based preprocessor to create WRF-Chem ready aircraft emissions files 
# (wrfchemaircraft_) from a global inventory in netcdf format. Please consult the README file 
# for how to use the preprocessor. The emissions inventory is not included, so the user must 
# provide their own.
echo " "
echo "######################################################################"
echo " Please see script for details about Aircraft Emissions Preprocessor"
echo "######################################################################"
echo " "

######################## Fire INventory from NCAR (FINN) ###########################
# Fire INventory from NCAR (FINN): A daily fire emissions product for atmospheric chemistry models
# https://www2.acom.ucar.edu/modeling/finn-fire-inventory-ncar
echo " "
echo "###########################################"
echo " Please see folder for details about FINN."
echo "###########################################"
echo " "
#####################################BASH Script Finished##############################
echo " "
echo "WRF CHEM Tools compiled with latest version of NETCDF files available on 05/26/2022"
echo "If error occurs using WRFCHEM tools please update your NETCDF libraries or reconfigure with older libraries"
echo "This is a WRC Chem Community tool made by a private user and is not supported by UCAR/NCAR"
echo "BASH Script Finished"
