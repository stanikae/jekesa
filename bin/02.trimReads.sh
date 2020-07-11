#!/bin/bash


indir=$project  
#samples=$samples

CONDA_BASE=$(conda info --base)

# contaminants files
contaminants=$CONDA_BASE/envs/jekesa/opt/fastqc*/Configuration/contaminant_list.txt
adapters=$CONDA_BASE/envs/jekesa/opt/fastqc*/Configuration/adapter_list.txt


# quality filter fastq
#fq1=$(find $indir -name "${samples}_*R1*f*q.gz")
#fq2=$(find $indir -name "${samples}_*R2*f*q.gz")

for fq1 in $indir/*R1*f*q*
do
  fq2=$(echo $fq1 | awk -F "R1" '{print $1 "R2" $2}')
	
  trim_galore -q 20 \
  --length 50 --trim-n -o $trimmedReads --gzip \
  --paired $fq1 $fq2 \
  --cores 4 \
  --fastqc_args "-o $qcReports --contaminants $contaminants --adapters $adapters --threads $threads"
  #--retain_unpaired -r1 85 -r2 85
done

echo -e "\t[`date +"%d-%b-%Y %T"`]\tGenerating QC reports for clean reads using multiQC"
nohup multiqc -o $reportsDir/${projectName}-postQC $qcReports --pdf --export --filename ${projectName}_post_qc &

