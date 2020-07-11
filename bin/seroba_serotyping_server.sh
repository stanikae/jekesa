#!/bin/bash

#declare -x project=$1 #path to output directory
#declare -x filename=$2
#declare -x path=$3
#declare -x threads=$4
#declare -x MLSTscheme=$5


#trimmedReads=/home/stanford/CRDM_batch01/trimGalore_18_Feb_2019/clean_reads
#samples=$filename
sample=$samples
#now=$(date +"%d_%b_%Y")
#db_dir=/opt/seroba_db
#cleanReads=$indir
#indir=$trimmedReads
indir=$filteredReads
#serobaDir=$project/seroba_${now}_analysis
workDir=$serobaDir #$path/$project

#mkdir -p $serobaDir
# 1: create database for kmc and ariba

#usage: seroba createDBs  <database dir> <kmer size>
#Creates a Database for kmc and ariba
#positional arguments:
#    database dir     output directory for kmc and ariba Database
#    kmer size   kmer_size you want to use for kmc , recommended = 71

#seroba createDBs my_database/ 71
    
# 2: Identify serotype of your input data
cd $workDir

#for sample in $(< $samples)
# do
        #mkdir -p $serobaDir
echo $sample
	#file1=$serobaDir/f1_1.fq
	#file2=$serobaDir/f2_2.fq 
fq1=$(find $indir -maxdepth 1 -name "${sample}_S*val_1*.gz") #*val_1*.gz #_*val_1*fq.gz
fq2=$(find $indir -maxdepth 1 -name "${sample}_S*val_2*.gz")
name=$(basename $fq1 | cut -d_ -f1)
echo -e "$fq1\t$fq2"
file1=$serobaDir/$name\_1.fq
file2=$serobaDir/$name\_2.fq
gunzip -c $fq1 > $file1
gunzip -c $fq2 > $file2
readlink -f $file1
readlink -f $file2
#echo -e "$fq1\t$fq2"
seroba runSerotyping $db_dir $file1 $file2 $serobaDir/$sample
rm $file1 $file2
#done

# seroba runSerotyping  /opt/seroba_db/ ~/tmp/seroba_analysis/f1_1.fq ~/tmp/seroba_analysis/f1_2.fq ~/tmp/seroba_analysis/f1_test
# 3: Summaries the output in one tsv file
#cd $workDir
#seroba summary  $serobaDir
#(echo -e "sample_Id\tserotype\tcomments\t" && cat summary.tsv) | tr '\t' ',' | awk -F, '{gsub("/.*/","",$1)}1' OFS=, > $workDir/summary_header.csv

# save seroba results to xlsx excel workbook
#Rscript ~/repos/bacteria_denovo_assembly/converting_csv_2_xlsx.R  $workDir/summary_header.csv $reportsDir/${projectName}_serobaResults.xlsx

