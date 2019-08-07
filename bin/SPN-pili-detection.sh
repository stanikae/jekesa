#!/bin/bash

# Script to identify presence of pili in SPN WGS data

filename=$filename
workdir=$pilusDir
spadesDir=$spadesDir


#if ! [ -d "$workdir" ]; then
#	mkdir -p $workdir
#fi

for sample in $(cat $filename); do
	file=$(find $spadesDir -name "${sample}_scaffolds.fasta")
	contigs=$file
	name=$(basename -s _scaffolds.fasta $contigs)
	outdir=$workdir/$name

	if ! [ -d "$outdir" ]; then
        	mkdir -p $outdir
	fi

	prodigal_out=$outdir/prodigal.out
	protein_out=$outdir/protein.faa
	nucl_out=$outdir/nucleotide.fa
	gff_out=$outdir/annotations.gff

	# Step 1: get gene predictions
	prodigal -a $protein_out -c -d $nucl_out -f gff -i $contigs -o $prodigal_out

	# protein blastdb
	cd $outdir
	# Step 2: create BLAST databases
	makeblastdb -in $protein_out -dbtype prot -out spnDB
	# nucleotide blastdb
	makeblastdb -in $nucl_out -dbtype nucl -out spnDBnt

	# Step 3: perform blast analysis to check for presence of Pili
	# blastn
	blastn -db $outdir/spnDBnt -query ~/tmp/spn_pili.fna -out $outdir/spn_pili.out -word_size 7 -evalue 0.01 -outfmt "6 qseqid sseqid pident qlen slen length mismatch evalue bitscore qcovs"

	# Step 4: Sorting blastp output
	#cat $outdir/spn_pili.out | sort -k8,8nr -k3,3nr  
	# awk '{if($3 >= 95 && $NF >= 25) print}'
	cat $outdir/spn_pili.out | sort -k9,9nr -k3,3nr -k6,6nr | head -n1 | awk '{if($3 >= 95 && $NF >= 25) print}' > $outdir/best_hit.txt

	# Step 5: check if pilus is present and report
	echo "sampleID,Pili" > $outdir/${name}.pili.tsv

	if [ -s "$outdir/best_hit.txt" ]; then
		protID=$(cat "$outdir/best_hit.txt" | awk '{print $1}')
	
		if [ "$protID" == "ACO22459.1" ]; then
			ID="1:rrgA"
			echo "$name,$ID" >> $outdir/${name}.pili.tsv

		else
			ID="2:pitB"
			echo "$name,$ID" >> $outdir/${name}.pili.tsv
		fi

	else
		echo "$name,neg" >> $outdir/${name}.pili.tsv	

	fi

done

# Step 6: Merge reports into one report
for i in $(find $workdir -mindepth 2 -name "*.pili.tsv"); do cat $i; done | grep -v "^sampleID" > $workdir/Pili-combined-results.txt

echo "sampleID,Pili" > $workdir/Pili-combined-results.tsv
cat $workdir/Pili-combined-results.txt >> $workdir/Pili-combined-results.tsv

# Step 7: Convert tsv xlsx file
if [ -s $workdir/Pili-combined-results.tsv ]; then
	Rscript ~/repos/bacteria_denovo_assembly/converting_csv_2_xlsx.R $workdir/Pili-combined-results.tsv $reportsDir/${projectName}_pili-results.xlsx
fi

