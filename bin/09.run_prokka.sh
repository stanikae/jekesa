#!/bin/bash


#outdir=~/bacterial-snp-analysis/spn-swiss-isolates/gbk-files
fasta_dir=$1
outdir=$2
threads=$3

if ! [ -d $outdir ]; then
 mkdir -p "$outdir"
fi

genus="Neisseria" #"Streptococcus"
species="gonorrhoeae" #"pneumoniae"
#ref_gbk=~/Genomes-ksnp3/NC_011900/GCF_000007045.1_ASM704v1_genomic.gbff

for fasta in $(find $fasta_dir -name "*.fasta")
 do 
   in_fasta=$fasta
   strain=$(basename -s _assembly.fasta $fasta)
   echo $strain
   #----------------------- Run PROKKA ----------------------------------
   prokka --outdir $outdir/$strain --force --cpus $threads \
   --addgenes --addmrna --centre "NSCF" \
    --prefix $strain --genus $genus --species $species --strain $strain \
   --kingdom 'Bacteria' $in_fasta
#--proteins $ref_gbk
done

