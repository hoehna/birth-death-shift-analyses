#!/bin/bash

SCRIPTS_DIR="scripts_tmp_branch_rates"

if [ -d ${SCRIPTS_DIR} ]; then
  rm -rf ${SCRIPTS_DIR}
fi
mkdir ${SCRIPTS_DIR}


ds="primates"

for ncats in 4 6 8 10 12 20;
do

    for script_name in "BDS_DA" "BDS_SCM";
    do

        Rev_script_name="${SCRIPTS_DIR}/${script_name}_${ds}_n_cats_${ncats}.Rev"

        echo "NUM_RATE_CATEGORIES = ${ncats}" > ${Rev_script_name}
        echo "DATASET = \"${ds}\"" >> ${Rev_script_name}
        echo "source(\"Rev_scripts/mcmc_${script_name}.Rev\")" >> ${Rev_script_name}

        mpirun -n 32 rb-mpi ${Rev_script_name}

    done

done

Rscript R_scripts/plot_branch_rate_num_cats.R


rm -rf ${SCRIPTS_DIR}


rm -rf ${SCRIPTS_DIR}

echo "done ..."
