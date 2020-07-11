#!/bin/bash

for read1 in $trimmedReads/*R1*f*q*
do
  read2=$(echo $fq1 | awk -F "R1" '{print $1 "R2" $2}')
  # outdir for each name
  name=$(basename $fq1 | awk -F '_S' '{print $1}')
  #mkdir -p $aribaDir/$name

  ln -s $read1 $aribaVF_Dir/${name}_1.fastq.gz
  ln -s $read2 $aribaVF_Dir/${name}_2.fastq.gz
  fq1=$aribaVF_Dir/${name}_1.fastq.gz
  fq2=$aribaVF_Dir/${name}_2.fastq.gz

  ariba run --threads $threads $ariba_VFref $fq1 $fq2 $aribaVF_Dir/${name}.run
  #rm $aribaVF_Dir/${name}_1.fastq.gz $aribaVF_Dir/${name}_2.fastq.gz
  rm $fq1 $fq2
  mv $aribaVF_Dir/${name}.run/report.tsv $aribaVF_Dir/${name}.run/${name}-report.tsv

done

# summarizing the identified virulence factors
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
  $reportsDir/${projectName}-aribaVFs-${var}-final.xlsx >> $project/tmp/converting_csv.log 2>&1
done

# merge and write ariba AMR and VF reports to xlsx
#Rscript $SCRIPTS_DIR/merge_files.R \
#        $reportsDir \
#        ${projectName}-aribaAMR-known_variants-final.xlsx \
#        ${projectName}-aribaVFs-known_variants-final.xlsx \
#        ${projectName}-ariba_final.xlsx >> $project/tmp/merge_files.log 2>&1

# copy ariba VF .tre and .csv files to reports directory
rsync -a $aribaVF_Dir/*{tre,csv} $reportsDir/ariba-VFs/


