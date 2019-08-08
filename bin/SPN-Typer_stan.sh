#!/bin/bash -l

read -a PARAM <<< $(echo $1) # $1 == job script

###This script is called for each job in the qsub array. The purpose of this code is to read in and parse a line of the job-control.txt file
###created by 'StrepLab-JanOw_GAS-wrapr.sh' and pass that information, as arguments, to other programs responsible for various parts of strain
###characterization (MLST, emm type and antibiotic drug resistance prediction).

read1=${PARAM[0]}
read2=${PARAM[1]}
allDB_dir=${PARAM[2]}
batch_out=${PARAM[3]}
sampl_out=${PARAM[4]}

###Start Doing Stuff###

cd $sampl_out
#batch_name=$(echo "$readPair_1" | awk -F"/" '{print $(NF-4)}')
#out_name=$(echo "$readPair_1" | awk -F"/" '{print $(NF-4)"--"$(NF)}' | sed 's/_S[0-9]\+_L[0-9]\+_R[0-9]\+.*//g')  ###Use This For Batches off the MiSeq###
#out_name=$(echo "$readPair_1" | awk -F"/" '{print $(NF-1)"--"$(NF)}' | sed 's/_S[0-9]\+_L[0-9]\+_R[0-9]\+.*//g')   ###Otherwise Use This###
just_name=$(echo "$read1" | awk -F "/" '{print $(NF)}' | sed 's/_.*//g')
out_nameMLST=MLST_"$just_name"

###Pre-Process Paired-end Reads###
sampleName=$(basename $sampl_out)
ln -s $read1 $sampl_out/${sampleName}_1.fastq.gz
ln -s $read2 $sampl_out/${sampleName}_2.fastq.gz
readPair_1=$sampl_out/${sampleName}_1.fastq.gz
readPair_2=$sampl_out/${sampleName}_2.fastq.gz

###Call GBS bLactam Resistances###
mkdir $sampl_out/velvet_output
#ln -s $spadesDir/$projectName/${projectName}_assembly.fasta ./velvet_output/contigs.fa

for i in `find $spadesDir/$just_name -maxdepth 1 -type f \( -name "${just_name}*scaffolds.fasta" -o -name "${just_name}*assembly.fasta" \)`
 do
	ln -s $i $sampl_out/velvet_output/contigs.fa
done

perl ~/repos/JanOw_Dependencies/PBP-Gene_Typer.pl -1 "$readPair_1" -2 "$readPair_2" -r "$allDB_dir/MOD_bLactam_resistance.fasta" -n "$just_name" -s SPN -p 1A,2B,2X
## OUTPUT file ===> TEMP_pbpID_Results.txt #####
## PBP genes: PBP_Code(1A:2B:2X) ##### 

echo -e "COMPLETED BLACTAM RESISTANCE TYPING\n"

###Predict bLactam MIC### Minimum Inihibitory Concentration
bash /home/stanford/repos/Spn_Scripts_Reference/bLactam_MIC_Rscripts/PBP_AA_sampledir_to_MIC_20180710.sh $sampl_out
## OUTPUT file ===> BLACTAM_MIC_RF_with_SIR.txt #####

echo -e "COMPLETED PREDICTION OF BLACTAM MIC (Minimum Inihibitory Concentration)\n"

###Call GBS Misc. Resistances###
perl ~/repos/Spn_Scripts_Reference/SPN_Res_Typer.pl -1 "$readPair_1" -2 "$readPair_2" -d "$allDB_dir" -r SPN_Res_Gene-DB_Final.fasta -n "$just_name"
## OUTPUT file ===> OUT_Res_Results.txt #####
perl /home/stanford/repos/Spn_Scripts_Reference/SPN_Target2MIC.pl OUT_Res_Results.txt "$just_name"
## OUTPUT file ===> RES-MIC_45186

echo -e "COMPLETED CALLING SPN MISC. RESISTANCE GENES\n"

###Output the emm type/MLST/drug resistance data for this sample to it's results output file###
tabl_out="TABLE_Isolate_Typing_results.txt"
bin_out="BIN_Isolate_Typing_results.txt"
printf "$just_name|" >> "$tabl_out"
printf "$just_name|" >> "$bin_out"

###PBP_ID Output###
justPBPs="NF"
sed 1d TEMP_pbpID_Results.txt | while read -r line
do
    if [[ -n "$line" ]]
    then
        justPBPs=$(echo "$line" | awk -F"\t" '{print $2}' | tr ':' '|')
        justPBP_BIN=$(echo "$line" | awk -F"\t" '{print $2}' | tr ':' '|')
    fi
    printf "$justPBPs|" >> "$tabl_out"
    printf "$justPBP_BIN|" >> "$bin_out"
done

###bLactam Predictions###
pbpID=$(tail -n1 "TEMP_pbpID_Results.txt" | awk -F"\t" '{print $2}')
if [[ ! "$pbpID" =~ .*NF.* ]] && [[ ! "$pbpID" =~ .*NEW.* ]]
then
    echo "No NF or NEW outputs for PBP Type"
    bLacTab=$(tail -n1 "BLACTAM_MIC_RF_with_SIR.txt" | tr ' ' '|')
    printf "$bLacTab" >> "$tabl_out"
    #bLacCom=$(echo "$line" | tr ' ' ',')
    #printf "$bLacCom," >> "$bin_out"
else
    echo "One of the PBP types has an NF or NEW"
    printf "NF|NF|NF|NF|NF|NF|NF|NF|NF|NF|NF|NF|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|" >> "$tabl_out"
    #printf "NF\tNF\tNF\tNF\tNF\tNF\tNF\tNF\tNF\tNF\tNF\tNF," >> "$bin_out"
fi


###Resistance Targets###
while read -r line
do
    #RES_targ=$(echo "$line" | cut -f2)
    #printf "$RES_targ\t" >> "$tabl_out"
#    printf "$line\t" | tr ',' '\t' >> "$tabl_out"
    printf "$line\n" >> "$tabl_out"
done < RES-MIC_"$just_name"

#batch_name=$(basename `dirname $batch_out`) #$(echo $line | awk -F" " '{print $1}' | awk -F"/" '{print $(NF-4)}')
final_outDir=$sampl_out #$(echo $line | awk -F" " '{print $5}')
final_result_Dir=$batch_out #$(echo $line | awk -F" " '{print $4}')
cat $final_outDir/TABLE_Isolate_Typing_results.txt >> $final_result_Dir/TABLE_SPN_"$batch_name"_Typing_Results.txt
#cat $final_outDir/BIN_Isolate_Typing_results.txt >> $final_result_Dir/BIN_GBS_"$batch_name"_Typing_Results.txt
if [[ -e $final_outDir/TEMP_newPBP_allele_info.txt ]]; then
  cat $final_outDir/TEMP_newPBP_allele_info.txt >> $final_result_Dir/UPDATR_SPN_"$batch_name"_Typing_Results.txt
fi

