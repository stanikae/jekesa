#!/bin/bash

CONDA_BASE=$(conda info --base)
export PATH="$CONDA_BASE/envs/r_env/bin:$PATH"
#export PATH="$HOME/anaconda3/envs/resfinder/bin:$PATH"

# activate the resfinder environment
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda deactivate
eval "$(conda shell.bash hook)"
conda activate cge
# check activated env
export PATH="$CONDA_BASE/envs/cge/bin:$PATH"
echo -e "Active env:\t$CONDA_DEFAULT_ENV" >> $cge_out/06.res4.log 2>&1
echo -e "env path: $CONDA_PREFIX" >> $cge_out/06.res4.log 2>&1
echo -e "Full path: $PATH" >> $cge_out/06.res4.log 2>&1

# CGE amr detection using resfinder4
cge_out=$project/res4_results
if ! [ -d $cge_out ]; then
 mkdir -p $cge_out
fi
# resistance gene prediction using assembled contigs
for contigs in $(find $spadesDir -name "*_assembly.fasta")
 do
  name=$(basename $contigs | sed 's/_assembly.fasta//')
  mkdir -p $cge_out/$name

  if grep -Fq "$MLSTscheme" $DATABASES_DIR/resfinder4_mlst_matches.csv; then
     line=$(grep "$MLSTscheme" "$DATABASES_DIR"/resfinder4_mlst_matches.csv)
     pointID=$(echo $line | awk -F',' '{print $2}')

     python3 /home/stan/git-repos/resfinder/run_resfinder.py -ifa $contigs \
     -o $cge_out/$name -b ${CONDA_BASE}/envs/cge/bin/blastn -db_res $DATABASES_DIR/resfinder4_db \
     -s $pointID -t 0.90 -l 0.60 -acq >> $cge_out/06.res4.log 2>&1
     # save res4 output to csv
     Rscript $SCRIPTS_DIR/06.res4_to_csv.R $cge_out/$name $name >> $project/tmp/06.res4_to_csv.log 2>&1
  else
     python3 /home/stan/git-repos/resfinder/run_resfinder.py -ifa $contigs \
     -o $cge_out/$name -b ${CONDA_BASE}/envs/cge/bin/blastn -db_res $DATABASES_DIR/resfinder4_db \
     -t 0.90 -l 0.60 -acq >> $cge_out/06.res4.log 2>&1
     # save res4 output to csv
     Rscript $SCRIPTS_DIR/06.res4_to_csv.R $cge_out/$name $name >> $project/tmp/06.res4_to_csv.log 2>&1
  fi

done
# deactivate resfinder environment
conda deactivate

# copy *.tsv files to the same folder
mkdir -p $cge_out/CSVs
find $cge_out -name "*res4.csv" -exec rsync {} $cge_out/CSVs/ \;
# merge resfinder output from multiple samples
$SCRIPTS_DIR/06.resfinder2tsv.R $cge_out/CSVs $reportsDir/06.res4-results.xlsx > $project/tmp/06.res4_2_tsv.log 2>&1

