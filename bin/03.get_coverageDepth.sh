#!/bin/bash

tmp=$project/tmp

if ! [ -d $tmp ]; then
 mkdir -p $tmp
fi

for fq1 in $project/*_R1_*f*q*
do
  #fq2=$(echo $fq1 | awk -F "R1" '{print $1 "R2" $2}')
  name=$(basename $fq1 | awk -F '_S' '{print $1}')
  
  cov_out=$project/coverageDepth/$name
  if ! [ -d $cov_out ]; then
    mkdir -p $cov_out
  fi

  # calculate number of bases in R1
  r1_bases=$(seqtk fqchk -q0 $project/${name}*_R1_*.f*q.gz |  grep "^ALL" | cut -f2)
  # estimate genome size using mash
  mash sketch -o $tmp/sketch -k 32 -m 3 -r $project/${name}*_R1_*.f*q.gz 2> $project/mash.txt
  gsize=$(cat $project/mash.txt | grep "Estimated genome size:" | awk -F ": " '{ print $2 }' | perl -ne 'printf "%d\n", $_;')
  # Calculate depth of coverage
  echo -e "$name,$gsize,`expr $r1_bases \* 2 / $gsize`" > $cov_out/${name}.csv
done

# save coverage results to xlsx
cat ${project}/coverageDepth/*/*.csv > ${project}/coverageDepth/coverage_merged.csv
echo "Sample,Est.GenomeSize,CoverageDepth" > ${project}/coverageDepth/${projectName}-coverage-final.csv
grep -v "^Sample,Est.GenomeSize,CoverageDepth" ${project}/coverageDepth/coverage_merged.csv >> ${project}/coverageDepth/${projectName}-coverage-final.csv
# convert coverage results to .xlsx file
Rscript $SCRIPTS_DIR/csv2xlsx.R ${project}/coverageDepth/${projectName}-coverage-final.csv \
$reportsDir/03.coverageDepth.xlsx >> $project/tmp/03.coverageDepth.csv2xlsx.log 2>&1
