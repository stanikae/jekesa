#!/bin/bash

# functions
edit_kraken_report () {
  reportFile=$1
  firstEdit=$2
  reportTopHits=$3

  cat $reportFile | sort -k1,1nr | \
  egrep -v "root|cellular organisms|group" | \
  awk '$4 !~ /K|D|P|C|O|F|G/' | tr '\t' ',' > $firstEdit
  
  firstLine=$(cat $firstEdit | head -n1)

  if [[ "$firstLine" =~ "-" ]]; then
    echo $firstLine | sed 's/,[[:space:]]\+/,/' > $reportTopHits
    #
    cat $firstEdit | awk -F ',' '$4 ~ /S/' | \
    sort -t ',' -k1,1nr | head -n2 | \
    sed -e 's/^[ \t]*//' | sed 's/,[[:space:]]\+/,/' >> $reportTopHits
    #
    cat $firstEdit | awk -F ',' '$4 ~ /U/' | \
    sed -e 's/^[ \t]*//' | sed 's/,[[:space:]]\+/,/' >> $reportTopHits
  else
    cat $firstEdit | awk -F ',' '$4 ~ /S/' | \
    sort -t ',' -k1,1nr | head -n3 | \
    sed -e 's/^[ \t]*//' | sed 's/,[[:space:]]\+/,/' > $reportTopHits
    #
    cat $firstEdit | awk -F ',' '$4 ~ /U/' | \
    sed -e 's/^[ \t]*//' | sed 's/,[[:space:]]\+/,/' >> $reportTopHits
  fi
}

# run script
for fq1 in $trimmedReads/*_R1_*.fq.gz
do
  if [ -s $fq1 ]; then
  fq=$(echo $fq1 | awk -F "_R1" '{print $1 "_R2"}')
  fqfile=$(basename $fq)
  fq2=$(find $trimmedReads -name "${fqfile}*val_2.fq.gz")
  # outdir for each sample
  name=$(basename $fq1 | awk -F '_S' '{print $1}')
  mkdir -p $krakenDir/$name

  # classify
  kraken2 --db $krakenDB --threads $threads --paired \
  --output $krakenDir/"$name"/${name}.kraken \
  --report $krakenDir/"$name"/${name}.kraken.report \
  --memory-mapping $fq1 $fq2 --gzip-compressed \
  --unclassified-out $krakenDir/"$name"/${name}#_unclassified.fq

  # Grouping classification report by percentage
  edit_kraken_report $krakenDir/$name/${name}.kraken.report \
  $krakenDir/$name/${name}.kraken.report-downstream.txt $krakenDir/$name/${name}.kraken.report-top-4.txt 
 fi
done

# check species identity for previously assembled genomes
if [ -d $spadesDir/previousContigs ]; then
 for contFile in $spadesDir/previousContigs/*_assembly.fasta
      do
        id=$(basename -s _assembly.fasta $contFile)
        krak_out=$krakenDir/$id
        if ! [ -d $krak_out ]; then
          mkdir -p $krak_out
        fi

        kraken2 --db $krakenDB --threads $threads \
        --output $krak_out/${id}.kraken --report $krak_out/${id}.kraken.report \
        --memory-mapping  --unclassified-out $krak_out/${id}_unclassified.fa $contFile

      # Group by percentage
      edit_kraken_report $krak_out/${id}.kraken.report $krak_out/${id}.kraken.report-downstream.txt $krak_out/${id}.kraken.report-top-4.txt 
 done
fi

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
Rscript $SCRIPTS_DIR/csv2xlsx.R $outDir/${projectName}-kraken_combinedReports.csv \
$reportsDir/04.kraken.xlsx >> $project/tmp/04.kraken.csv2xlsx.log 2>&1

