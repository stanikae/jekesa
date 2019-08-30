#!/bin/bash


declare -x projectName=$(basename $project)
declare -x SCRIPTS_DIR=${BASH_SOURCE%/*}/bin
declare -x DATABASES_DIR=${BASH_SOURCE%/*}/db
declare -x SPN_SCRIPTS_DIR=${BASH_SOURCE%/*}/spn_scripts
declare -x GAS_SCRIPTS_DIR=${BASH_SOURCE%/*}/GAS_scripts

echo ${BASH_SOURCE}
echo ${BASH_SOURCE%/*}
echo $GAS_SCRIPTS_DIR
echo $SPN_SCRIPTS_DIR
