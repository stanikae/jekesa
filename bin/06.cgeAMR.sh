#!/bin/bash

CONDA_BASE=$(conda info --base)

# activate the resfinder environment
#source ${CONDA_BASE}/etc/profile.d/conda.sh
eval "$(conda shell.bash hook)"
conda activate resfinder

# CGE amr detection
# resistance gene prediction using assembled contigs
for contigs in $(find $spadesDir -name "*_assembly.fasta")
 do
  name=$(basename $contigs | sed 's/_assembly.fasta//')
  mkdir -p $resfinder/$name
  python3 $SCRIPTS_DIR/resfinder.py -i $contigs \
  -o $resfinder/$name -p $DATABASES_DIR/resfinder_db \
  -t 0.90 -l 0.60 > $project/tmp/resfinder.log 2>&1

  # point mutation detection using assembled contigs
  mkdir -p $pointfinder/$name
  python3 $SCRIPTS_DIR/PointFinder.py -i $contigs \
  -o $pointfinder/$name -p $DATABASES_DIR/pointfinder_db \
  -s salmonella -m blastn -m_p ${CONDA_BASE}/envs/resfinder/bin/blastn \
  -t 0.90 -l 0.60 > $project/tmp/pointfinder.log 2>&1
done
# deactivate resfinder environment
conda deactivate
