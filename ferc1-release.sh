#!/bin/bash
# A script to generate a reproducible data release locally.
# Assumes:
#  - A Unix-like OS
#  - libsnappy is installed
#  - conda is installed
#  - Environment variable $CONDA_EXE is path to conda
#  - Should be run from within a fresh git clone:
#    https://github.com/catalyst-cooperative/ferc1-data-release.git

PUDL_VERSION=0.3.2
START_TIME=$(date --iso-8601="seconds")
FERC1_YEARS1=""

###############################################################################
# Create, activate, and record the ferc1-data-release conda environment
###############################################################################
echo "======================================================================"
echo $START_TIME
echo "Creating and archiving PUDL conda environment"
echo "======================================================================"
$CONDA_EXE init bash
eval "$($CONDA_EXE shell.bash hook)"
$CONDA_EXE env remove --name ferc1-data-release
$CONDA_EXE create --yes --name ferc1-data-release \
    --strict-channel-priority --channel conda-forge \
    python=3.7 pip git catalystcoop.pudl=$PUDL_VERSION
source activate ferc1-data-release

ACTIVE_CONDA_ENV=$($CONDA_EXE env list | grep '\*' | awk '{print $1}')
echo "Active conda env: $ACTIVE_CONDA_ENV"

# Record exactly which software was installed for ETL:
$CONDA_EXE env export | grep -v "^prefix" > archived-environment.yml

echo "======================================================================"
date --iso-8601="seconds"
echo "Setting up PUDL data management environment."
echo "======================================================================"
pudl_setup --clobber ./

echo "======================================================================"
date --iso-8601="seconds"
echo "Downloading raw input data."
echo "======================================================================"
pudl_data --sources ferc1 $FERC1_YEARS

echo "======================================================================"
date --iso-8601="seconds"
echo "Cloning FERC Form 1 into SQLite."
echo "======================================================================"
ferc1_to_sqlite --clobber ferc1-release-settings.yml

echo "======================================================================"
date --iso-8601="seconds"
echo "Archiving raw input data for distribution."
echo "======================================================================"
mkdir zenodo-archive
tar -czf zenodo-archive/ferc1-input-data.tgz data/

echo "======================================================================"
date --iso-8601="seconds"
echo "Archiving database documentation files."
echo "======================================================================"
tar -czf zenodo-archive/docs.tgz docs/

echo "======================================================================"
date --iso-8601="seconds"
echo "Archiving FERC 1 SQLite DB."
echo "======================================================================"
tar -czf zenodo-archive/ferc1-sqlite.tgz sqlite/ferc1.sqlite

cp ferc1-release.sh \
    reproduce-ferc1-release.sh \
    ferc1-release-settings.yml \
    archived-environment.yml \
    README.md \
    zenodo-archive

echo "======================================================================"
END_TIME=$(date --iso-8601="seconds")
ARCHIVE_SIZE=$(du -sh zenodo-archive)
echo "FERC Form 1 Database Cloning Complete."
echo "START TIME:" $START_TIME
echo "END TIME:  " $END_TIME
echo "Archive Size:" $ARCHIVE_SIZE
echo "======================================================================"
