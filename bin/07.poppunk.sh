#!/bin/bash

run_id=$(basename $1)
poppunk_dir=$1/poppunk-analysis
reports_dir=$reportsDir 
threads=$threads
refDB_dir=$DATABASES_DIR/poppunk_db #/media/60tb/Databases/PopPunk-Databases
MLSTscheme=$MLSTscheme

# create poppunk work directory
if ! [ -d "$poppunk_dir" ]; then
 mkdir -p $poppunk_dir
fi

# create poppunk final results directory
if [ -d "$reports_dir" ]; then
 poppunk_report="$reports_dir"/poppunk-results
 mkdir -p $poppunk_report
fi

# create list of assemblies to analyze
while read -r line; do 
  if [[ "$line" =~ "$MLSTscheme" ]]; then 
     name=$(echo $line | cut -d ' ' -f1)
     #ls ~/kedibone/35B-Isolates/spades*/${name}/${name}*_assembly.fasta
     ls $spadesDir/${name}/${name}*_assembly.fasta >> $poppunk_dir/reference_list.txt
  fi
done < $mlstDir/mlst_merged.tsv

# check if previously assembled contigs/genomes are provided, including reference seq files
if [[ -d $spadesDir/previousContigs ]]; then
   ls $spadesDir/previousContigs/*_assembly.fasta >> $poppunk_dir/reference_list.txt
fi
#ls $spadesDir/*/*.fasta | grep -f $sampleList > $poppunk_dir/reference_list.txt
#ls $spadesDir/*/*_assembly.fasta > $poppunk_dir/reference_list.txt

# create grep list of IDs
cat $poppunk_dir/reference_list.txt | awk -F '/' '{print $NF}' > $poppunk_dir/grep_list.txt

if [[ $(wc -l < $poppunk_dir/reference_list.txt) -ge 4 ]]; then
# run poppunk
echo -e "\t[`date +"%d-%b-%Y %T"`]\tBeginning PopPunk run for project $projectName"
cd $poppunk_dir
#poppunk --create-db --r-files $poppunk_dir/reference_list.txt --output strain_db --threads $threads --plot-fit 5
#poppunk --easy-run --r-files reference_list.txt --output spn_db --threads $threads --plot-fit 5 --min-k 13 --full-db --microreact --phandango
# --cytoscape

# Using existing databases to get cluster assignments
if [[ "$MLSTscheme" == "spyogenes" ]]; then
   poppunk --assign-query --ref-db $refDB_dir/GAS_query_v2 \
	--distances $refDB_dir/GAS_query_v2/GAS_query_v2.dists \
	--model-dir $refDB_dir/GAS_query_v2 \
	--q-files reference_list.txt \
	--output gas_db --threads $threads --ignore-length \
	--update-db --microreact --phandango >> $project/tmp/poppunk.log
elif [[ "$MLSTscheme" == "spneumoniae" ]]; then 
   poppunk --assign-query --ref-db $refDB_dir/GPS_query \
	--distances $refDB_dir/GPS_query/GPS_query.dists \
	--model-dir $refDB_dir/GPS_query \
	--q-files reference_list.txt \
	--output spn_db --threads $threads --full-db \
	--external-clustering $refDB_dir/gpsc_definitive.csv --update-db --microreact --phandango --cytoscape >> $project/tmp/poppunk.log
else
   poppunk --create-db --r-files $poppunk_dir/reference_list.txt --output strain_db --threads $threads --plot-fit 5 >> $project/tmp/poppunk.log
   #poppunk --easy-run --r-files reference_list.txt --output spn_db --threads $threads --plot-fit 5 --min-k 13 --full-db --microreact --phandango
   # --cytoscape
   score=$(cat ${tmp}/ppk-${now}.log | grep "Score" | awk '{print $NF}')
   #echo $score
   ## score – a value of at least 0.8 would be expected for a good fit
   if (( $(echo "$score < 0.8" | bc -l) )); then
      echo -e "$score is less than 0.9, now running refitting model using dbscan"
      poppunk --fit-model \
      --distances ${db_name}_${now}/${db_name}_${now}.dists \
      --ref-db ${db_name}_${now} --output ${db_name}_${now} \
      --full-db --dbscan \
      --info-csv $epi_info \
      --microreact --phandango --cytoscape --grapetree > ${tmp}/ppk-dbscan-${now}.log 2>&1
   fi

fi
## NOTES
# Check the distances (in the .err log file) to see that no random probabilities are greater than 0.05
# Check the model fit:
	# A bad network score – a value of at least 0.8 would be expected for a good fit. 
	# A high density suggests the fit was not specific enough
	# and too many points in the core-accessory plot have been included as within strain
# re-fitting model (using DBSCAN)
#echo -e "\nRe-fitting model"; date
#echo -e "\t[`date +"%d-%b-%Y %T"`]\tBeginning PopPunk run for project $projectName"
#poppunk --fit-model --distances spn_db/*.dists --ref-db spn_db --output spn_db --full-db --dbscan
#poppunk --easy-run --r-files $poppunk_dir/reference_list.txt --output spn_db --threads $threads --full-db --microreact --cytoscape --phandango

#score=$(cat ${tmp}/ppk-${now}.log | grep "Score" | awk '{print $NF}')
#echo $score
## score – a value of at least 0.8 would be expected for a good fit
#if (( $(echo "$score < 0.8" | bc -l) )); then
#echo -e "$score is less than 0.9, now running refitting model using dbscan"
#poppunk --fit-model \
#--distances ${db_name}_${now}/${db_name}_${now}.dists \
#--ref-db ${db_name}_${now} --output ${db_name}_${now} \
#--full-db --dbscan \
#--info-csv $epi_info \
#--microreact --phandango --cytoscape --grapetree > ${tmp}/ppk-dbscan-${now}.log 2>&1
#fi

# crating interactive output
# creating GPSC output file
if [[ "$MLSTscheme" == "spyogenes" ]]; then
	echo -e "\t[`date +"%d-%b-%Y %T"`]\tCreating PopPunk output file for $MLSTscheme"
	head -n1 $poppunk_dir/gas_db/gas_db_clusters.csv > $poppunk_dir/assigned_gpscs.csv
        grep -F -f $poppunk_dir/grep_list.txt $poppunk_dir/gas_db/gas_db_clusters.csv | sed 's|/.*/||g' >> $poppunk_dir/assigned_gpscs.csv
	Rscript $SCRIPTS_DIR/csv2xlsx.R \
		$poppunk_dir/assigned_gpscs.csv $reports_dir/07.GAS.assigned-gpscs.xlsx >> $project/tmp/07.GAS.gpscs.poppunk.csv2xlsx.log
	# determine if the novel (NA) files are the same or not using the clusters.csv file
	head -n1 $poppunk_dir/gas_db/gas_db_clusters.csv > $poppunk_dir/assigned_clusters.csv
        grep -F -f $poppunk_dir/grep_list.txt $poppunk_dir/gas_db/gas_db_clusters.csv | sed 's|/.*/||g' >> $poppunk_dir/assigned_clusters.csv
	Rscript $SCRIPTS_DIR/csv2xlsx.R \
		$poppunk_dir/assigned_clusters.csv $reports_dir/07.GAS.assigned-clusters.xlsx >> $project/tmp/07.GAS.clusters.poppunk.csv2xlsx.log
elif [[ "$MLSTscheme" == "spneumoniae" ]]; then
	echo -e "\t[`date +"%d-%b-%Y %T"`]\tCreating PopPunk GPSC output file for $MLSTscheme" 
	head -n1 $poppunk_dir/spn_db/spn_db_external_clusters.csv > $poppunk_dir/assigned_gpscs.csv
	grep -F -f $poppunk_dir/grep_list.txt $poppunk_dir/spn_db/spn_db_external_clusters.csv | sed 's|/.*/||g' >> $poppunk_dir/assigned_gpscs.csv
	Rscript $SCRIPTS_DIR/csv2xlsx.R \
		$poppunk_dir/assigned_gpscs.csv $reports_dir/07.SPN.assigned-gpscs.xlsx >> $project/tmp/07.SPN.gpsc.poppunk.csv2xlsx.log
	# determine if the novel (NA) files are the same or not using the clusters.csv file
	head -n1 $poppunk_dir/spn_db/spn_db_clusters.csv > $poppunk_dir/assigned_clusters.csv
        grep -F -f $poppunk_dir/grep_list.txt $poppunk_dir/spn_db/spn_db_clusters.csv | sed 's|/.*/||g' >> $poppunk_dir/assigned_clusters.csv
	Rscript $SCRIPTS_DIR/csv2xlsx.R \
		$poppunk_dir/assigned_clusters.csv $reports_dir/07.SPN.assigned-clusters.xlsx >> $project/tmp/07.SPN.clusters.poppunk.csv2xlsx.log
else
	head -n1 $poppunk_dir/strain_db/strain_db_external_clusters.csv > $poppunk_dir/assigned_gpscs.csv
        grep -F -f $poppunk_dir/grep_list.txt $poppunk_dir/strain_db/strain_db_external_clusters.csv | sed 's|/.*/||g' >> $poppunk_dir/assigned_gpscs.csv
	Rscript $SCRIPTS_DIR/csv2xlsx.R \
		$poppunk_dir/assigned_gpscs.csv $reports_dir/07.other.assigned-gpscs.xlsx >> $project/tmp/07.other.gpsc.poppunk.csv2xlsx.log
	# determine if the novel (NA) files are the same or not using the clusters.csv file
	head -n1 $poppunk_dir/strain_db/strain_db_clusters.csv > $poppunk_dir/assigned_clusters.csv
        grep -F -f $poppunk_dir/grep_list.txt $poppunk_dir/strain_db/strain_db_clusters.csv | sed 's|/.*/||g' >> $poppunk_dir/assigned_clusters.csv	
	Rscript $SCRIPTS_DIR/csv2xlsx.R \
		$poppunk_dir/assigned_clusters.csv $reports_dir/07.other.assigned-clusters.xlsx >> $project/tmp/07.other.poppunk.csv2xlsx.log
fi
# Save results in the Reports directory
echo -e "\t[`date +"%d-%b-%Y %T"`]\tCopy final PopPunk results to the Reports directory"
cp $poppunk_dir/*/*.{csv,nwk,dot} $poppunk_report/

else
    echo -e "\t[`date +"%d-%b-%Y %T"`]\tNumber of samples too low to run PopPunk for ${projectName} ...... provide at least 4 samples"
fi
#Rscript bin/adding_poppunk_results.R \
#~/kedibone/35B-Isolates/Reports_35B-Isolates_11_Sep_2019 35B-Isolates_WGS-typing-report.xlsx \
#assigned_gpscs.xlsx assigned_clusters.xlsx WGS-typing-poppunk-report.xlsx
