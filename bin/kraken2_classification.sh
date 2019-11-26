#!/bin/bash

#krakenDB=/media/60tb/Databases/minikraken2_v2_8GB_201904_UPDATE #/media/60tb/src/kraken/NCBI
#trimmedReads=/media/60tb/nicd/crdm/bacteriology/kedibone/35B-Isolates/trimGalore_11_Sep_2019/clean_reads
#samples=11741
#filteredReads=/home/stanford/tmp/kraken2
#threads=16

#if ! [ -d $outdir ]; then
# mkdir -p $outdir
#fi

name=$samples
outdir=$filteredReads

read1=$(find $trimmedReads -name "${name}_S*val_1*fq.gz")
read2=$(find $trimmedReads -name "${name}_S*val_2*fq.gz")

echo $read1
echo $read2

#cat $read1 $read2 > $outdir/${name}_combined.fq.gz

# classify
echo -e "\nRunning Kraken2 classification `date`"
kraken2 --db $krakenDB --threads $threads --paired --unclassified-out $outdir/${name}#.fq \
--output $outdir/${name}.kraken --report $outdir/${name}.kraken.report \
--memory-mapping $read1 $read2 --gzip-compressed

# get unclassified contig IDs
#echo -e "\nGetting kraken unclassified reads `date`"
#cat $outdir/${name}.unclassified | grep "^>" | sed 's/>//1' > $outdir/${name}.unclassified.names

# Grouping classification report by percentage
reportFile=$outdir/${name}.kraken.report
firstEdit=$outdir/${name}.kraken.report-downstream.txt
reportTopHits=$outdir/${name}.kraken.report-top-4.txt

cat $reportFile | sort -k1,1nr | egrep -v "root|cellular organisms|group" | awk '$4 !~ /K|D|P|C|O|F|G/' | tr '\t' ',' > $firstEdit

#cat $firstEdit | head -n1
#echo
firstLine=$(cat $firstEdit | head -n1)
echo $firstLine
# awk '{if($4=="-")print} NR==5{exit}'

if [[ "$firstLine" =~ "-" ]]; then
   echo $firstLine | sed 's/,[[:space:]]\+/,/' > $reportTopHits #~/tmp/kraken_new_report.txt
   cat $firstEdit | awk -F ',' '$4 ~ /S/' | sort -t ',' -k1,1nr | head -n2 | sed -e 's/^[ \t]*//' | sed 's/,[[:space:]]\+/,/' >> $reportTopHits
   cat $firstEdit | awk -F ',' '$4 ~ /U/' | sed -e 's/^[ \t]*//' | sed 's/,[[:space:]]\+/,/' >> $reportTopHits #~/tmp/kraken_new_report.txt
else
   cat $firstEdit | awk -F ',' '$4 ~ /S/' | sort -t ',' -k1,1nr | head -n3 | sed -e 's/^[ \t]*//' | sed 's/,[[:space:]]\+/,/' > $reportTopHits
   cat $firstEdit | awk -F ',' '$4 ~ /U/' | sed -e 's/^[ \t]*//' | sed 's/,[[:space:]]\+/,/' >> $reportTopHits #~/tmp/kraken_new_report.txt
fi

# get IDs matching to species of interest
	
#topName=$(cat $reportTopHits | sed 's/,[[:space:]]\+/,/' | sort -t ',' -k1,1nr | awk -F, '{print $NF}' | head -n1 | tr ' ' '_')
#cat $outdir/${name}.kraken.translate.mpa | grep "$topName" | cut -f1 | sort -u > $outdir/${name}.matching.names

# combine IDs
#cat  $outdir/${name}.matching.names $outdir/${name}.unclassified.names > $outdir/${name}.names.txt

# get filtered reads for species of interest
#if [[ "$read1" =~ "BGI" ]]; then 
# if [[ "$read2" =~ "BGI" ]]; then 
#   #echo "true"
#   gunzip -c $read1 | sed -e '/^@S/s/\/1/ 1/' > $bbmapDir/${name}_S_1_val_1.fq
#   gunzip -c $read2 | sed -e '/^@S/s/\/2/ 2/' > $bbmapDir/${name}_S_2_val_2.fq
#   rm $read1
#   rm $read2
#   filterbyname.sh in=$bbmapDir/${name}_S_1_val_1.fq in2=$bbmapDir/${name}_S_2_val_2.fq out=$filteredReads/${name}_S_val_1.fq out2=$filteredReads/${name}_S_val_2.fq names=$outdir/${name}.names.txt include=t
   #compress the files
#   gzip $filteredReads/*.fq
#   gzip $bbmapDir/*.fq
# fi
#else
# filterbyname.sh in=$read1 in2=$read2 out=$filteredReads/${name}_S_val_1.fq out2=$filteredReads/${name}_S_val_2.fq names=$outdir/${name}.names.txt include=t
 #compress the files
# gzip $filteredReads/*.fq
#fi

