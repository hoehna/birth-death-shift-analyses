#!/bin/bash

SCRIPTS_DIR="scripts_tmp_branch_rates"
JOB_FILE="jobs_branch_rates.txt"

if [ -d ${SCRIPTS_DIR} ]; then
  rm -rf ${SCRIPTS_DIR}
fi
mkdir ${SCRIPTS_DIR}


ds="primates"

for ncats in 2 4 6 8 10 12 20; 
do
    
    for script_name in "FRCBD_DA" "FRCBD_char_mapping";    
    do
    
        Rev_script_name="${SCRIPTS_DIR}/${script_name}_${ds}_n_cats_${ncats}.Rev"
        bash_script_name="${SCRIPTS_DIR}/${script_name}_${ds}_n_cats_${ncats}.sh"
        
        echo "NUM_RATE_CATEGORIES = ${ncats}" > ${Rev_script_name}
        echo "DATASET = \"${ds}\"" >> ${Rev_script_name}
        echo "source(\"Rev_scripts/mcmc_${script_name}.Rev\")" >> ${Rev_script_name}
        
        echo "#!/bin/bash" > ${bash_script_name}
        echo "" >> ${bash_script_name}
        
        echo "rb ${Rev_script_name}" >> ${bash_script_name}
        
        chmod +x ${bash_script_name}
        
        echo "${bash_script_name}" >> ${JOB_FILE}
          
    done 

done

parallel -j 14 ::: bash ${SCRIPTS_DIR}/*.sh

Rscript R_scripts/plot_branch_rates.R
Rscript R_scripts/plot_branch_rate_num_cats.R


rm -rf ${SCRIPTS_DIR}
rm -rf ${JOB_FILE}


rm -rf ${SCRIPTS_DIR}

echo "done ..."
