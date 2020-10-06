#!/bin/bash


indir=$project  
#samples=$samples

CONDA_BASE=$(conda info --base)

# contaminants files
contaminants=$CONDA_BASE/envs/jekesa/opt/fastqc*/Configuration/contaminant_list.txt
adapters=$CONDA_BASE/envs/jekesa/opt/fastqc*/Configuration/adapter_list.txt

for fq1 in $indir/*_R1_*f*q*
do
  if [ -s $fq1 ]; then
  fq2=$(echo $fq1 | awk -F "_R1" '{print $1 "_R2" $2}')
	
  trim_galore -q 30 \
  --length 50 --trim-n -o $trimmedReads --gzip \
  --paired $fq1 $fq2 \
  --cores 4 --no_report_file \
  --fastqc_args "-o $qcReports --contaminants $contaminants --adapters $adapters --threads $threads"
  #--retain_unpaired -r1 85 -r2 85
  fi
done

echo -e "\t[`date +"%d-%b-%Y %T"`]\tGenerating QC reports for clean reads using multiQC"
if [ "$(ls -A $qcReports)" ]; then
 nohup multiqc -o $reportsDir/${projectName}-postQC $qcReports --pdf --export --filename ${projectName}_post_qc &
fi
