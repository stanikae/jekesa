#!/bin/bash

tmp=$project/tmp
cov_out=$project/coverageDepth/$samples

if ! [ -d $tmp ]; then
 mkdir -p $tmp
fi

if ! [ -d $cov_out ]; then
 mkdir -p $cov_out
fi

# calculate number of bases in R1
r1_bases=$(seqtk fqchk -q0 $project/${samples}*R1*.f*q.gz |  grep "^ALL" | cut -f2)
# estimate genome size using mash
mash sketch -o $tmp/sketch -k 32 -m 3 -r $project/${samples}*R1*.f*q.gz 2> $project/mash.txt
gsize=$(cat $project/mash.txt | grep "Estimated genome size:" | awk -F ": " '{ print $2 }' | perl -ne 'printf "%d\n", $_;')
# Calculate depth of coverage
echo -e "$samples,$gsize,`expr $r1_bases \* 2 / $gsize`" > $cov_out/${samples}.csv

