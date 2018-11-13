#!/bin/bash

SCRIPTS_DIR="scripts_tmp"
JOB_FILE="jobs_prior_sensitivity_shifts.txt"

if [ -d ${SCRIPTS_DIR} ]; then
  rm -rf ${SCRIPTS_DIR}
fi
mkdir ${SCRIPTS_DIR}


ds="primates"
script_name="FRCBD_char_mapping"


for n_events in 1 5 10 20 50 100; 
do
    
    Rev_script_name="${SCRIPTS_DIR}/${script_name}_${ds}_n_events_${n_events}.Rev"
    bash_script_name="${SCRIPTS_DIR}/${script_name}_${ds}_n_events_${n_events}.sh"
    
    echo "NUM_RATE_CATEGORIES = 10" > ${Rev_script_name}
    echo "DATASET = \"${ds}\"" >> ${Rev_script_name}
    echo "EXPECTED_NUM_EVENTS = ${n_events}" >> ${Rev_script_name}
    echo "source(\"Rev_scripts/mcmc_${script_name}.Rev\")" >> ${Rev_script_name}
    
    echo "#!/bin/bash" > ${bash_script_name}
    echo "" >> ${bash_script_name}
#    echo "rb ${Rev_script_name}" >> ${bash_script_name}
    echo "mpirun -n 20 rb-mpi ${Rev_script_name}" >> ${bash_script_name}
    
    chmod +x ${bash_script_name}
    
    echo "${bash_script_name}" >> ${JOB_FILE}
    
done

parallel -j 6 ::: bash ${SCRIPTS_DIR}/*.sh
#parallel -j 3 bash -- ${SCRIPTS_DIR}/*.sh
#parallel -j 4 -a ${JOB_FILE}

Rscript R_scripts/plot_branch_rate_prior_sensitivity_num_shifts.R
Rscript R_scripts/plot_prior_sensitivity_num_shifts.R
Rscript R_scripts/plot_branch_rate_tree_sequence.R



rm -rf ${SCRIPTS_DIR}
rm -rf ${JOB_FILE}


rm -rf ${SCRIPTS_DIR}

echo "done ..."
