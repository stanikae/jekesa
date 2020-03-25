#!/bin/bash


indir=$project  
samples=$samples

# contaminants files
contaminants=$HOME/anaconda3/envs/jekesa/opt/fastqc*/Configuration/contaminant_list.txt
adapters=$HOME/anaconda3/envs/jekesa/opt/fastqc*/Configuration/adapter_list.txt


# quality filter fastq
fq1=$(find $indir -name "${samples}_*R1*f*q.gz")
fq2=$(find $indir -name "${samples}_*R2*f*q.gz")
	
trim_galore -q 20 \
--length 50 --trim-n -o $trimmedReads --gzip \
--paired $fq1 $fq2 \
--cores 4 \
--fastqc_args "-o $qcReports --contaminants $contaminants --adapters $adapters --threads $threads" \
#--retain_unpaired -r1 85 -r2 85


