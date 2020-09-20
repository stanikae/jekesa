#!/bin/bash

indir=$project
cleanDir=$trimmedReads

for fq1 in $indir/*_R1_*f*q*
do
  
 if [ -s $fq1 ]; then
  fq2=$(echo $fq1 | awk -F "_R1" '{print $1 "_R2" $2}')
  name=$(basename $fq1 | awk -F '_S' '{print $1}')
  # count raw reads number of reads
  rawReads=$(zcat $fq1 $fq2 | echo $((`wc -l`/4)))
  rawBases=$(zcat $fq1 $fq2 | paste - - - - | cut -f 2 | tr -d '\n' | wc -c)
  # count clean reads
  read1=$(find $cleanDir -name "${name}_*val_1.fq.gz")
  read2=$(find $cleanDir -name "${name}_*val_2.fq.gz")
  cleanReads=$(zcat $read1 $read2 | echo $((`wc -l`/4)))
  cleanBases=$(zcat $read1 $read2 | paste - - - - | cut -f 2 | tr -d '\n' | wc -c)
  echo -e "$name\t$rawReads\t$rawBases\t$cleanReads\t$cleanBases" >> $readsDir/total_reads.tsv
 fi
done

if [ -e $readsDir/total_reads.tsv ]; then
  echo -e "\t[`date +"%d-%b-%Y %T"`]\tSaving Read count data in MS excel format"
  echo -e "SampleID\tTotal.reads\tTotal.bases\tClean.reads\tClean.bases" > $readsDir/${projectName}-total_reads.tsv
  cat $readsDir/total_reads.tsv >> $readsDir/${projectName}-total_reads.tsv
  
  Rscript $SCRIPTS_DIR/tsv2xlsx.R $readsDir/${projectName}-total_reads.tsv \
  $reportsDir/03.countReads.xlsx >> $project/tmp/03.countReads.tsv2xlsx.log 2>&1
fi
