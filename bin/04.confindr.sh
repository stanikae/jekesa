#!/bin/bash

#confindrDir=$project/ariba_${now}_analysis
if ! [ -d $confindrDir ]; then
  echo "creating confindr work directory"
  mkdir -p $confindrDir
fi
confindrDB=$DATABASES_DIR/confindr_db

for read1 in $trimmedReads/*R1*.fq.gz
do
  fq=$(echo $read1 | awk -F "R1" '{print $1 "R2"}')
  fqfile=$(basename $fq)
  read2=$(find $trimmedReads -name "${fqfile}*val_2.fq.gz")
  #read2=$(echo $fq1 | awk -F "R1" '{print $1 "R2" $2}')
  #outdir for each name
  name=$(basename $read1 | awk -F '_S' '{print $1}')

  ln -s $read1 $confindrDir/${name}_R1.fastq.gz
  ln -s $read2 $confindrDir/${name}_R2.fastq.gz
  fq1=$confindrDir/${name}_R1.fastq.gz
  fq2=$confindrDir/${name}_R2.fastq.gz

  mkdir -p $confindrDir/${name}
  echo "$confindrDir/${name}"

  confindr.py -i ${confindrDir}/ -o ${confindrDir}/${name} -d $confindrDB
  rm $fq1 $fq2
done

# Save confindr results in one .csv file
cat ${confindrDir}/*/*_report.csv > ${confindrDir}/confindr_merged.csv
echo "Sample,Genera_present,ContaminationPresent" > ${confindrDir}/${projectName}-confindr-final.csv
grep -v '^Sample' ${confindrDir}/confindr_merged.csv | \
sed 's/_.*1,/,/g' | cut -d "," -f1,2,4,5 | \
awk -F ',' '{print $1,$2,$3" ("$4"%)"}' OFS="," >> ${confindrDir}/${projectName}-confindr-final.csv

# Convert confindr results to .xlsx file
Rscript $SCRIPTS_DIR/csv2xlsx.R $confindrDir/${projectName}-confindr-final.csv \
$reportsDir/04.confindr.xlsx >> $project/tmp/04.confindr.csv2xlsx.log 2>&1
