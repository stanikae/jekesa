
#!/bin/sh

#check and and take the arragments from the command line:
if [ $# != 2 ]; 
 then
	echo "Usage: `basename $0` <absolute path to project_name> <sample_list>"
	exit
fi
#project=$1
#filename=$2
#path=$3
#fastqDir=/media/6tb/nscf_sequencing_data_backup
#fastqDir=/media/6tb/nscf_sequencing_data_backup/Kedibone-SPN
#fastqDir=/media/6tb/nscf_sequencing_data_backup/BGI_fastq/miseq_bgi
#fastqDir=/media/60tb/nicd/crdm/bacteriology/kedibone/tmp/kraken/47750
#fastqDir=/media/6tb/nscf_sequencing_data_backup/merged-190712_M02621-190711_M02143
#fastqDir=/mnt/e/190823_M02621_0165_000000000-CCLWY
fastqDir=/mnt/f/2016
#check if the $project directory is exists or not:
#if exists:
if [ -d $project ];
 then
	echo ">>>>$project<<< directory exists"
	if ls -l $project | egrep -q "fastq|fq"; then 
	 	echo -e "*** $project *** contains fastq files, proceeding with de novo assembly"
	else 
		echo -e "*** $project *** exists and no fastq files present... exiting..\n"
		exit
	fi 
	#exit
#	continue
#for sample in `cat $filename`
#do
    # find /media/6tb/nscf_sequencing_data_backup/* -name "$sample"*.gz -exec ln -s {} $path/$project \;
     
#done
#if not exists, make $project directory:
 elif [ ! -d $project ]
  then
	mkdir -p $project
	for sample in `cat $filename`
	 do
		found=`find $fastqDir -name "${sample}_S*.gz" -print`
		if [ -z "$found" ]; then
    			echo "$sample not found"
 		else
			find $fastqDir -name "${sample}_S*.gz" -exec ln -s {} $project \;
			#ln -s "$found" "$project"
			echo "$sample linked"
 		fi
	done
fi

