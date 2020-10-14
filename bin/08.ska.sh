#!/bin/bash

indir=$1
outdir=$2
ref=$3
skaDir=$outdir/ska-downstream
# ska fasta
for file in $(find $indir -name "*.fasta"); 
do 
  name=$(basename -s .fasta $file)
  ska fasta -o $2/$name $file
done


if ! [ -d $skaDir ]; then
 mkdir -p $skaDir
fi

# ska summary
ska summary $outdir/*.skf > $outdir/ska.summary.tsv
ska summary $outdir/*.skf | cut -f1 | grep -v "Sample" > $outdir/sample-list

# ska merge
#ska merge -o ska/merged ska/ska-output/*.skf
ska merge -o $outdir/merged -s $outdir/sample-list $outdir/*.skf

# ska distances
ska distance -S -o $outdir/distances -f $outdir/merged.skf

# ska align
ska align -k -o $outdir/reference_free $outdir/merged-02.skf
ska align -k -v -o $outdir/reference_free_var $outdir/merged-02.skf

# generate neighbor joining tree

# Use .dot, .wk/.tre, and *clusters.tsv in microreact for visualization


# ska annotate - generate vcf file if reference is provided
# using reference fasta
ska annotate -o $outdir/annotation -r $ref $outdir/merged-02.skf
# using reference gff3
#ska annotate -o $outdir/annotation -p -r test-SKA/refs/MO10.gff3 $outdir/merged-02.skf



