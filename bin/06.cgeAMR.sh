#!/bin/bash

CONDA_BASE=$(conda info --base)

# activate the resfinder environment
#source ${CONDA_BASE}/etc/profile.d/conda.sh
eval "$(conda shell.bash hook)"
conda activate resfinder

# CGE amr detection
# resistance gene prediction using assembled contigs
for contigs in $(find $spadesDir -name "*_assembly.fasta")
 do
  name=$(basename $contigs | sed 's/_assembly.fasta//')
  mkdir -p $resfinder/$name
  python3 $SCRIPTS_DIR/resfinder.py -i $contigs \
  -o $resfinder/$name -p $DATABASES_DIR/resfinder_db \
  -t 0.90 -l 0.60 >> $project/tmp/06.resfinder.log 2>&1
  # convert json to tsv
  Rscript $SCRIPTS_DIR/json2tsv.R $resfinder/$name/data_resfinder.json \
  $resfinder/$name/${name}.resfindr.tsv >> $project/tmp/06.json2tsv.log 2>&1

  # point mutation detection using assembled contigs
  mkdir -p $pointfinder/$name
  python3 $SCRIPTS_DIR/PointFinder.py -i $contigs \
  -o $pointfinder/$name -p $DATABASES_DIR/pointfinder_db \
  -s salmonella -m blastn -m_p ${CONDA_BASE}/envs/resfinder/bin/blastn \
  -t 0.90 -l 0.60 >> $project/tmp/06.pointfinder.log 2>&1
  # prepare output file for each sample
  sed -i -n '/Known Mutations/,$p' $pointfinder/$name/${name}_blastn_HTMLtable.txt
  echo $name | cat - $pointfinder/$name/${name}_blastn_HTMLtable.txt | \
  sed '/^[[:space:]]*$/d' | tr '\t' ';' > $pointfinder/${name}_pointfinder.txt
done
# deactivate resfinder environment
conda deactivate

# merge resfinder output from multiple samples
for file in $(find ~/Test-pipeline-02/resfinder -name "*.resfindr.tsv"); do 
  cat $file >> $resfinder/06.resfinder.tsv
done
# remove multiple headers
sed -i '1!{/^sampleID/d;}' $resfinder/06.resfinder.tsv

