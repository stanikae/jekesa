#!/bin/bash

#confindrDir=$project/ariba_${now}_analysis

#mkdir -p $confindrDir
confindrDB=$DATABASES_DIR/confindr_db
sample=$samples

read1=$(find $trimmedReads -maxdepth 1 -name "${sample}_S*val_1*.gz") #*val_1*.gz #_*val_1*fq.gz
read2=$(find $trimmedReads -maxdepth 1 -name "${sample}_S*val_2*.gz")
ln -s $read1 $confindrDir/${sample}_R1.fastq.gz
ln -s $read2 $confindrDir/${sample}_R2.fastq.gz
fq1=$confindrDir/${sample}_R1.fastq.gz
fq2=$confindrDir/${sample}_R2.fastq.gz

echo $fq1
echo $fq2

mkdir -p $confindrDir/${sample}
echo "$confindrDir/${sample}"

confindr.py -i ${confindrDir}/ -o ${confindrDir}/${sample} -d $confindrDB
rm $fq1 $fq2
#mv $confindrDir/${sample}.run/report.tsv $confindrDir/${sample}.run/${sample}-report.tsv

#done
