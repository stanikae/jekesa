#!/bin/bash

CONDA_BASE=$(conda info --base)
export PATH="$CONDA_BASE/envs/r_env/bin:$PATH"

# activate the resfinder environment
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda deactivate
eval "$(conda shell.bash hook)"
conda activate resfinder

# on some linux systems this will not add the resfinder env to path
# so adding the resfinder bin to path here just in case
export PATH="$CONDA_BASE/envs/resfinder/bin:$PATH"

# CGE serotyping Ecoli
#serotyper=$project/serofinder
#if ! [ -d $serotyper ]; then
# mkdir -p $serotyper
#fi

# resistance gene prediction using assembled contigs
for contigs in $(find $spadesDir -name "*_assembly.fasta")
 do
  name=$(basename $contigs | sed 's/_assembly.fasta//')
  mkdir -p $serotyper/$name
  python3 $SCRIPTS_DIR/serotypefinder.py -i $contigs \
  -o $serotyper/$name -mp ${CONDA_BASE}/envs/resfinder/bin/blastn -p $DATABASES_DIR/db_stfinder \
  -t 0.85 -l 0.60 >> $serotyper/07.serotyper.log 2>&1
  # convert json to tsv
  Rscript $SCRIPTS_DIR/07.json2tsv.R $serotyper/$name/data.json \
  $serotyper/$name/${name}.serotyper.tsv >> $project/tmp/07.json2tsv.log 2>&1

done
# deactivate resfinder environment
conda deactivate

# copy *.tsv files to the same folder
mkdir -p $serotyper/TSVs
find $serotyper -name "*serotyper.tsv" -exec rsync {} $serotyper/TSVs/ \;
# merge resfinder output from multiple samples
$SCRIPTS_DIR/06.resfinder2tsv.R $serotyper/TSVs $reportsDir/07.serotyper.xlsx > $project/tmp/07.serotype2tsv.log 2>&1

