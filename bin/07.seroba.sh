#!/bin/bash

for fq1 in $trimmedReads/*R1*f*q*
 do
  fq2=$(echo $fq1 | awk -F "R1" '{print $1 "R2" $2}')
  # outdir for each name
  name=$(basename $fq1 | awk -F '_S' '{print $1}')

  cd $serobaDir
  file1=$serobaDir/${name}_1.fq
  file2=$serobaDir/${name}_2.fq
  gunzip -c $fq1 > $file1
  gunzip -c $fq2 > $file2
  seroba runSerotyping $db_dir $file1 $file2 $serobaDir/$name
  rm $file1 $file2
done

cd $serobaDir
seroba summary $serobaDir
(echo -e "sample_Id\tserotype\tcomments\t" && cat summary.tsv) \
tr '\t' ',' | awk -F ',' '{gsub("/.*/","",$1)}1' OFS=',' > $serobaDir/summary_header.csv

# save seroba results to xlsx excel workbook
Rscript $SCRIPTS_DIR/csv2xlsx.R $serobaDir/summary_header.csv \
	$reportsDir/${projectName}_serobaResults.xlsx >> $project/tmp/converting_csv.log 2>&1
