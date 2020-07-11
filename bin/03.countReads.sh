#!/bin/bash

indir=$project
cleanDir=$trimmedReads
#$trimgaloreDir
#readsDir=$project/total_reads

#if ! [ -d $readsDir ]; then
# mkdir -p $readsDir
#fi
for fq1 in $indir/*R1*f*q*
do
  fq2=$(echo $fq1 | awk -F "R1" '{print $1 "R2" $2}')
  name=$(basename $fq1 | awk -F '_S' '{print $1}')
  # count raw reads number of reads
  #fq1=$(find $indir -maxdepth 1 -name "${name}_*R1*.f*q.gz")
  #fq2=$(find $indir -maxdepth 1 -name "${name}_*R2*.f*q.gz")
  #rawReads=$(reformat.sh in=$fq1 in2=$fq2 2>&1 >/dev/null | grep "Input:" | cut -f 2,3)
  rawReads=$(zcat $fq1 $fq2 | echo $((`wc -l`/4)))
  rawBases=$(zcat $fq1 $fq2 | paste - - - - | cut -f 2 | tr -d '\n' | wc -c)
  # count clean reads
  read1=$(find $cleanDir -name "${name}_*val_1.fq.gz")
  read2=$(find $cleanDir -name "${name}_*val_2.fq.gz")
  #cleanReads=$(reformat.sh in=$read1 in2=$read2 2>&1 >/dev/null | grep "Input:" | cut -f 2,3)
  cleanReads=$(zcat $read1 $read2 | echo $((`wc -l`/4)))
  cleanBases=$(zcat $read1 $read2 | paste - - - - | cut -f 2 | tr -d '\n' | wc -c)
  echo -e "$name\t$rawReads\t$rawBases\t$cleanReads\t$cleanBases" >> $readsDir/total_reads.tsv
done

echo -e "\t[`date +"%d-%b-%Y %T"`]\tSaving Read count data in MS excel format"
echo -e "SampleID\tTotal_reads\tTotal_yield\tClean_reads\tClean_bases" > $readsDir/${projectName}-total_reads.tsv
cat $readsDir/total_reads.tsv >> $readsDir/${projectName}-total_reads.tsv

if [ -e $readsDir/${projectName}-total_reads.tsv ]; then
  Rscript $SCRIPTS_DIR/tsv2xlsx.R \
	$readsDir/${projectName}-total_reads.tsv \
	$reportsDir/${projectName}-total_reads.xlsx >> $project/tmp/converting_tsv.log 2>&1
fi
