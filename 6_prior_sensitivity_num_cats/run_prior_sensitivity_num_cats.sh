#!/bin/bash

SCRIPTS_DIR="scripts_tmp"

if [ -d ${SCRIPTS_DIR} ]; then
  rm -rf ${SCRIPTS_DIR}
fi
mkdir ${SCRIPTS_DIR}


ds="primates"
script_name="BDS_SCM"

for ncats in 2 4 6 8 10 20;
do

    Rev_script_name="${SCRIPTS_DIR}/${script_name}_${ds}_n_cats_${ncats}.Rev"

    echo "NUM_RATE_CATEGORIES = ${ncats}" > ${Rev_script_name}
    echo "DATASET = \"${ds}\"" >> ${Rev_script_name}
    echo "EXPECTED_NUM_EVENTS = 10" >> ${Rev_script_name}
    echo "source(\"Rev_scripts/mcmc_${script_name}.Rev\")" >> ${Rev_script_name}

    mpirun -np 16 rb-mpi ${Rev_script_name}


done


Rscript R_scripts/plot_branch_rate_prior_sensitivity_num_cats.R


rm -rf ${SCRIPTS_DIR}

echo "done ..."
