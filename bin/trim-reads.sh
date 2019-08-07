#!/bin/bash


indir=$project  
samples=$samples

# contaminants files
#contaminants=$HOME/Programs/FastQC/Configuration/contaminant_list.txt
#adapters=$HOME/Programs/FastQC/Configuration/adapter_list.txt


# quality filter fastq
fq1=$(find $indir -name "${samples}_*R1*f*q.gz")
fq2=$(find $indir -name "${samples}_*R2*f*q.gz")

echo $fq1
echo -e "\n$fq2"
	
trim_galore -q 20 \
--length 50 --trim-n -o $trimmedReads --gzip \
--paired $fq1 $fq2 \
--retain_unpaired -r1 85 -r2 85
#--fastqc_args "-o $qcReports --contaminants $contaminants --adapters $adapters --threads $threads" \


