#!/bin/bash


bact_out=$project/bactInspector/$samples

if ! [ -d $bact_out ]; then
 mkdir -p $bact_out
fi

echo -e "Running bactInspector check_species"; date
bactinspector check_species -i $trimmedReads -o $bact_out -fq ${samples}_S_val_1*.gz

# edit check_species output
sed -i 's/_S_val_1//' $bact_out/species_investigation*.tsv
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

echo -e "Running bactInspector closest_match"; date
bactinspector closest_match -i $bact_out -o $bact_out -r -m ${samples}*.msh

# edit closet_species output
echo -e "sampleID\trefseq_closest_match" > $bact_out/closest_refseq.tsv
refseq=$(cut -f9 $bact_out/closest_matches_*.tsv | tail -n -1)
echo -e "$samples\t$refseq" >> $bact_out/closest_refseq.tsv

# Combine species identification and closest match results
speciesID=$(cat $bact_out/species_investigation-top1.tsv | tail -n -1 )

#echo -e "sampleID,bactInspector_match,refseq_closest_match" > $bact_out/${samples}_bactInspector.csv
echo -e "$samples,$speciesID,$refseq" > $bact_out/${samples}_bactInspector.csv
