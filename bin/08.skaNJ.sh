#!/bin/bash

indir=$1
outdir=$2
ref=$3
skaDir=$outdir/ska-skf-files
skaAnot=$outdir/ska-vcfs

if ! [ -d $skaDir ]; then
  mkdir -p $skaDir
fi

if ! [ -d $skaAnot ]; then
  mkdir -p $skaAnot
fi

# ska fasta
for file in $(find $indir -name "*_assembly.fasta"); 
do 
  name=$(basename -s _assembly.fasta $file)
  ska fasta -o $skaDir/$name $file
done

# ska summary
ska summary $skaDir/*.skf > $outdir/ska.summary.tsv
ska summary $skaDir/*.skf | cut -f1 | grep -v "Sample" > $outdir/sample-list

# ska merge
#ska merge -o ska/merged ska/ska-output/*.skf
ska merge -o $outdir/merged -s $outdir/sample-list $skaDir/*.skf
mergedFile=$(find $outdir -name "merged*.skf")

# ska distances
ska distance -S -o $outdir/distances $mergedFile

# ska align
ska align -k -o $outdir/reference_free $mergedFile
ska align -k -v -o $outdir/reference_free_var $mergedFile

# generate neighbor joining tree

# Use .dot, .wk/.tre, and *clusters.tsv in microreact for visualization


# ska annotate - generate vcf file if reference is provided
# using reference fasta
if [[ -e $ref ]]; then
 for name in $(cat $outdir/sample-list); do
  ska annotate -v -o $skaAnot/${name}-annotation -r $ref $skaDir/${name}.skf
  #ska annotate -o $outdir/annotation -r $ref $mergedFile
  # using reference gff3
  #ska annotate -v -o $outdir/annotation -p -r $ref $mergedFile
 done
fi

# construct neighbor joining tree from the variants only alignment
# using rapidnj
alnFile=$(find $outdir -name "reference_free_var*.aln")
if [[ -s $alnFile ]]; then
 rapidnj -i fa $alnFile -x $outdir/nj-tree.nwk
else
 echo "No alignment file found"
fi
# move results files to the jekesa results directory


