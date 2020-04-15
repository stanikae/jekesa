#!/bin/bash

#project=~/tmp/Test-200214_M02143
#samples="QF01750498"
#confindrDir=~/tmp/Test-200214_M02143/confindr_20_Feb_2020
#indir=$project
confindrDB=$DATABASES_DIR/confindr_db
#echo $indir
echo "$confindrDB" 

name=$samples
mkdir -p $confindrDir/${name}
echo "$confindrDir/${name}"


indir=$trimmedReads
echo $trimmedReads
echo $indir
#sample=$samples

#mkdir -p $spadesDir/$sample
fq1=$(find $indir -maxdepth 1 -name "${sample}_S*val_1*.gz") #*val_1*.gz #*val_1*f*q.gz
fq2=$(find $indir -maxdepth 1 -name "${sample}_S*val_2*.gz")


#fq1=$(find ${indir}/ -maxdepth 1 -name "${name}*R1*.fastq.gz") # -exec cp {} $confindrDir/ \;
#fq1=$(find ${indir}/ -maxdepth 1 -name "${name}*R2*.fastq.gz")

echo $fq1
echo $fq2

cp $fq1 $confindrDir/
cp $fq2 $confindrDir/
#cp ${project}/${name}*.fastq.gz ${confindrDir}/

#if ls $confindrDir | grep -q "$name"; then 
#  ls $confindrDir
  # confindr.py -i ${confindrDir}/${name}/ -o ${confindrDir}/${name} -d $confindrDB #${DATABASES_DIR}/confindr_db
#else
#    echo -e "Fastq files for $name not present in $confindrDir/${name} ... now copying fastq files"
#    cp ${project}/${name}*.fastq.gz ${confindrDir}/
    confindr.py -i ${confindrDir}/ -o ${confindrDir}/${name} -d $confindrDB
#    rm ${confindrDir}/*fastq.gz
#fi

