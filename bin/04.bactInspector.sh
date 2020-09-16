#!/bin/bash

# functions to process bactInspector output

check_species_edit () {
   sed -i 's/_S.*_val_1//' $1
   if [[ $(wc -l $1 | awk '{ print $1 }' ) -gt 2 ]]; then
      (head -n1 $1) && (tail -n -1 $1 | \
      sort -k3,3nr ) | head -n2 | \
      awk -F '\t' '{ print $1,$2" ("$3"%)" }' OFS=',' | \
      tail -n -1> $2
  else
      cat $1 | \
      awk -F '\t' '{ print $1,$2" ("$3"%)" }' OFS=',' | \
      tail -n -1 > $2
  fi
}

closest_match_edit () {
   echo -e "sampleID\trefseq_closest_match" > $bact_out/closest_refseq.tsv
   refseq=$(cut -f9 $bact_out/closest_matches_*.tsv | tail -n -1)
   echo -e "$name\t$refseq" >> $bact_out/closest_refseq.tsv
}

combine_bactIns () {
   echo -e "sampleID\trefseq_closest_match" > $1
   refseq=$(cut -f9 $2 | tail -n -1)
   echo -e "$name\t$refseq" >> $1
   speciesID=$(cat $3 | tail -n -1 )
   echo -e "$speciesID,$refseq" > $4	
}



for fq1 in $trimmedReads/*_R1_*fq.gz
do
  fq=$(echo $fq1 | awk -F "_R1" '{print $1 "_R2"}')
  fqfile=$(basename $fq)
  fq2=$(find $trimmedReads -name "${fqfile}*val_2.fq.gz")

  # outdir for each sample
  name=$(basename $fq1 | awk -F '_S' '{print $1}')
  bact_out=$project/bactInspector/$name

  if ! [ -d $bact_out ]; then
    mkdir -p $bact_out
  fi

  echo -e "`date` \tRunning bactInspector check_species"
  bactinspector check_species -p $threads -i $trimmedReads -o $bact_out -fq $fq1
  # edit check_species output
  check_species_edit $bact_out/species_investigation*.tsv $bact_out/species-inv-top1.tsv
  # edit check_species output
#  check_species_edit $bact_out/species_investigation*.tsv $bact_out/species-investigation-top1.tsv
#  sed -i 's/_S.*_val_1//' $bact_out/species_investigation*.tsv
#  if [[ $(wc -l $bact_out/species_investigation_*.tsv | awk '{ print $1 }' ) -gt 2 ]]; then
#	#cat $bact_out/species_investigation_*.tsv | head -n2 > $bact_out/species_investigation-top1.tsv
#	(head -n1 $bact_out/species_investigation_*.tsv) && (tail -n -1 $bact_out/species_investigation_*.tsv | \
#	sort -k3,3nr ) | head -n2 | \
#	awk -F '\t' '{ print $1,$2" ("$3"%)" }' OFS=',' | \
#	tail -n -1> $bact_out/species_investigation-top1.tsv
#  else
#	cat $bact_out/species_investigation*.tsv | \
#	awk -F '\t' '{ print $1,$2" ("$3"%)" }' OFS=',' | \
#	tail -n -1 > $bact_out/species_investigation-top1.tsv
#  fi

  #Rscript $SCRIPTS_DIR/converting_tsv_2_xlsx.R $bact_out/species_investigation-top1.tsv $reportsDir/${projectName}_species_investigation.xlsx

  echo -e "`date`\tRunning bactInspector closest_match"
  bactinspector closest_match -p $threads -i $bact_out -o $bact_out -r -m ${name}*.msh
  # edit closet_species output
  combine_bactIns $bact_out/closest_refseq.tsv $bact_out/closest_matches_*.tsv $bact_out/species-inv-top1.tsv $bact_out/${name}_bactInspector.csv
#  echo -e "sampleID\trefseq_closest_match" > $bact_out/closest_refseq.tsv
#  refseq=$(cut -f9 $bact_out/closest_matches_*.tsv | tail -n -1)
#  echo -e "$name\t$refseq" >> $bact_out/closest_refseq.tsv
#
#  # Combine species identification and closest match results
#  speciesID=$(cat $bact_out/species_investigation-top1.tsv | tail -n -1 )
#
#  #echo -e "sampleID,bactInspector_match,refseq_closest_match" > $bact_out/${name}_bactInspector.csv
#  #echo -e "$name,$speciesID,$refseq" > $bact_out/${name}_bactInspector.csv
#  echo -e "$speciesID,$refseq" > $bact_out/${name}_bactInspector.csv
done

# check species identity for previously assembled genomes
if [ -d $spadesDir/previousContigs ]; then
 
for contFile in $spadesDir/previousContigs/*_assembly.fasta
      do
        id=$(basename -s _assembly.fasta $contFile)
        bact_out=$project/bactInspector/$id
        if ! [ -d $bact_out ]; then
          mkdir -p $bact_out
        fi

        bactinspector check_species -i $spadesDir/previousContigs -o $bact_out -p $threads -n 2 -f $contFile
        bactinspector closest_match -i $spadesDir/previousContigs -o $bact_out -p $threads -f $contFile
      # edit check_species output
      check_species_edit $bact_out/species_investigation*.tsv $bact_out/species-inv-top1.tsv
      combine_bactIns $bact_out/closest_refseq.tsv $bact_out/closest_matches_*.tsv $bact_out/species-inv-top1.tsv $bact_out/${id}_bactInspector.csv
 done
fi

# save bactInspector results to xlsx
echo -e "sampleID,Species_Identification,refseq_closest_match" > $project/bactInspector/bactInspector_results.csv
for file in $(find $project/bactInspector -name "*_bactInspector.csv"); do
  cat $file >> $project/bactInspector/bactInspector_results.csv
done

# convert bactInspector .csv to .xlsx
Rscript $SCRIPTS_DIR/csv2xlsx.R $project/bactInspector/bactInspector_results.csv \
$reportsDir/04.bactInspector.xlsx >> $project/tmp/04.bactInspector.csv2xlsx.log 2>&1

