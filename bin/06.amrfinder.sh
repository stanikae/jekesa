#!/bin/bash

CONDA_BASE=$(conda info --base)
export PATH="$CONDA_BASE/envs/r_env/bin:$PATH"
#export PATH="$HOME/anaconda3/envs/resfinder/bin:$PATH"

# activate the amrfinder environment
#source ${CONDA_BASE}/etc/profile.d/conda.sh
#conda deactivate
#eval "$(conda shell.bash hook)"
#conda activate amrFP
# check activated env
#export PATH="$CONDA_BASE/envs/amrFP/bin:$PATH"
#echo -e "Active env:\t$CONDA_DEFAULT_ENV" >> $amrFP_out/06.amrfinder.log 2>&1
#echo -e "env path: $CONDA_PREFIX" >> $amrFP_out/06.amrfinder.log 2>&1
#echo -e "Full path: $PATH" >> $amrFP_out/06.amrfinder.log 2>&1

# AMR and virulence genes detection using NCBI AMRFinderPlus
amrFP_out=$project/amrfinder
if ! [ -d $amrFP_out ]; then
 mkdir -p $amrFP_out
fi
# resistance gene prediction using assembled contigs
for contigs in $(find $spadesDir -name "*_assembly.fasta")
 do
  name=$(basename $contigs | sed 's/_assembly.fasta//')
  mkdir -p $amrFP_out/$name

  if grep -Fq "$MLSTscheme" $DATABASES_DIR/amrfinder_mlst_matches.csv; then
     line=$(grep -w "$MLSTscheme" "$DATABASES_DIR"/amrfinder_mlst_matches.csv)
     pointID=$(echo $line | awk -F',' '{print $2}')

     amrfinder --plus --nucleotide $contigs --name $name --threads $threads \
     --output $amrFP_out/$name/${name}_report.tsv --nucleotide_output $amrFP_out/$name/${name}.fna \
     --organism $pointID >> $amrFP_out/06.amrfinder.log 2>&1
     # save res4 output to csv
     #Rscript $SCRIPTS_DIR/06.res4_to_csv.R $amrFP_out/$name $name >> $project/tmp/06.res4_to_csv.log 2>&1
  else
     amrfinder --plus --nucleotide $contigs --name $name --threads $threads \
     --output $amrFP_out/$name/${name}_report.tsv \
     --nucleotide_output $amrFP_out/$name/${name}.fna >> $amrFP_out/06.amrfinder.log 2>&1
     # save res4 output to csv
     #Rscript $SCRIPTS_DIR/06.res4_to_csv.R $amrFP_out/$name $name >> $project/tmp/06.res4_to_csv.log 2>&1
  fi

done
# deactivate resfinder environment
#conda deactivate

# copy *.tsv files to the same folder
mkdir -p $amrFP_out/TSVs
find $amrFP_out -name "*_report.tsv" -exec rsync {} $amrFP_out/TSVs/ \;
# merge resfinder output from multiple samples
$SCRIPTS_DIR/06.resfinder2tsv.R $amrFP_out/TSVs $reportsDir/06.amrfinder.xlsx > $project/tmp/06.amrfinder2excel.log 2>&1

