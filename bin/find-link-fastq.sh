
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

counter=0

if [ -d $project ];
 then
	echo -e "*** $project directory already exists ***"
	if ls -l $project | egrep -q "fastq|fq"; then 
	 	echo -e "*** $project contains fastq files already ***"
	else 
		echo -e "*** $project exists and no fastq files present ***"
		#exit
	fi 
        echo -e "*** Now adding additional fastq files to ${project} *** \n"
        for sample in `cat $filename`
         do
                found=`find $fastqDir -name "${sample}_*.gz" -print`
                if [ -z "$found" ]; then
                        echo -e "$sample not found"
                else
                        find $fastqDir -name "${sample}_*.gz" -exec ln -s {} $project \;
                        #ln -s "$found" "$project"
                        #echo "$sample linked"
                        counter=$((counter+1))
                fi
        done 
#if not exists, make $project directory:
 elif [ ! -d $project ]
  then
	mkdir -p $project
	for sample in `cat $filename`
	 do
		found=`find $fastqDir -name "${sample}_*.gz" -print`
		if [ -z "$found" ]; then
    			echo -e "$sample not found"
 		else
			find $fastqDir -name "${sample}_*.gz" -exec ln -s {} $project \;
			#ln -s "$found" "$project"
			#echo "$sample linked"
                        counter=$((counter+1))
 		fi
	done
 
fi

# 
echo -e "Number of linked sample IDs: $counter"
