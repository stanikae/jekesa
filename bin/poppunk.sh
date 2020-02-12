#!/bin/bash

run_id=$(basename $1)
spadesDir=$(find $1 -type d -name "spades_*")
poppunk_dir=$1/poppunk-analysis
reports_dir=$(find $1 -type d -name "Reports_${run_id}_*")
echo -e "\n$spadesDir"
echo -e "\n$reports_dir\n"
threads=8 #$threads
refDB_dir=$DATABASES_DIR/poppunk_db #/media/60tb/Databases/PopPunk-Databases
# echo $MLSTscheme
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
#while read -r line; do if [[ "$line" =~ "$MLSTscheme" ]]; then name=$(echo $line | cut -d ' ' -f1); ls ~/kedibone/35B-Isolates/spades*/${name}/${name}*_assembly.fasta; fi; done < ~/kedibone/35B-Isolates/mlst_output_11_Sep_2019/mlst_merged.tsv

#ls $spadesDir/*/*.fasta | grep -f $sampleList > $poppunk_dir/reference_list.txt
ls $spadesDir/*/*_assembly.fasta > $poppunk_dir/reference_list.txt

# create grep list of IDs
cat $poppunk_dir/reference_list.txt | awk -F '/' '{print $NF}' > $poppunk_dir/grep_list.txt

# run poppunk
echo -e "\nBeginning PopPunk run"; date
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
	--update-db --microreact --phandango
elif [[ "$MLSTscheme" == "spneumoniae" ]]; then 
   poppunk --assign-query --ref-db $refDB_dir/GPS_query \
	--distances $refDB_dir/GPS_query/GPS_query.dists \
	--model-dir $refDB_dir/GPS_query \
	--q-files reference_list.txt \
	--output spn_db --threads $threads --full-db \
	--external-clustering $refDB_dir/gpsc_definitive.csv --update-db --microreact --phandango --cytoscape
else
   poppunk --create-db --r-files $poppunk_dir/reference_list.txt --output strain_db --threads $threads --plot-fit 5
   #poppunk --easy-run --r-files reference_list.txt --output spn_db --threads $threads --plot-fit 5 --min-k 13 --full-db --microreact --phandango
   # --cytoscape
fi
## NOTES
# Check the distances (in the .err log file) to see that no random probabilities are greater than 0.05
# Check the model fit:
	# A bad network score – a value of at least 0.8 would be expected for a good fit. 
	# A high density suggests the fit was not specific enough
	# and too many points in the core-accessory plot have been included as within strain
# re-fitting model (using DBSCAN)
echo -e "\nRe-fitting model"; date
#poppunk --fit-model --distances spn_db/*.dists --ref-db spn_db --output spn_db --full-db --dbscan
#poppunk --easy-run --r-files $poppunk_dir/reference_list.txt --output spn_db --threads $threads --full-db --microreact --cytoscape --phandango

# crating interactive output

# creating GPSC output file
if [[ "$MLSTscheme" == "spyogenes" ]]; then
	head -n1 $poppunk_dir/gas_db/gas_db_clusters.csv > $poppunk_dir/assigned_gpscs.csv
        grep -F -f $poppunk_dir/grep_list.txt $poppunk_dir/gas_db/gas_db_clusters.csv | sed 's|/.*/||g' >> $poppunk_dir/assigned_gpscs.csv
	Rscript ~/repos/jekesa/bin/converting_csv_2_xlsx.R $poppunk_dir/assigned_gpscs.csv $reports_dir/assigned_gpscs.xlsx
	# determine if the novel (NA) files are the same or not using the clusters.csv file
	head -n1 $poppunk_dir/gas_db/gas_db_clusters.csv > $poppunk_dir/assigned_clusters.csv
        grep -F -f $poppunk_dir/grep_list.txt $poppunk_dir/gas_db/gas_db_clusters.csv | sed 's|/.*/||g' >> $poppunk_dir/assigned_clusters.csv
	Rscript ~/repos/jekesa/bin/converting_csv_2_xlsx.R $poppunk_dir/assigned_clusters.csv $reports_dir/assigned_clusters.xlsx	
elif [[ "$MLSTscheme" == "spneumoniae" ]]; then
	head -n1 $poppunk_dir/spn_db/spn_db_external_clusters.csv > $poppunk_dir/assigned_gpscs.csv
	grep -F -f $poppunk_dir/grep_list.txt $poppunk_dir/spn_db/spn_db_external_clusters.csv | sed 's|/.*/||g' >> $poppunk_dir/assigned_gpscs.csv
	Rscript ~/repos/jekesa/bin/converting_csv_2_xlsx.R $poppunk_dir/assigned_gpscs.csv $reports_dir/assigned_gpscs.xlsx
	# determine if the novel (NA) files are the same or not using the clusters.csv file
	head -n1 $poppunk_dir/spn_db/spn_db_clusters.csv > $poppunk_dir/assigned_clusters.csv
        grep -F -f $poppunk_dir/grep_list.txt $poppunk_dir/spn_db/spn_db_clusters.csv | sed 's|/.*/||g' >> $poppunk_dir/assigned_clusters.csv
	Rscript ~/repos/jekesa/bin/converting_csv_2_xlsx.R $poppunk_dir/assigned_clusters.csv $reports_dir/assigned_clusters.xlsx
else
	head -n1 $poppunk_dir/strain_db/strain_db_external_clusters.csv > $poppunk_dir/assigned_gpscs.csv
        grep -F -f $poppunk_dir/grep_list.txt $poppunk_dir/strain_db/strain_db_external_clusters.csv | sed 's|/.*/||g' >> $poppunk_dir/assigned_gpscs.csv
	Rscript ~/repos/jekesa/bin/converting_csv_2_xlsx.R $poppunk_dir/assigned_gpscs.csv $reports_dir/assigned_gpscs.xlsx
	# determine if the novel (NA) files are the same or not using the clusters.csv file
	head -n1 $poppunk_dir/strain_db/strain_db_clusters.csv > $poppunk_dir/assigned_clusters.csv
        grep -F -f $poppunk_dir/grep_list.txt $poppunk_dir/strain_db/strain_db_clusters.csv | sed 's|/.*/||g' >> $poppunk_dir/assigned_clusters.csv	
	Rscript ~/repos/jekesa/bin/converting_csv_2_xlsx.R $poppunk_dir/assigned_clusters.csv $reports_dir/assigned_clusters.xlsx
fi
# Save results in the Reports directory
echo -e "\ncopy final poppunk results to Reports directory"; date
cp $poppunk_dir/*/*.{csv,nwk,dot} $poppunk_report/
#Rscript bin/adding_poppunk_results.R ~/kedibone/35B-Isolates/Reports_35B-Isolates_11_Sep_2019 35B-Isolates_WGS-typing-report.xlsx assigned_gpscs.xlsx assigned_clusters.xlsx WGS-typing-poppunk-report.xlsx
