#!/bin/bash


#fastqc_out=$indir/fastqcReports\_$now
#indir=$project
# sample files
#samples=$HOME/sampleID_file
#samples=$filename
#samples=$samples

# contaminants files
contaminants=$HOME/Programs/FastQC/Configuration/contaminant_list.txt
adapters=$HOME/Programs/FastQC/Configuration/adapter_list.txt

for fq in $project/*.gz
#for fq in $(find $project -name "*${samples}*.gz")
 do
	fastqc -o $fastqc_out --contaminants $contaminants --adapters $adapters --threads $threads $fq
done

# combine all fastqc reports using mulitQC
#multiqc -o $reportsDir/$projectName $fastqc_out --pdf --export --filename ${projectName}_b4_qc

# quality filter fastq 
#trimming fastq reads

#trim_galore -q 5 \
#--fastqc_args "-o $outdir --contaminants $contaminants --adapters $adapters --threads 8" \
#--length 75 --trim-n -o $trimmedReads --gzip --paired $fastq1 $fastq2 \
#--retain_unpaired -r1 85 -r2 85

# check quality metrics using multiQC
#multiqc -d $outdir -o $outdir

