#!/bin/bash

SCRIPTS_DIR="scripts_tmp"
JOB_FILE="jobs_prior_sensitivity_num_cats.txt"

if [ -d ${SCRIPTS_DIR} ]; then
  rm -rf ${SCRIPTS_DIR}
fi
mkdir ${SCRIPTS_DIR}


ds="primates"
script_name="FRCBD_char_mapping"

for ncats in 2 4 6 8 10 20; 
do
    
    Rev_script_name="${SCRIPTS_DIR}/${script_name}_${ds}_n_cats_${ncats}.Rev"
    bash_script_name="${SCRIPTS_DIR}/${script_name}_${ds}_n_cats_${ncats}.sh"
    
    echo "NUM_RATE_CATEGORIES = ${ncats}" > ${Rev_script_name}
    echo "DATASET = \"${ds}\"" >> ${Rev_script_name}
    echo "EXPECTED_NUM_EVENTS = 10" >> ${Rev_script_name}
    echo "source(\"Rev_scripts/mcmc_${script_name}.Rev\")" >> ${Rev_script_name}
    
    echo "#!/bin/bash" > ${bash_script_name}
    echo "" >> ${bash_script_name}
    echo "rb ${Rev_script_name}" >> ${bash_script_name}
    
    chmod +x ${bash_script_name}
    
    echo "${bash_script_name}" >> ${JOB_FILE}
    
done


parallel -j 6 ::: bash ${SCRIPTS_DIR}/*.sh
#parallel -j 4 -a ${JOB_FILE}

Rscript R_scripts/plot_branch_rate_prior_sensitivity_num_cats.R


rm -rf ${SCRIPTS_DIR}
rm -rf ${JOB_FILE}


rm -rf ${SCRIPTS_DIR}

echo "done ..."
