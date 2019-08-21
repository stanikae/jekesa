#!/bin/bash


#now=$(date +"%d_%b_%Y")

###Will search thru every file in the batch directory and check if it matches the following regexs: _L.*_R1_001.fastq and _L.*_R2_001.fastq###
###If both paired end fastq files are found then the full paths of each file will be written to the 'job-control.txt' file###

batch_dir_star="${batch_dir}/*/*"

for sample in $batch_dir_star
do
    if [[ "$sample" =~ val_1.fq ]]
    then
        sampl_name=$(echo "$sample" | sed 's/^.*\///g' | sed 's/_S.*.fq.gz//g')
    fi
    sampl_out=$out_analysis/$sampl_name
    eval sampl_out=$sampl_out

    if [[ $sample =~ _S_val_1 ]]
    then
        readPair_1=$(echo "$sample") # | sed 's/_S/_S1_S/') #sed 's/_L\([0-9]\+\)_R1/_S1_L\1_R1/g')
    fi

    if [[ $sample =~ _S_val_2 ]]
    then
        readPair_2=$(echo "$sample") # | sed 's/_S/_S2_S/') #sed 's/_L\([0-9]\+\)_R2/_S1_L\1_R2/g')
    fi

    echo -e "$readPair_1\n"
    echo -e "$readPair_2\n"

    if [ -n "$readPair_1" -a -n "$readPair_2" ]
    then	
      if (( `stat -c%s "$readPair_1"` > 2000000 )); then
	if (( `stat -c%s "$readPair_2"` > 2000000 )); then
		if [[ ! -d "$sampl_out" ]]
        	then
            	     mkdir "$sampl_out"
        	fi
        	echo "Both Forward and Reverse Read files exist."
        	echo "Paired-end Read-1 is: $readPair_1"
        	echo "Paired-end Read-2 is: $readPair_2"
        	printf "\n"
        	echo "$readPair_1 $readPair_2 $allDB_dir $out_analysis $sampl_out" >> $out_analysis/job-control.txt
        	###Prepare script for next sample###
        	readPair_1=""
        	readPair_2=""
	fi
   fi
   fi
done

printf "Sample|PBP1A|PBP2B|PBP2X|WGS_PEN_SIGN|WGS_PEN|WGS_PEN_SIR_Meningitis|WGS_PEN_SIR_Nonmeningitis|WGS_AMO_SIGN|WGS_AMO|WGS_AMO_SIR|WGS_MER_SIGN|WGS_MER|WGS_MER_SIR|WGS_TAX_SIGN|WGS_TAX|WGS_TAX_SIR_Meningitis|WGS_TAX_SIR_Nonmeningitis|WGS_CFT_SIGN|WGS_CFT|WGS_CFT_SIR_Meningitis|WGS_CFT_SIR_Nonmeningitis|WGS_CFX_SIGN|WGS_CFX|WGS_CFX_SIR|WGS_AMP_SIGN|WGS_AMP|WGS_AMP_SIR|WGS_CPT_SIGN|WGS_CPT|WGS_CPT_SIR|WGS_ZOX_SIGN|WGS_ZOX|WGS_ZOX_SIR|WGS_FOX_SIGN|WGS_FOX|WGS_FOX_SIR|WGS_EC|WGS_ERY_SIGN|WGS_ERY_MIC|WGS_ERY_SIR|WGS_CLI_SIGN|WGS_CLI_MIC|WGS_CLI_SIR|WGS_SYN_SIGN|WGS_SYN_MIC|WGS_SYN_SIR|WGS_LZO_SIGN|WGS_LZO_MIC|WGS_LZO_SIR|WGS_ERYCLI|WGS_COT|WGS_COT_SIGN|WGS_COT_MIC|WGS_COT_SIR|WGS_TET|WGS_TET_SIGN|WGS_TET_MIC|WGS_TET_SIR|WGS_DOX_SIGN|WGS_DOX_MIC|WGS_DOX_SIR|WGS_FQ|WGS_CIP_SIGN|WGS_CIP_MIC|WGS_CIP_SIR|WGS_LFX_SIGN|WGS_LFX_MIC|WGS_LFX_SIR|WGS_Other|WGS_CHL_SIGN|WGS_CHL_MIC|WGS_CHL_SIR|WGS_RIF_SIGN|WGS_RIF_MIC|WGS_RIF_SIR|WGS_VAN_SIGN|WGS_VAN_MIC|WGS_VAN_SIR|WGS_DAP_SIGN|WGS_DAP_MIC|WGS_DAP_SIR\n" >> $out_analysis/TABLE_SPN_"$batch_name"_Typing_Results.txt

