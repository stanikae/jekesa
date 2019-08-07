#!/bin/bash


#now=$(date +"%d_%b_%Y")

###Will search thru every file in the batch directory and check if it matches the following regexs: _L.*_R1_001.fastq and _L.*_R2_001.fastq###
###If both paired end fastq files are found then the full paths of each file will be written to the 'job-control.txt' file###
# _L001_R1_001_val_1.fq.gz
# sed 's/_S[0-9]\+\_.*.fq.gz//g'
# _S[0-9]+_L[0-9]+_R._001.fastq

batch_dir_star="${batch_dir}/*/*"

for sample in $batch_dir_star
do
    if [[ "$sample" =~ val_1.fq ]]
    then
        sampl_name=$(echo "$sample" | sed 's/^.*\///g' | sed 's/_S.*.fq.gz//g')
    #elif [[ "$sample" =~ _[1|2].fastq.gz ]]
    #then
    #    sampl_name=$(echo "$sample" | sed 's/^.*\///g' | sed 's/_[1|2].fastq.gz//g')
    fi
    #echo $sampl_name
    sampl_out=$out_analysis/$sampl_name
    #echo $sampl_out
    eval sampl_out=$sampl_out
    #echo The sample file is: $sample
    #echo $sampl_out

    #if [[ $sampl_name =~ ^Undetermined ]]
    #then
    #    echo "Skipping the 'Undetermined' fastq files"
    #    continue
   # fi

    if [[ $sample =~ _S_val_1 ]]
    then
        readPair_1=$(echo "$sample") # | sed 's/_S/_S1_S/') #sed 's/_L\([0-9]\+\)_R1/_S1_L\1_R1/g')
        #mv $sample $readPair_1
    #elif [[ $sample =~ _L.*_R1_001_val && $sample =~ S[0-9]+ ]]
    #then
    #    readPair_1=$sample
    #elif [[ $sample =~ .*_1.fastq.gz ]]
    #then
    #    readPair_1=$sample
    fi

    if [[ $sample =~ _S_val_2 ]]
    then
        readPair_2=$(echo "$sample") # | sed 's/_S/_S2_S/') #sed 's/_L\([0-9]\+\)_R2/_S1_L\1_R2/g')
        #mv $sample $readPair_2
    #elif [[ $sample =~ _L.*_R2_001_val && $sample =~ S[0-9]+ ]]
    #then
	#readPair_2=$sample
    #elif [[ $sample =~ .*_2.fastq.gz ]]
    #then
     #   readPair_2=$sample
    fi
    #echo -e "$readPair_1\t$readPair_2"
#   if [ -n "$readPair_1" -a -n "$readPair_2" ]
#    then
#        if [[ ! -d "$sampl_out" ]]
#        then
#            mkdir "$sampl_out"
#        fi
#        echo "Both Forward and Reverse Read files exist."
#        echo "Paired-end Read-1 is: $readPair_1"
#        echo "Paired-end Read-2 is: $readPair_2"
#        printf "\n"
#        echo "$readPair_1 $readPair_2 $allDB_dir $out_analysis $sampl_out" >> $out_analysis/job-control.txt
        ###Prepare script for next sample###
#        readPair_1=""
#        readPair_2=""
#    fi

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

#if [[ $(find /path/to/file -type f -size +1M 2>/dev/null) ]]; then
#    somecmd
#fi

#if (( `stat -c%s /home/stanford/kedibone/CRDM-08r/kraken/41467/41467_S_val_2.fq.gz` > 1000000 )); then echo "large enough"; fi

#printf "Sample\tWGS_Serotype\tPili\tST\taroe\tgdh\tgki\trecP\tspi\txpt\tddl\tPBP1A\tPBP2B\tPBP2X\tWGS_PEN_SIGN\tWGS_PEN\tWGS_PEN_SIR_Meningitis\tWGS_PEN_SIR_Nonmeningitis\tWGS_AMO_SIGN\tWGS_AMO\tWGS_AMO_SIR\tWGS_MER_SIGN\tWGS_MER\tWGS_MER_SIR\tWGS_TAX_SIGN\tWGS_TAX\tWGS_TAX_SIR_Meningitis\tWGS_TAX_SIR_Nonmeningitis\tWGS_CFT_SIGN\tWGS_CFT\tWGS_CFT_SIR_Meningitis\tWGS_CFT_SIR_Nonmeningitis\tWGS_CFX_SIGN\tWGS_CFX\tWGS_CFX_SIR\tWGS_AMP_SIGN\tWGS_AMP\tWGS_AMP_SIR\tWGS_CPT_SIGN\tWGS_CPT\tWGS_CPT_SIR\tWGS_ZOX_SIGN\tWGS_ZOX\tWGS_ZOX_SIR\tWGS_FOX_SIGN\tWGS_FOX\tWGS_FOX_SIR\tEC\tWGS_ERY_SIGN\tWGS_ERY\tWGS_ERY_SIR\tWGS_CLI_SIGN\tWGS_CLI\tWGS_CLI_SIR\tWGS_SYN_SIGN\tWGS_SYN\tWGS_SYN_SIR\tWGS_LZO_SIGN\tWGS_LZO\tWGS_LZO_SIR\tWGS_ERY/CLI\tCot\tWGS_COT_SIGN\tWGS_COT\tWGS_COT_SIR\tTet\tWGS_TET_SIGN\tWGS_TET\tWGS_TET_SIR\tWGS_DOX_SIGN\tWGS_DOX\tWGS_DOX_SIR\tFQ\tWGS_CIP_SIGN\tWGS_CIP\tWGS_CIP_SIR\tWGS_LFX_SIGN\tWGS_LFX\tWGS_LFX_SIR\tOther\tWGS_CHL_SIGN\tWGS_CHL\tWGS_CHL_SIR\tWGS_RIF_SIGN\tWGS_RIF\tWGS_RIF_SIR\tWGS_VAN_SIGN\tWGS_VAN\tWGS_VAN_SIR\tWGS_DAP_SIGN\tWGS_DAP\tWGS_DAP_SIR\n" >> $out_analysis/TABLE_SPN_"$batch_name"_Typing_Results.txt

printf "Sample|PBP1A|PBP2B|PBP2X|WGS_PEN_SIGN|WGS_PEN|WGS_PEN_SIR_Meningitis|WGS_PEN_SIR_Nonmeningitis|WGS_AMO_SIGN|WGS_AMO|WGS_AMO_SIR|WGS_MER_SIGN|WGS_MER|WGS_MER_SIR|WGS_TAX_SIGN|WGS_TAX|WGS_TAX_SIR_Meningitis|WGS_TAX_SIR_Nonmeningitis|WGS_CFT_SIGN|WGS_CFT|WGS_CFT_SIR_Meningitis|WGS_CFT_SIR_Nonmeningitis|WGS_CFX_SIGN|WGS_CFX|WGS_CFX_SIR|WGS_AMP_SIGN|WGS_AMP|WGS_AMP_SIR|WGS_CPT_SIGN|WGS_CPT|WGS_CPT_SIR|WGS_ZOX_SIGN|WGS_ZOX|WGS_ZOX_SIR|WGS_FOX_SIGN|WGS_FOX|WGS_FOX_SIR|WGS_EC|WGS_ERY_SIGN|WGS_ERY_MIC|WGS_ERY_SIR|WGS_CLI_SIGN|WGS_CLI_MIC|WGS_CLI_SIR|WGS_SYN_SIGN|WGS_SYN_MIC|WGS_SYN_SIR|WGS_LZO_SIGN|WGS_LZO_MIC|WGS_LZO_SIR|WGS_ERYCLI|WGS_COT|WGS_COT_SIGN|WGS_COT_MIC|WGS_COT_SIR|WGS_TET|WGS_TET_SIGN|WGS_TET_MIC|WGS_TET_SIR|WGS_DOX_SIGN|WGS_DOX_MIC|WGS_DOX_SIR|WGS_FQ|WGS_CIP_SIGN|WGS_CIP_MIC|WGS_CIP_SIR|WGS_LFX_SIGN|WGS_LFX_MIC|WGS_LFX_SIR|WGS_Other|WGS_CHL_SIGN|WGS_CHL_MIC|WGS_CHL_SIR|WGS_RIF_SIGN|WGS_RIF_MIC|WGS_RIF_SIR|WGS_VAN_SIGN|WGS_VAN_MIC|WGS_VAN_SIR|WGS_DAP_SIGN|WGS_DAP_MIC|WGS_DAP_SIR\n" >> $out_analysis/TABLE_SPN_"$batch_name"_Typing_Results.txt

