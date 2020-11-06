#!/bin/bash
set -e
set -x


if [ $# != 1 ];
 then
        echo "Usage: `basename $0` <path to installation directory>"
        exit
fi


installDir=$1
if ! [ -d $installDir ]; then
  mkdir -p $installDir
fi

declare -x SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
declare -x DBPATH=$(echo "$(dirname $SCRIPTPATH)/db")

kraken_download_url="https://genome-idx.s3.amazonaws.com/kraken/k2_standard_8gb_20200919.tar.gz"
poppunk_gpsc_db_url="https://www.pneumogen.net/gps/GPS_query.tar.bz2"
poppunk_gpsc_url="https://www.pneumogen.net/gps/gpsc_definitive.csv"
poppunk_gas_db_url="https://s3-eu-west-1.amazonaws.com/pfigshare-u-files/17424146/GAS_query_v2.tar.bz2"
resfinder_db_url="https://git@bitbucket.org/genomicepidemiology/resfinder_db.git"
pointfinder_db_url="https://git@bitbucket.org/genomicepidemiology/pointfinder_db.git"
disinfinder_db_url="https://git@bitbucket.org/genomicepidemiology/disinfinder_db.git"
serotypefinder_db_url="https://bitbucket.org/genomicepidemiology/serotypefinder_db.git"
virulencefinder_db_url="https://bitbucket.org/genomicepidemiology/virulencefinder_db.git"
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

cge_git () {
  git init
  url=$1
  db_name=$2
  
  if ! [ -d $db_name ]; then
    git clone $url $db_name
    cd $db_name
    python3 INSTALL.py kma_index non_interactive
  fi  
}

# ------------------------ MiniKraken ----------------------------
if ! [ -d $installDir/kraken8gb_standard ]; then
   mkdir -p $installDir/kraken8gb_standard
   cd $installDir/kraken8gb_standard
   db_download "${kraken_download_url}" "kraken8gb_standard.tar.gz"
   tar -zxf kraken8gb_standard.tar.gz
fi
#
if ! [ -h $DBPATH/kraken_db ]; then
 ln -nsf $installDir/kraken8gb_standard $DBPATH/kraken_db
fi
# ----- PopPunk S. pneumoniae and S. pyogenes databases ----------
if ! [ -d $installDir/poppunk_db ]; then
   mkdir -p $installDir/poppunk_db
   cd $installDir/poppunk_db
   db_download "${poppunk_gpsc_db_url}" "GPS_query.tar.bz2"
   db_download "${poppunk_gpsc_url}" "gpsc_definitive.csv"
   db_download "${poppunk_gas_db_url}" "GAS_query_v2.tar.bz2"

   tar -jxf GAS_query_v2.tar.bz2
   tar -jxf GPS_query.tar.bz2
fi
#
if ! [ -h $DBPATH/poppunk_db ]; then
   ln -nsf $installDir/poppunk_db $DBPATH/poppunk_db
fi
# -------------------------- ConFindr ----------------------------
echo "To download ConFindr databases, kindly follow the instructions"
echo "at https://olc-bioinformatics.github.io/ConFindr/install/#downloading-confindr-databases"
echo "By default ConFindr only comes with databases for Escherichia, Listeria and Salmonella"
# --------------------------- Resfinder -------------------------
CONDA_BASE=$(conda info --base)
# activate cge environment
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda deactivate
conda activate cge
export PATH="$CONDA_BASE/envs/cge/bin:$PATH"

cd $installDir
cge_git "${resfinder_db_url}" db_resfinder
#
if ! [ -h $DBPATH/resfinder_db ]; then
 ln -nsf $installDir/db_resfinder $DBPATH/resfinder_db
fi
# --------------------------- PointFinder ------------------------
cd $installDir
cge_git "${pointfinder_db_url}" db_pointfinder
#
if ! [ -h $DBPATH/pointfinder_db ]; then
 ln -nsf $installDir/db_pointfinder $DBPATH/pointfinder_db
fi
# --------------------------- DisinFinder -------------------------
cd $installDir
cge_git "${disinfinder_db_url}" db_disinfinder
#
if ! [ -h $DBPATH/disinfinder_db ]; then
  ln -nsf $installDir/db_disinfinder $DBPATH/disinfinder_db
fi
# --------------------------- ResFinder4 -------------------------

# --------------------------- SeroTyperFinder --------------------
cd $installDir
cge_git "${serotypefinder_db_url}" db_stfinder
#
if ! [ -h $DBPATH/db_stfinder ]; then 
 ln -nsf $installDir/db_stfinder $DBPATH/db_stfinder
fi
# --------------------------- VirulenceFinder --------------------
cd $installDir
cge_git "${virulencefinder_db_url}" db_virulencefinder
#
if ! [ -h $DBPATH/db_virulencefinder ]; then
 ln -nsf $installDir/db_virulencefinder $DBPATH/db_virulencefinder
fi
# ----------------------------------------------------------------
conda deactivate
