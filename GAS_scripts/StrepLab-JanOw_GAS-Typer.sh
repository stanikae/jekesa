#!/bin/bash -l

read -a PARAM <<< $(echo $1)

declare -x SPN_SCRIPTS_DIR=$SPN_SCRIPTS_DIR
declare -x GAS_SCRIPTS_DIR=$GAS_SCRIPTS_DIR

#. /usr/share/Modules/init/bash
#module load perl/5.22.1
#module load ncbi-blast+/2.2.29
#module load BEDTools/2.17.0
#module load freebayes/0.9.21
#module load prodigal/2.60
#module load cutadapt/1.8
#module load cutadapt/1.8.3
#module load srst2/0.1.7

###This script is called for each job in the qsub array. The purpose of this code is to read in and parse a line of the job-control.txt file
###created by 'StrepLab-JanOw_GAS-wrapr.sh' and pass that information, as arguments, to other programs responsible for various parts of strain
###characterization (MLST, emm type and antibiotic drug resistance prediction).

read1=${PARAM[0]}
read2=${PARAM[1]}
allDB_dir=${PARAM[2]}
batch_out=${PARAM[3]}
declare -x sampl_out=${PARAM[4]}


###Start Doing Stuff###
cd "$sampl_out"
#batch_name=$(echo "$readPair_1" | awk -F"/" '{print $(NF-4)}')
#out_name=$(echo "$readPair_1" | awk -F"/" '{print $(NF-4)"--"$(NF)}' | sed 's/_S[0-9]\+_L[0-9]\+_R[0-9]\+.*//g')  ###Use This For Batches off the MiSeq###
#out_name=$(echo "$readPair_1" | awk -F"/" '{print $(NF-1)"--"$(NF)}' | sed 's/_S[0-9]\+_L[0-9]\+_R[0-9]\+.*//g')   ###Otherwise Use This###
#just_name=$(echo "$readPair_1" | awk -F"/" '{print $(NF)}' | sed 's/_S[0-9]\+_L[0-9]\+_R[0-9]\+.*//g')
just_name=$(echo "$read1" | awk -F "/" '{print $(NF)}' | sed 's/_.*//g')
#out_nameMLST=MLST_"$just_name"
#out_nameEMM=EMM_"$just_name"
#out_namePBP=PBP_"$just_name"
echo -e "$sampl_out\n$just_name"
###Pre-Process Paired-end Reads###

sampleName=$(basename $sampl_out)
#if [[ "$read1" =~ ".gz" ]]; then
# gunzip $read1
# gunzip $read2
#fi
ln -s $read1 $sampl_out/${sampleName}_1.fastq.gz
ln -s $read2 $sampl_out/${sampleName}_2.fastq.gz
readPair_1=$sampl_out/${sampleName}_1.fastq.gz
readPair_2=$sampl_out/${sampleName}_2.fastq.gz

###Call MLST###
#srst2 --samtools_args "\-A" --mlst_delimiter '_' --input_pe "$readPair_1" "$readPair_2" --output "$out_nameMLST" --save_scores --mlst_db "$allDB_dir/Streptococcus_pyogenes.fasta" --mlst_definitions "$allDB_dir/spyogenes.txt" --min_coverage 99.999
###Check and extract new MLST alleles###
#MLST_allele_checkr.pl "$out_nameMLST"__mlst__Streptococcus_pyogenes__results.txt "$out_nameMLST"__*.Streptococcus_pyogenes.sorted.bam "$allDB_dir/Streptococcus_pyogenes.fasta"


# create directory and symlink assembled contigs
mkdir $sampl_out/velvet_output

for i in `find $spadesDir/$just_name -maxdepth 1 -type f \( -name "${just_name}*scaffolds.fasta" -o -name "${just_name}*assembly.fasta" \)`
 do
        ln -s $i $sampl_out/velvet_output/contigs.fa
done

###Call emm Type###
#module unload perl/5.22.1
#module load perl/5.16.1-MT
perl $GAS_SCRIPTS_DIR/emm_typer.pl -1 "$readPair_1" -2 "$readPair_1" -r "$allDB_dir" -n "$just_name"
echo -e "\n************************************"
echo -e "COMPLETED: emm_typing"; date
echo -e "************************************\n"
perl $GAS_SCRIPTS_DIR/PBP-Gene_Typer.pl -1 "$readPair_1" -2 "$readPair_2" -r "$allDB_dir/GAS_bLactam_Ref.fasta" -n "$just_name" -s GAS -p 2X
#module unload perl/5.16.1-MT
#module load perl/5.22.1
echo -e "\n************************************"
echo -e "COMPLETED: pbp-gene_typing"; date
echo -e "************************************\n"
###Call GAS Misc Resistance###
perl $GAS_SCRIPTS_DIR/GAS_Res_Typer.pl -1 "$readPair_1" -2 "$readPair_2" -d "$allDB_dir" -r GAS_Res_Gene-DB_Final.fasta -n "$just_name"
echo -e "\n************************************"
echo -e "COMPLETED: res_typing"; date
echo -e "************************************\n"
perl $GAS_SCRIPTS_DIR/GAS_Target2MIC.pl TEMP_Res_Results.txt "$just_name" TEMP_pbpID_Results.txt
echo -e "\n************************************"
echo -e "COMPLETED: target2MIC"; date
echo -e "************************************\n"
###Type Surface and Secretory Proteins###
perl $GAS_SCRIPTS_DIR/GAS_Features_Typer.pl -1 "$readPair_1" -2 "$readPair_2" -d "$allDB_dir" -f GAS_features_Gene-DB_Final.fasta -n "$just_name"
echo -e "\n************************************"
echo -e "COMPLETED: feature_typing"; date
echo -e "************************************\n"
###Output the emm type/MLST/drug resistance data for this sample to it's results output file###
tabl_out="TABLE_Isolate_Typing_results.txt"
bin_out="BIN_Isolate_Typing_results.txt"
#contamination_level=10
printf "$just_name\t" >> "$tabl_out"
printf "$just_name," >> "$bin_out"
###EMM TYPE OUTPUT###
emm_out="NF"
while read -r line
do
    if [[ -n "$line" ]]
    then
        justTarget=$(echo "$line" | awk -F"\t" '{print $1}')
        if [[ "$emm_out" == "NF" ]]
        then
            emm_out="$justTarget"
        else
            emm_out="$emm_out;$justTarget"
        fi
    fi
done <<< "$(sed 1d *__emm-Type__Results.txt)"
printf "$emm_out\t" >> "$tabl_out"
printf "$emm_out," >> "$bin_out"
echo -e "\nCOMPLETED: emm_output"; date
###MLST OUTPUT###
#sed 1d "$out_nameMLST"__mlst__Streptococcus_pyogenes__results.txt | while read -r line
#do
#    MLST_tabl=$(echo "$line" | cut -f2-9)
#    echo "MLST line: $MLST_tabl\n";
#    printf "$MLST_tabl\t" >> "$tabl_out"
#    MLST_val=$(echo "$line" | awk -F" " '{print $2}')
#    printf "$MLST_val," >> "$bin_out"
#done #< "$out_nameMLST"__mlst__Streptococcus_pyogenes__results.txt
#tail -n+2 "$out_nameMLST"__mlst__Streptococcus_pyogenes__results.txt | cut -f2-9 >> "$tabl_out"

###Features Targets###
while read -r line
do
    FEAT_targ=$(echo "$line" | cut -f2)
    printf "$FEAT_targ\t" >> "$tabl_out"
done < TEMP_protein_Results.txt
echo -e "\n************************************\n"
echo -e "\nCOMPLETED: features-output"; date
echo -e "\n************************************\n"
###PBP_ID Output###
justPBPs="NF"
sed 1d TEMP_pbpID_Results.txt | while read -r line
do
    if [[ -n "$line" ]]
    then
        justPBPs=$(echo "$line" | awk -F"\t" '{print $2}')
    fi
    printf "$justPBPs\t" >> "$tabl_out"
done
echo -e "\nCOMPLETED: pbp-output"; date
###Resistance Targets###
while read -r line
do
    #RES_targ=$(echo "$line" | cut -f2)
    #printf "$RES_targ\t" >> "$tabl_out"
    printf "$line\t" | tr ',' '\t' >> "$tabl_out"
done < RES-MIC_"$just_name"
printf "\n" >> "$tabl_out"

cat BIN_Features_Results.txt | sed 's/$/,/g' >> "$bin_out"
cat BIN_Res_Results.txt >> "$bin_out"
printf "\n" >> "$bin_out"
echo -e "\nCOMPLETED: res_output"; date
###Output the emm type/MLST/drug resistance data for this sample to it's results output file###
#batch_name=$(basename `dirname $batch_out`) #$(echo $line | awk -F" " '{print $1}' | awk -F"/" '{print $(NF-4)}')
final_outDir=$sampl_out #$(echo $line | awk -F" " '{print $5}')
final_result_Dir=$batch_out #$(echo $line | awk -F" " '{print $4}')
cat $final_outDir/TABLE_Isolate_Typing_results.txt | sed 's/\t/|/g' | sed '$s/|$//' >> $final_result_Dir/TABLE_GAS_"$batch_name"_Typing_Results.txt
#cat $final_outDir/BIN_Isolate_Typing_results.txt >> $final_result_Dir/BIN_GBS_"$batch_name"_Typing_Results.txt
if [[ -e $final_outDir/TEMP_newPBP_allele_info.txt ]]; then
  cat $final_outDir/TEMP_newPBP_allele_info.txt >> $final_result_Dir/UPDATR_GAS_"$batch_name"_Typing_Results.txt
fi
echo -e "\n************************************"
echo -e "COMPLETED: Added all results for $just_name"; date
echo -e "************************************\n"
