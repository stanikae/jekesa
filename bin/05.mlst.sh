#!/bin/bash

for contigs in $(find $spadesDir -name "*_assembly.fasta")
do
  name=$(basename $contigs | sed 's/_assembly.fasta//')
  mkdir -p $mlstDir/$name

  # perform MLST typing using mlst tool
  #MLSTscheme="noScheme"
  if grep -q "$MLSTscheme" "$schemeList"; then
        echo -e "$MLSTscheme found in MLST database, proceeding with MLST typing\n"
        mlst --legacy --scheme $MLSTscheme --threads $threads --nopath \
        --novel $mlstDir/mlst_novel.fa $contigs --quiet >> $mlstDir/mlst_allele.tsv

  elif [ $MLSTscheme == "noScheme" ]; then
        echo -e "$MLSTscheme NOT found in MLST database, now performing MLST typing against the entire database\n"
        #FILE    SCHEME  ST
        mlst --threads $threads --nopath $contigs >> $mlstDir/mlst_allele.tsv
  else
       # now=$(date +"%d_%b_%Y")
       # declare -x mlstDir=$project/mlst_output\_$now
       # mkdir -p $mlstDir
        echo -e "$MLSTscheme NOT found in MLST database\n"
        #mlst --threads $threads --nopath $spadesDir/$name/$name*.fa* >> $mlstDir/mlst_allele.tsv
        echo -e "FILE\tSCHEME\tST" > $mlstDir/mlst_allele.tsv
        echo -e "$name\t-\t-" >> $mlstDir/mlst_allele.tsv
 fi
done

# saving mlst typing .csv results to xlsx format
if [[ "$MLSTscheme" == "noScheme" ]]; then
  names1=$(echo -e "FILE\tSCHEME\tST")
  num1=$(cat $mlstDir/mlst_allele.tsv | awk '{print NF}' | sort -nr -u | head -n1)
  num="$(($num1-3))"
  names2=$(yes "gene" | head -n $num | paste -s -d '\t' -)
  names=$(echo -e "$names1\t$names2")
  (echo $names | tr ' ' '\t') > $mlstDir/mlst_merged.tsv && \
  awk -v OFS='\t' '{gsub(/_.*/,"",$1);print}' $mlstDir/mlst_allele.tsv >> $mlstDir/mlst_merged.tsv
else
  (head -n1 $mlstDir/mlst_allele.tsv) > $mlstDir/mlst_merged.tsv && \
  grep -v "^FILE" $mlstDir/mlst_allele.tsv  | awk -v OFS='\t' '{gsub(/_.*/,"",$1);print}' >> $mlstDir/mlst_merged.tsv
fi

# saving mlst typing .csv results to xlsx format
#echo -e "\t[`date +"%d-%b-%Y %T"`]\tSaving WGS typing results in MS excel format"
if [ -e $mlstDir/mlst_merged.tsv ]; then
  Rscript $SCRIPTS_DIR/tsv2xlsx.R $mlstDir/mlst_merged.tsv \
  $reportsDir/05.mlst.xlsx >> $project/tmp/05.mlst.tsv2xlsx.log 2>&1
fi



