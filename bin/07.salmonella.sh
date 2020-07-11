#!/bin/bash

CONDA_BASE=$(conda info --base)
# activate the resfinder environment
#source ${CONDA_BASE}/etc/profile.d/conda.sh
eval "$(conda shell.bash hook)"
conda activate resfinder

# salmonella serotyping
for contigs in $(find $spadesDir -name "*_assembly.fasta")
 do
  name=$(basename $contigs | sed 's/_assembly.fasta//')
  #mkdir -p $mlstDir/$name
  # seqsero2
  mkdir -p $seqsero/$name
  SeqSero2_package.py -t 4 -m k -i $contigs \
  -n $name -d $seqsero/$name \
  -p $threads > $project/tmp/seqsero.log 2>&1
  # sistr
  mkdir -p $sistr/$name
  sistr --qc -vv --alleles-output $sistr/$name/${name}-allele-results.json \
  --novel-alleles $sistr/$name/${name}-novel-alleles.fasta --cgmlst-profiles cgmlst-profiles.csv \
  -f tab -o $sistr/$name/${name}-sistr-output.tab $contigs > $project/tmp/sistr.log 2>&1
done
# deactivate resfinder environment
conda deactivate

# Edit and merge SeqSero output file
echo -e "SampleID\tO.antigen\tH1.antigen.fliC\tH2.antigen.fljB\tPredicted.subspecies\tAntigenic.profile\tSerotype\tNote" > $seqsero/07.seqsero.tsv
for file in $(find $seqsero -name "*SeqSero_result.tsv"); do 
  cat $file | tail -n -1 | \
  awk -v OFS='\t' '{print $1,$4,$5,$6,$7,$8,$9,$10}' >> $seqsero/07.seqsero.tsv
done

# Convert .tsv to .xlsx
if [ -e $seqsero/07.seqsero.tsv ]; then
  Rscript $SCRIPTS_DIR/tsv2xlsx.R $seqsero/07.seqsero.tsv \
	$reportsDir/07.seqsero.xlsx > $project/tmp/07.seqsero.log 2>&1
fi

# Edit and compile sistr output file
echo -e "cgmlst.ST\tcgmlst.distance\tcgmlst.genome.match\tcgmlst.matching.alleles\tcgmlst.subspecies\th1\th2\to.antigen\tqc.status\tserogroup\tserovar\tserovar.antigen\tserovar.cgmlst" > $sistr/07.sistr.tsv 
for file in $(find $sistr -name "*-sistr-output.tab"); do
  cat $file | awk -v OFS='\t' -F '\t' '{print $1,$2,$3,$4,$5,$8,$9,$10,$12,$13,$14,$15,$16}' |\
  tail -n -1 >> $sistr/07.sistr.tsv
done

# Convert .csv to .xlsx
Rscript $SCRIPTS_DIR/tsv2xlsx.R $sistr/07.sistr.tsv \
	$reportsDir/07.sistr.xlsx > $project/tmp/07.sistr.log 2>&1

