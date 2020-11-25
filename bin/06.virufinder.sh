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
#virufinder=$project/serofinder
#if ! [ -d $virufinder ]; then
# mkdir -p $virufinder
#fi

# resistance gene prediction using assembled contigs
for contigs in $(find $spadesDir -name "*_assembly.fasta")
 do
  name=$(basename $contigs | sed 's/_assembly.fasta//')
  mkdir -p $virufinder/$name
  
  # resistance gene prediction using assembled contigs
#  if grep -Fq "$MLSTscheme" $DATABASES_DIR/virulencefinder_mlst2db.csv; then
#     line=$(grep -w "$MLSTscheme" "$DATABASES_DIR"/virulencefinder_mlst2db.csv)
#     pointID=$(echo $line | awk -F',' '{print $2}')

#     python3 $SCRIPTS_DIR/virulencefinder.py -i $contigs \
#     -o $virufinder/$name -mp ${CONDA_BASE}/envs/resfinder/bin/blastn -p $DATABASES_DIR/db_virulencefinder \
#     -d "$pointID" -t 0.90 -l 0.60 >> $virufinder/06.res4.log 2>&1
     # save res4 output to csv
     #Rscript $SCRIPTS_DIR/06.res4_to_csv.R $virufinder/$name $name >> $project/tmp/06.res4_to_csv.log 2>&1
     #Rscript $SCRIPTS_DIR/07.json2tsv.R $virufinder/$name/data.json \
     #$virufinder/$name/${name}.virufinder.tsv >> $project/tmp/06.json2tsv.log 2>&1
#   else
     python3 $SCRIPTS_DIR/virulencefinder.py -i $contigs \
     -o $virufinder/$name -mp ${CONDA_BASE}/envs/resfinder/bin/blastn -p $DATABASES_DIR/db_virulencefinder \
     -t 0.90 -l 0.60 >> $virufinder/06.res4.log 2>&1
     # save res4 output to csv
     #Rscript $SCRIPTS_DIR/06.res4_to_csv.R $virufinder/$name $name >> $project/tmp/06.res4_to_csv.log 2>&1
     #Rscript $SCRIPTS_DIR/07.json2tsv.R $virufinder/$name/data.json \
     #$virufinder/$name/${name}.virufinder.tsv >> $project/tmp/06.json2tsv.log 2>&1
#  fi
  # convert json to tsv
  Rscript $SCRIPTS_DIR/06.virulence_json2tsv.R $virufinder/$name/data.json \
  $virufinder/$name/${name}.virufinder.tsv $MLSTscheme >> $project/tmp/06.json2tsv.log 2>&1

done
# deactivate resfinder environment
conda deactivate

# copy *.tsv files to the same folder
mkdir -p $virufinder/TSVs
find $virufinder -name "*virufinder.tsv" -exec rsync {} $virufinder/TSVs/ \;
# merge resfinder output from multiple samples
$SCRIPTS_DIR/06.resfinder2tsv.R $virufinder/TSVs $reportsDir/06.virufinder.xlsx > $project/tmp/06.resfinder2tsv.log 2>&1

