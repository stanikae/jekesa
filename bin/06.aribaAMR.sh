#!/bin/bash

for read1 in $trimmedReads/*R1*.fq.gz
do
  fq=$(echo $read1 | awk -F "R1" '{print $1 "R2"}')
  fqfile=$(basename $fq)
  read2=$(find $trimmedReads -name "${fqfile}*val_2.fq.gz")
  
  # outdir for each name
  name=$(basename $read1 | awk -F '_S' '{print $1}')
  #mkdir -p $aribaDir/$name

  ln -s $read1 $aribaDir/${name}_1.fastq.gz
  ln -s $read2 $aribaDir/${name}_2.fastq.gz
  fq1=$aribaDir/${name}_1.fastq.gz
  fq2=$aribaDir/${name}_2.fastq.gz

  ariba run --threads $threads $ariba_ref $fq1 $fq2 $aribaDir/${name}.run
  #rm $aribaDir/${name}_1.fastq.gz $aribaDir/${name}_2.fastq.gz
  rm $fq1 $fq2
  mv $aribaDir/${name}.run/report.tsv $aribaDir/${name}.run/${name}-report.tsv

done

# summarizing the identified resistance genes
# get known variants
ariba summary --known_variants $aribaDir/${projectName}-aribaAMR_known_variants.summary `find $aribaDir -name "*-report.tsv"`
# get novel variants
ariba summary --novel_variants $aribaDir/${projectName}-aribaAMR_novel_variants.summary `find $aribaDir -name "*-report.tsv"`
# ariba cluster all
ariba summary --preset cluster_all $aribaDir/${projectName}-aribaAMR_cluster_all.summary `find $aribaDir -name "*-report.tsv"`

# editing the report summary
#if [[ "$MLSTscheme" == "spneumoniae" ]]; then
#  for var in $(echo -e "known_variants\nnovel_variants\ncluster_all"); do
#    cat $aribaDir/${projectName}-aribaAMR_${var}.summary.csv | \
#    sed 's|.*\.run/||' | sed 's|-report.tsv||' \
#    sed 's|Streptococcus_pneumoniae|SPN|g' > $aribaDir/${projectName}-aribaAMR-${var}-final.csv
#  done
#else

for var in $(echo -e "known_variants\nnovel_variants\ncluster_all"); do
  cat $aribaDir/${projectName}-aribaAMR_${var}.summary.csv | \
  sed 's|.*\.run/||' | sed 's|-report.tsv||' > $aribaDir/${projectName}-aribaAMR-${var}-final.csv
done

# writing ariba report to xlsx
for var in $(echo -e "known_variants\nnovel_variants\ncluster_all"); do
  Rscript $SCRIPTS_DIR/csv2xlsx.R $aribaDir/${projectName}-aribaAMR-${var}-final.csv \
  $reportsDir/06.aribaAMR-${var}.xlsx >> $project/tmp/06.aribaAMR-${var}.csv2xlsx.log 2>&1
done

# copy ariba AMR .tre and .csv files to reports directory
rsync -a $aribaDir/*{tre,csv} $reportsDir/ariba-AMR/

