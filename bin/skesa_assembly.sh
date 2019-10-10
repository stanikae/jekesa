#!/bin/bash

indir=$filteredReads
echo $spadesDir
sample=$samples

mkdir -p $spadesDir/$sample
fq1=$(find $indir -maxdepth 1 -name "${sample}_S*val_1*.gz") #*val_1*.gz #*val_1*f*q.gz
fq2=$(find $indir -maxdepth 1 -name "${sample}_S*val_2*.gz")
	
# unpaired reads after quality filtering
fqU1=$(find $indir -name "${sample}_S*unpaired_1*f*q.gz")
fqU2=$(find $indir -name "${sample}_S*unpaired_2*f*q.gz")
	

skesa --fastq $fq1,$fq2 --cores $threads --memory 48 --contigs_out $spadesDir/$sample/${sample}_assembly.fasta

# rename contigs files using sampleID
#for i in `find $spadesDir/$sample -maxdepth 1 -type f \( -name "scaffolds.fasta" -o -name "assembly.fasta" \)`
# do
#        echo $i
#        name=$(dirname $i)
#        name2=$(basename $name)
#        echo $name2
#       rename "s/scaffolds.fasta/${name2}_scaffolds.fasta/" $i
#        if [[ "$i" =~ "assembly.fasta" ]]
#         then
#                mv $i $name/$name2\_assembly.fasta
#         else
#                mv $i $name/$name2\_scaffolds.fasta
#        fi
#done

# determining assembly metrics using QUAST
if [ -f "$fqU1" ]
 then
        #echo "unpaired file 1 exists"
        if [ -e "$fqU2" ]; then
                #echo -e "$fqU1\t$fqU2"
                # both unpaired read files exists # --circos --glimmer --rna-finding
                quast.py --min-contig 200 --threads $threads --conserved-genes-finding \
                --contig-thresholds 0,200,500,1000,5000,10000,25000,50000 \
                --output-dir $quastDir/${sample}_assembly \
                --labels "$sample" $spadesDir/$sample/${sample}*.fa* \
                --pe1 $fq1 --pe2 $fq2 \
                --single $fqU1 --single $fqU2

        else
                #echo -e "Unpaired file 2 doesn't exist"
                # unpaired file 2 doesn't exist
                quast.py --min-contig 200 --threads $threads --conserved-genes-finding \
                --contig-thresholds 0,200,500,1000,5000,10000,25000,50000 \
                --output-dir $quastDir/${sample}_assembly --labels "$sample" $spadesDir/$sample/${sample}*.fa* \
                --pe1 $fq1 --pe2 $fq2 \
                --single $fqU1
        fi
 else
        #echo -e "Unpaired file 1 does'nt exist\nchecking if unpaired file 2 exists"
        if [ -e "$fqU2" ]; then
                #echo -e "Unpaired file 2 exists"
                # unpaired file 1 doesn't exist but unpaired file 2 exist
                quast.py --min-contig 200 --threads $threads --conserved-genes-finding \
                --contig-thresholds 0,200,500,1000,5000,10000,25000,50000 \
                --output-dir $quastDir/${sample}_assembly \
                --labels "$sample" $spadesDir/$sample/${sample}*.fa* \
                --pe1 $fq1 --pe2 $fq2 \
                --single $fqU2
        else
                #echo -e "Both unpaired file 1 and 2 don't exist"
                # both unpaired files do not exists
                quast.py --min-contig 200 --threads $threads --conserved-genes-finding \
                --contig-thresholds 0,200,500,1000,5000,10000,25000,50000 \
                --output-dir $quastDir/${sample}_assembly \
                --labels "$sample" $spadesDir/$sample/${sample}*.fa* \
                --pe1 $fq1 --pe2 $fq2
        fi
fi

# multiqc reports
#multiqc -o $reportsDir $quastDir --pdf --export --filename $projectName\_quast


### perform MLST typing using mlst tool
#if grep -q "$MLSTscheme" "$schemeList"; then
#        echo -e "$MLSTscheme found in MLST database, proceeding with MLST typing\n"
#        mlst --legacy --scheme $MLSTscheme --threads $threads --nopath \
#	--novel $mlstDir/mlst_novel.fa $spadesDir/$sample/$sample*.fa* --quiet >> $mlstDir/mlst_allele.tsv
#
# else
#       # now=$(date +"%d_%b_%Y")
#       # declare -x mlstDir=$project/mlst_output\_$now
#       # mkdir -p $mlstDir
#        echo -e "$MLSTscheme NOT found in MLST database, now performing MLST typing against the entire database\n"
#        mlst --threads $threads --nopath $spadesDir/$sample/$sample*.fa* >> $mlstDir/mlst_allele.tsv
#fi

# perform MLST typing using mlst tool
if grep -q "$MLSTscheme" "$schemeList"; then
        echo -e "$MLSTscheme found in MLST database, proceeding with MLST typing\n"
        mlst --legacy --scheme $MLSTscheme --threads $threads --nopath \
        --novel $mlstDir/mlst_novel.fa $spadesDir/$sample/$sample*.fa* --quiet >> $mlstDir/mlst_allele.tsv

 elif [ $MLSTscheme == "noScheme" ]; then
        echo -e "$MLSTscheme NOT found in MLST database, now performing MLST typing against the entire database\n"
        #FILE    SCHEME  ST
        mlst --threads $threads --nopath $spadesDir/$sample/$sample*.fa* >> $mlstDir/mlst_allele.tsv

 else
       # now=$(date +"%d_%b_%Y")
       # declare -x mlstDir=$project/mlst_output\_$now
       # mkdir -p $mlstDir
        echo -e "$MLSTscheme NOT found in MLST database\n"
        #mlst --threads $threads --nopath $spadesDir/$sample/$sample*.fa* >> $mlstDir/mlst_allele.tsv
        echo -e "FILE\tSCHEME\tST" > $mlstDir/mlst_allele.tsv
        echo -e "$sample\t-\t-" >> $mlstDir/mlst_allele.tsv
fi
