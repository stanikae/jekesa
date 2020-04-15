#!/bin/bash


# Detection of resistance genes, virulence factors and plasmid detection
#ariba_ref=~/ariba_DBs/out.card.prepareref
#aribaDir=$project/ariba_${now}_analysis

#mkdir -p $aribaDir
sample=$samples
# This resistance typing step is currently only using CARD database to identify resistance genes
#for sample in $(cat $filename)
# do
trimmedReads=$filteredReads

read1=$(find $trimmedReads -maxdepth 1 -name "${sample}_S*val_1*.gz") #*val_1*.gz #_*val_1*fq.gz
read2=$(find $trimmedReads -maxdepth 1 -name "${sample}_S*val_2*.gz")
ln -s $read1 $aribaDir/${sample}_1.fastq.gz
ln -s $read2 $aribaDir/${sample}_2.fastq.gz
fq1=$aribaDir/${sample}_1.fastq.gz
fq2=$aribaDir/${sample}_2.fastq.gz


ariba run --threads $threads $ariba_ref $fq1 $fq2 $aribaDir/${sample}.run
#rm $aribaDir/${sample}_1.fastq.gz $aribaDir/${sample}_2.fastq.gz
rm $fq1 $fq2
mv $aribaDir/${sample}.run/report.tsv $aribaDir/${sample}.run/${sample}-report.tsv

#done
