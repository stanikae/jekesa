#!/bin/bash

for fq1 in $trimmedReads/*R1*f*q*
do
  fq2=$(echo $fq1 | awk -F "R1" '{print $1 "R2" $2}')
  # outdir for each sample
  name=$(basename $fq1 | awk -F '_S' '{print $1}')
  mkdir -p $krakenDir/$name

  # classify
  kraken2 --db $krakenDB --threads $threads --paired \
  --output $outdir/${name}.kraken \
  --report $outdir/${name}.kraken.report \
  --memory-mapping $fq1 $fq2 --gzip-compressed \
  --unclassified-out $outdir/${name}#.fq

  # Grouping classification report by percentage
  reportFile=$outdir/${name}.kraken.report
  firstEdit=$outdir/${name}.kraken.report-downstream.txt
  reportTopHits=$outdir/${name}.kraken.report-top-4.txt

  cat $reportFile | sort -k1,1nr | egrep -v "root|cellular organisms|group" | awk '$4 !~ /K|D|P|C|O|F|G/' | tr '\t' ',' > $firstEdit
  firstLine=$(cat $firstEdit | head -n1)
  #echo $firstLine
  # awk '{if($4=="-")print} NR==5{exit}'

  if [[ "$firstLine" =~ "-" ]]; then
    echo $firstLine | sed 's/,[[:space:]]\+/,/' > $reportTopHits #~/tmp/kraken_new_report.txt
    cat $firstEdit | awk -F ',' '$4 ~ /S/' | sort -t ',' -k1,1nr | head -n2 | sed -e 's/^[ \t]*//' | sed 's/,[[:space:]]\+/,/' >> $reportTopHits
    cat $firstEdit | awk -F ',' '$4 ~ /U/' | sed -e 's/^[ \t]*//' | sed 's/,[[:space:]]\+/,/' >> $reportTopHits #~/tmp/kraken_new_report.txt
  else
    cat $firstEdit | awk -F ',' '$4 ~ /S/' | sort -t ',' -k1,1nr | head -n3 | sed -e 's/^[ \t]*//' | sed 's/,[[:space:]]\+/,/' > $reportTopHits
    cat $firstEdit | awk -F ',' '$4 ~ /U/' | sed -e 's/^[ \t]*//' | sed 's/,[[:space:]]\+/,/' >> $reportTopHits #~/tmp/kraken_new_report.txt
  fi

done

# save kraken report to csv and convert to .xlsx
inDir=$krakenDir #$project/kraken
outDir=$krakenDir #$project/kraken

echo "assembly,kraken_match_#1,kraken_match_#2,kraken_match_#3,kraken_unclassified," > $outDir/${projectName}-kraken_combinedReports.csv

for file in $(find $inDir -name "*.kraken.report-top-4.txt"); do
  name=$(basename -s .kraken.report-top-4.txt $file)
  report1=$(cat $file | sed 's/,[[:space:]]\+/,/' | sort -t ',' -k1,1nr | awk -F ',' '{print $NF, "("$1"%)"}' | tr '\n' ',')
  echo -e "$name,$report1" >> $outDir/${projectName}-kraken_combinedReports.csv
done

# convert kraken .csv to .xlsx
Rscript $SCRIPTS_DIR/csv2xlsx.R \
$outDir/${projectName}-kraken_combinedReports.csv \
$reportsDir/${projectName}-kraken_combinedReports.xlsx >> $project/tmp/converting_csv.log 2>&1

