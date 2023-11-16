#!/bin/bash

SCRIPTS_DIR="scripts_tmp"

if [ -d ${SCRIPTS_DIR} ]; then
  rm -rf ${SCRIPTS_DIR}
fi
mkdir ${SCRIPTS_DIR}


ds="primates"
script_name="BDS_SCM"


for n_events in 1 5 10 20 50 100;
do

    Rev_script_name="${SCRIPTS_DIR}/${script_name}_${ds}_n_events_${n_events}.Rev"

    echo "NUM_RATE_CATEGORIES = 10" > ${Rev_script_name}
    echo "DATASET = \"${ds}\"" >> ${Rev_script_name}
    echo "EXPECTED_NUM_EVENTS = ${n_events}" >> ${Rev_script_name}
    echo "source(\"Rev_scripts/mcmc_${script_name}.Rev\")" >> ${Rev_script_name}

    mpirun -n 16 rb-mpi ${Rev_script_name}

done


Rscript R_scripts/plot_branch_rate_prior_sensitivity_num_shifts.R
Rscript R_scripts/plot_prior_sensitivity_num_shifts.R
Rscript R_scripts/plot_branch_rate_tree_sequence.R



rm -rf ${SCRIPTS_DIR}


rm -rf ${SCRIPTS_DIR}

echo "done ..."
