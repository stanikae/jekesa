#!/bin/bash

#for i in $(cat $sampleList); do 
#cat ${i}_S*_R1*.fastq.gz ${i}_S*_R2*.fastq.gz | seqtk fqchk -q0 - | head -n1 | sed "
#s/min_len/${i}_min_len/"
#done >> ~/tmp/read-avg-length_35B-isolates.txt

cat ${samples}_S*_R1*.fastq.gz ${samples}_S*_R2*.fastq.gz | \
seqtk fqchk -q0 - | \
head -n1 | sed "#s/min_len/${i}_min_len/" | \
sed 's/_min.*avg_len://; s/;.*//' | tr ' ' ',' 
#>> ${projectName}_read-avg-length.csv
