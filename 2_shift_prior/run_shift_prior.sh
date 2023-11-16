#!/bin/bash

SCRIPTS_DIR="scripts_tmp_shift_prior"

if [ -d ${SCRIPTS_DIR} ]; then
  rm -rf ${SCRIPTS_DIR}
fi
mkdir ${SCRIPTS_DIR}


ncats="4"
ds="primates"

for n_exp in 1 10 20;
do

#    for script_name in "BDS_SCM_shift_prior" "BDS_DA_shift_prior";
    for script_name in "BDS_SCM_shift_prior";
    do

        Rev_script_name="${SCRIPTS_DIR}/${script_name}_${ds}_n_cats_${ncats}_n_events_${n_exp}.Rev"

        echo "NUM_RATE_CATEGORIES = ${ncats}" > ${Rev_script_name}
        echo "EXPECTED_NUM_EVENTS = ${n_exp}" >> ${Rev_script_name}
        echo "DATASET = \"${ds}\"" >> ${Rev_script_name}
        echo "source(\"Rev_scripts/mcmc_${script_name}.Rev\")" >> ${Rev_script_name}

        mpirun -n 16 rb-mpi ${Rev_script_name}

    done

done


Rscript R_scripts/plot_shift_prior.R


rm -rf ${SCRIPTS_DIR}
rm -rf ${JOB_FILE}

echo "done ..."
