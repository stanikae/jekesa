#!/bin/bash

for fq1 in $trimmedReads/*R1*fq.gz
do
  fq=$(echo $fq1 | awk -F "R1" '{print $1 "R2"}')
  fqfile=$(basename $fq)
  fq2=$(find $trimmedReads -name "${fqfile}*val_2.fq.gz")

  # outdir for each sample
  name=$(basename $fq1 | awk -F '_S' '{print $1}')
  bact_out=$project/bactInspector/$name

  if ! [ -d $bact_out ]; then
    mkdir -p $bact_out
  fi

  #echo -e "`date` \tRunning bactInspector check_species"
  bactinspector check_species -i $trimmedReads -o $bact_out -fq $fq1

  # edit check_species output
  sed -i 's/_S_R1_val_1//' $bact_out/species_investigation*.tsv
  if [[ $(wc -l $bact_out/species_investigation_*.tsv | awk '{ print $1 }' ) -gt 2 ]]; then
	#cat $bact_out/species_investigation_*.tsv | head -n2 > $bact_out/species_investigation-top1.tsv
	(head -n1 $bact_out/species_investigation_*.tsv) && (tail -n -1 $bact_out/species_investigation_*.tsv | \
	sort -k3,3nr ) | head -n2 | \
	awk -F '\t' '{ print $1,$2" ("$3"%)" }' OFS=',' | \
	tail -n -1> $bact_out/species_investigation-top1.tsv
  else
	cat $bact_out/species_investigation*.tsv | \
	awk -F '\t' '{ print $1,$2" ("$3"%)" }' OFS=',' | \
	tail -n -1 > $bact_out/species_investigation-top1.tsv
  fi

  #Rscript $SCRIPTS_DIR/converting_tsv_2_xlsx.R $bact_out/species_investigation-top1.tsv $reportsDir/${projectName}_species_investigation.xlsx

  echo -e "`date`\tRunning bactInspector closest_match"
  bactinspector closest_match -i $bact_out -o $bact_out -r -m ${name}*.msh
  # edit closet_species output
  echo -e "sampleID\trefseq_closest_match" > $bact_out/closest_refseq.tsv
  refseq=$(cut -f9 $bact_out/closest_matches_*.tsv | tail -n -1)
  echo -e "$name\t$refseq" >> $bact_out/closest_refseq.tsv

  # Combine species identification and closest match results
  speciesID=$(cat $bact_out/species_investigation-top1.tsv | tail -n -1 )

  #echo -e "sampleID,bactInspector_match,refseq_closest_match" > $bact_out/${name}_bactInspector.csv
  echo -e "$name,$speciesID,$refseq" > $bact_out/${name}_bactInspector.csv
done

# save bactInspector results to xlsx
echo -e "sampleID,Species_Identification,refseq_closest_match" > $project/bactInspector/bactInspector_results.csv
for file in $(find $project/bactInspector -name "*_bactInspector.csv"); do
  cat $file >> $project/bactInspector/bactInspector_results.csv
done

# convert bactInspector .csv to .xlsx
Rscript $SCRIPTS_DIR/csv2xlsx.R $project/bactInspector/bactInspector_results.csv \
$reportsDir/04.bactInspector.xlsx >> $project/tmp/04.bactInspector.csv2xlsx.log 2>&1

