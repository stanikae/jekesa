#!/bin/bash
set -e
set -x

installDir=$1
kraken_download_url="https://genome-idx.s3.amazonaws.com/kraken/k2_standard_8gb_20200919.tar.gz"
poppunk_gpsc_db_url="https://www.pneumogen.net/gps/GPS_query.tar.bz2"
poppunk_gpsc_url="https://www.pneumogen.net/gps/gpsc_definitive.csv"
poppunk_gas_db_url="https://s3-eu-west-1.amazonaws.com/pfigshare-u-files/17424146/GAS_query_v2.tar.bz2"

# function modified from ariba download function 
db_download () {
  url=$1
  name=$2
 # dbDir=$3

  if [ -e $name ]; then
    echo "Skipping download of $url, $name already exists"
  else
    echo "Downloading $url to $name"
    wget -c $url -O $name #-P $dbDir
  fi
}


# ------------------------ MiniKraken ----------------------------
cd $installDir
db_download "${kraken_download_url}" "kraken8gb_standard.tar.gz"
tar -zxf kraken8gb_standard.tar.gz


# ----- PopPunk S. pneumoniae and S. pyogenes databases ----------
cd $installDir
db_download "${poppunk_gpsc_db_url}" "GPS_query.tar.bz2"
db_download "${poppunk_gpsc_url}" "gpsc_definitive.csv"
db_download "${poppunk_gas_db_url}" "GAS_query_v2.tar.bz2"

tar -jxf GAS_query_v2.tar.bz2
tar -jxf GPS_query.tar.bz2


# -------------------------- ConFindr ----------------------------



# --------------------------- Resfinder -------------------------




# --------------------------- PointFinder ------------------------


# --------------------------- ResFinder4 -------------------------


# link dbs to jekesa db directory
# cretae global variables
echo -e "\t[`date +"%d-%b-%Y %T"`]\tParameters supplied by the User:"
echo -e "\t\tProject name: $project\n\t\tAssembler: $assembler\n\t\tThreads: $threads\n\t\tMLSTscheme: $MLSTscheme"
declare -x projectName=$(basename $project)
declare -x SCRIPTS_DIR=${BASH_SOURCE%/*}/bin
declare -x DATABASES_DIR=${BASH_SOURCE%/*}/db
declare -x SPN_SCRIPTS_DIR=${BASH_SOURCE%/*}/spn_scripts
declare -x GAS_SCRIPTS_DIR=${BASH_SOURCE%/*}/GAS_scripts
