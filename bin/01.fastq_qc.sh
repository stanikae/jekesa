#!/bin/bash

CONDA_BASE=$(conda info --base)
# contaminants files
contaminants=$CONDA_BASE/envs/jekesa/opt/fastqc*/Configuration/contaminant_list.txt
adapters=$CONDA_BASE/envs/jekesa/opt/fastqc*/Configuration/adapter_list.txt

for fq in $project/*f*q.gz
 do
    if [ -s $fq ];then
      fastqc -o $fastqc_out --contaminants $contaminants --adapters $adapters --threads $threads $fq
    fi
done

# combine all fastqc reports using mulitQC
if [ "$(ls -A $fastqc_out)" ]; then
 multiqc -o $reportsDir/${projectName}-beforeQC $fastqc_out --pdf --export --filename ${projectName}_b4_qc
fi
