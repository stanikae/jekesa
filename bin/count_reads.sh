#!/bin/bash

sampleID=$samples
indir="$countsRaw"
cleanDir="$countsTrimmed"
#$trimgaloreDir
#readsDir=$project/total_reads

#if ! [ -d $readsDir ]; then
# mkdir -p $readsDir
#fi
 
# count raw reads number of reads
fq1=$(find $indir -maxdepth 1 -name "${sampleID}_*R1*.f*q.gz")
fq2=$(find $indir -maxdepth 1 -name "${sampleID}_*R2*.f*q.gz")
rawReads=$(reformat.sh in=$fq1 in2=$fq2 2>&1 >/dev/null | grep "Input:" | cut -f 2,3)
echo -e "Raw read1:\t$fq1"
echo -e "Raw read2:\t$fq2"
echo -e "Raw reads:\t$rawReads"
# count clean reads
echo -e "Clean reads:\t$countsTrimmed\t$cleanDir"
echo -e "Output directory:\t$readsDir"
read1=$(find $cleanDir -name "${sampleID}_*val_1.fq.gz")
read2=$(find $cleanDir -name "${sampleID}_*val_2.fq.gz")
echo -e "Read1:\t$read1"
echo -e "Read2:\t$read2"
cleanReads=$(reformat.sh in=$read1 in2=$read2 2>&1 >/dev/null | grep "Input:" | cut -f 2,3)
echo -e "Clean reads:\t$cleanReads"
echo -e "$sampleID\t$rawReads\t$cleanReads" | awk -v OFS="\t" '{print $1,$2,$4,$6,$8}' >> $readsDir/total_reads.tsv
#echo -e "SampleID\tTotal_reads\tTotal_yield\tClean_reads\tClean_bases" 
cat $readsDir/total_reads.tsv 
