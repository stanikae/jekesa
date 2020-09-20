#!/bin/bash

for read1 in $trimmedReads/*_R1_*.fq.gz
do
 if [ -s $read1 ];then
  fq=$(echo $read1 | awk -F "_R1" '{print $1 "_R2"}')
  fqfile=$(basename $fq)
  read2=$(find $trimmedReads -name "${fqfile}*val_2.fq.gz")
  # outdir for each name
  name=$(basename $read1 | awk -F '_S' '{print $1}')
  #mkdir -p $aribaDir/$name

  ln -s $read1 $aribaVF_Dir/${name}_1.fastq.gz
  ln -s $read2 $aribaVF_Dir/${name}_2.fastq.gz
  fq1=$aribaVF_Dir/${name}_1.fastq.gz
  fq2=$aribaVF_Dir/${name}_2.fastq.gz

  ariba run --threads $threads $ariba_VFref $fq1 $fq2 $aribaVF_Dir/${name}.run
  #rm $aribaVF_Dir/${name}_1.fastq.gz $aribaVF_Dir/${name}_2.fastq.gz
  rm $fq1 $fq2
  mv $aribaVF_Dir/${name}.run/report.tsv $aribaVF_Dir/${name}.run/${name}-report.tsv
 fi
done

# summarizing the identified virulence factors
if [ "$(ls -A $aribaVF_Dir)" ]; then
# get known variants
ariba summary --known_variants $aribaVF_Dir/${projectName}-aribaVF_known_variants.summary `find $aribaVF_Dir -name "*-report.tsv"`
# get novel variants
ariba summary --novel_variants $aribaVF_Dir/${projectName}-aribaVF_novel_variants.summary `find $aribaVF_Dir -name "*-report.tsv"`
# ariba cluster all
ariba summary --preset cluster_all $aribaVF_Dir/${projectName}-aribaVF_cluster_all.summary `find $aribaVF_Dir -name "*-report.tsv"`

for var in $(echo -e "known_variants\nnovel_variants\ncluster_all"); do
  cat $aribaVF_Dir/${projectName}-aribaVF_${var}.summary.csv | \
  sed 's|.*\.run/||' | sed 's|-report.tsv||' > $aribaVF_Dir/${projectName}-aribaVFs-${var}-final.csv
  # convert .csv to .xlsx
  Rscript $SCRIPTS_DIR/csv2xlsx.R \
  $aribaVF_Dir/${projectName}-aribaVFs-${var}-final.csv \
  $reportsDir/06.aribaVFs-${var}.xlsx >> $project/tmp/06.aribaVFs-${var}.csv2xlsx.log 2>&1
done

# copy ariba VF .tre and .csv files to reports directory
rsync -a $aribaVF_Dir/*{tre,csv} $reportsDir/ariba-VFs/
fi

