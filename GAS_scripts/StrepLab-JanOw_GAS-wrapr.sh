#!/bin/bash -l

#. /usr/share/Modules/init/bash
###This wrapper script validates the input arguments and creates the job-control.txt file which is needed to submit the qsub array job to the cluster.###

#while getopts :s:r:o: option
#do
#    case $option in
#        s) batch_dir=$OPTARG;;
#        r) allDB_dir=$OPTARG;;
#        o) output_dir=$OPTARG;;
#    esac
#done


###Create the batch output files###
#batch_name=$(echo "$batch_dir" | awk -F"/" '{print $(NF-3)}')
#printf "Sample_Name\temm_Type\temm_Seq\t%_identity\tmatch_length\n" >> "$out_analysis"/JanOw_"$batch_name"_emmType_results.txt
printf "Sample|emm_Type|T_Type|Group_A|EMM_Family|Other_Surface_Proteins|Capsule|SDA1|SLAA|SIC|ROCA|PNGA3|NADase_D330G|Exotoxins|PBP_ID|WGS_ZOX_SIGN|WGS_ZOX|WGS_ZOX_SIR|WGS_FOX_SIGN|WGS_FOX|WGS_FOX_SIR|WGS_TAX_SIGN|WGS_TAX|WGS_TAX_SIR|WGS_CFT_SIGN|WGS_CFT|WGS_CFT_SIR|WGS_CPT_SIGN|WGS_CPT|WGS_CPT_SIR|WGS_AMP_SIGN|WGS_AMP|WGS_AMP_SIR|WGS_PEN_SIGN|WGS_PEN|WGS_PEN_SIR|WGS_MER_SIGN|WGS_MER|WGS_MER_SIR|ER_CL|WGS_ERY_SIGN|WGS_ERY|WGS_ERY_SIR|WGS_CLI_SIGN|WGS_CLI|WGS_CLI_SIR|WGS_LZO_SIGN|WGS_LZO|WGS_LZO_SIR|WGS_SYN_SIGN|WGS_SYN|WGS_SYN_SIR|WGS_ERY/CLI|TET|WGS_TET_SIGN|WGS_TET|WGS_TET_SIR|GYRA_PARC|WGS_LFX_SIGN|WGS_LFX|WGS_LFX_SIR|OTHER|WGS_DAP_SIGN|WGS_DAP|WGS_DAP_SIR|WGS_VAN_SIGN|WGS_VAN|WGS_VAN_SIR|WGS_RIF_SIGN|WGS_RIF|WGS_RIF_SIR|WGS_CHL_SIGN|WGS_CHL|WGS_CHL_SIR|WGS_SXT_SIGN|WGS_SXT|WGS_SXT_SIR\n" >> "$out_analysis"/TABLE_GAS_"$batch_name"_Typing_Results.txt
#printf "Sample,MLST,emm_Type,T_Type,MRP,ENN,FBAA,PRTF2,SFB1,R28,SOF,HASA,SDA1,SIC,ROCAM3,ROCAM18,PNGA,SLOG,SpeA,SpeC,SpeG,SpeH,SpeI,SpeJ,SpeK,SpeL,SpeM,SSA,SMEZ,23S1,23S3,CAT,ERMB,ERMT,ERMA,FOLA,FOLP1,FOLP2,GYRA,LNUB,LSAC,LSAE,MEF,PARC,RPOB1,RPOBN,TETL,TETM,TETO\n" >> "$out_analysis"/BIN_GAS_"$batch_name"_Typing_Results.txt

###Will search thru every file in the batch directory and check if it matches the following regexs: _L.*_R1_001.fastq and _L.*_R2_001.fastq###
###If both paired end fastq files are found then the full paths of each file will be written to the 'job-control.txt' file###
batch_dir_star="${batch_dir}/*" #/*"

for sample in $batch_dir_star
do
    if [[ "$sample" =~ val_1.fq ]]
    then
        sampl_name=$(echo "$sample" | sed 's/^.*\///g' | sed 's/_S.*.f*//g')
    fi
    sampl_out=$out_analysis/$sampl_name
    eval sampl_out=$sampl_out

    if [[ $sample =~ val_1 ]]
    then
        readPair_1=$(echo "$sample") # | sed 's/_S/_S1_S/') #sed 's/_L\([0-9]\+\)_R1/_S1_L\1_R1/g')
    fi

    if [[ $sample =~ val_2 ]]
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

#qsub -sync y -q all.q -t 1-$(cat $out_jobCntrl/job-control.txt | wc -l) -cwd -o "$out_qsub" -e "$out_qsub" ./StrepLab-JanOw_GAS-Typer.sh $out_jobCntrl

###Output the emm type/MLST/drug resistance data for this sample to it's results output file###
#while read -r line
#do
#    batch_name=$(echo $line | awk -F" " '{print $1}' | awk -F"/" '{print $(NF-4)}')
#    final_outDir=$(echo $line | awk -F" " '{print $5}')
#    final_result_Dir=$(echo $line | awk -F" " '{print $4}')
#    #cat $final_outDir/SAMPLE_Isolate__Typing_Results.txt >> $final_result_Dir/SAMPL_GAS_"$batch_name"_Typing_Results.txt
#    cat $final_outDir/TABLE_Isolate_Typing_results.txt >> $final_result_Dir/TABLE_GAS_"$batch_name"_Typing_Results.txt
#    #cat $final_outDir/BIN_Isolate_Typing_results.txt >> $final_result_Dir/BIN_GAS_"$batch_name"_Typing_Results.txt
#    #cat $final_outDir/TEMP_newPBP_allele_info.txt >> $final_result_Dir/UPDATR_GBS_"$batch_name"_Typing_Results.txt
#    if [[ -e $final_outDir/TEMP_newPBP_allele_info.txt ]]
#    then
#        cat $final_outDir/TEMP_newPBP_allele_info.txt >> $final_result_Dir/UPDATR_GBS_"$batch_name"_Typing_Results.txt
#    fi
#done < $out_jobCntrl/job-control.txt
