#!/bin/bash

for fq1 in $trimmedReads/*R1*.fq.gz
do
  fq=$(echo $fq1 | awk -F "R1" '{print $1 "R2"}')
  fqfile=$(basename $fq)
  fq2=$(find $trimmedReads -name "${fqfile}*val_2.fq.gz")
  
  # outdir for each name
  name=$(basename $fq1 | awk -F '_S' '{print $1}')
  mkdir -p $spadesDir/$name
  #echo $threads
  ram=$(expr ${threads} \* 3)	
  shovill --force --depth 0 --cpus $threads --ram $ram --assembler $assembler --outdir $spadesDir/$name --R1 $fq1 --R2 $fq2 

  # rename contigs files using nameID
  for i in `find $spadesDir/$name -maxdepth 1 -type f -name "contigs.fa"`
    do
        echo $i
        pathName=$(dirname $i)
        pathName2=$(basename $pathName)
       # echo $name2
        #rename "s/contigs.fa/${name2}_assembly.fasta/" $i
        if [[ "$i" =~ "contigs.fa" ]]
         then
                mv "$i" ${pathName}/${pathName2}_assembly.fasta
         else
                mv "$i" ${pathName}/${pathName2}_scaffolds.fasta
        fi
  done

  # determining assembly metrics using QUAST # --conserved-genes-finding
  quast.py --min-contig 200 --threads $threads \
  --contig-thresholds 0,200,500,1000,5000,10000,25000,50000 \
  --output-dir $quastDir/${name}_assembly \
  --labels "$name" $spadesDir/$name/${name}*.fa* \
  --pe1 $fq1 --pe2 $fq2 >> $quastDir/05.quast.log 2>&1
done

# multiqc reports
nohup multiqc -o $reportsDir/${projectName}-quast $quastDir \
--pdf --export --filename $projectName\_quast >> $project/tmp/quast_post-qc.log 2>&1&

# Combine quast reports and save in excel
Rscript $SCRIPTS_DIR/combining_quast_output.R $quastDir \
$reportsDir/05.quast.xlsx >> $project/tmp/05.quast2xlsx.log 2>&1

# soft link assembled contigs to results directory
mkdir -p $reportsDir/assembled-contigs
find $spadesDir -maxdepth 2 -type f -name "*_assembly.fasta" -exec rsync -c {} $reportsDir/assembled-contigs/ \;

