#!/bin/bash


# Detection of virulence factors
#ariba_ref=~/ariba_DBs/out.card.prepareref
#aribaVF_Dir=$project/ariba_${now}_analysis
#$project/ariba_${now}
#mkdir -p $aribaVF_Dir

#aribaVF_Dir=$project/virulenceFactorDetection

#if ! [ -d $aribaVF_Dir ]; then
# mkdir -p $aribaVF_Dir
#fi
 
sample=$samples
trimmedReads=$filteredReads

read1=$(find $trimmedReads -maxdepth 1 -name "${sample}_S*val_1*.gz") #*val_1*.gz #_*val_1*fq.gz
read2=$(find $trimmedReads -maxdepth 1 -name "${sample}_S*val_2*.gz")
ln -s $read1 $aribaVF_Dir/${sample}_1.fastq.gz
ln -s $read2 $aribaVF_Dir/${sample}_2.fastq.gz
fq1=$aribaVF_Dir/${sample}_1.fastq.gz
fq2=$aribaVF_Dir/${sample}_2.fastq.gz


ariba run --threads $threads $ariba_VFref $fq1 $fq2 $aribaVF_Dir/${sample}.run
#rm $aribaVF_Dir/${sample}_1.fastq.gz $aribaVF_Dir/${sample}_2.fastq.gz
rm $fq1 $fq2
mv $aribaVF_Dir/${sample}.run/report.tsv $aribaVF_Dir/${sample}.run/${sample}-report.tsv

#done
