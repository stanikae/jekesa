#!/bin/bash

CONDA_BASE=$(conda info --base)
# contaminants files
contaminants=$CONDA_BASE/envs/jekesa/opt/fastqc*/Configuration/contaminant_list.txt
adapters=$CONDA_BASE/envs/jekesa/opt/fastqc*/Configuration/adapter_list.txt

for fq in $project/*f*q.gz
 do
    fastqc -o $fastqc_out --contaminants $contaminants --adapters $adapters --threads $threads $fq
done

# combine all fastqc reports using mulitQC
#multiqc -o $reportsDir/$projectName $fastqc_out --pdf --export --filename ${projectName}_b4_qc
multiqc -o $reportsDir/${projectName}-beforeQC $fastqc_out --pdf --export --filename ${projectName}_b4_qc

