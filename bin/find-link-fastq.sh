
#!/bin/sh

#check and and take the arragments from the command line:
if [ $# != 3 ]; 
 then
	echo "Usage: `basename $0` <absolute path to project_name> <sample_list> <absolute path to directory with fastq files>"
	exit
fi
project=$1
filename=$2
fastqDir=$3
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
     
#if not exists, make $project directory:
 elif [ ! -d $project ]
  then
	mkdir -p $project
	for sample in `cat $filename`
	 do
		found=`find $fastqDir -maxdepth 1 -name "${sample}_S*.gz" -print`
		if [ -z "$found" ]; then
    			echo "$sample not found"
 		else
			find $fastqDir -maxdepth 1 -name "${sample}_S*.gz" -exec ln -s {} $project \;
			#ln -s "$found" "$project"
			echo "$sample linked"
 		fi
	done
fi

