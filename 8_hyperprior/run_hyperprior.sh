#!/bin/bash

SCRIPTS_DIR="scripts_tmp"
JOB_FILE="jobs_hyperprior.txt"

if [ -d ${SCRIPTS_DIR} ]; then
  rm -rf ${SCRIPTS_DIR}
fi
mkdir ${SCRIPTS_DIR}


ds="primates"
script_name="FRCBD_char_mapping"


Rev_script_name="${SCRIPTS_DIR}/${script_name}_${ds}.Rev"
bash_script_name="${SCRIPTS_DIR}/${script_name}_${ds}.sh"
    
echo "NUM_RATE_CATEGORIES = 10" > ${Rev_script_name}
echo "DATASET = \"${ds}\"" >> ${Rev_script_name}
echo "EXPECTED_NUM_EVENTS = 10" >> ${Rev_script_name}
echo "source(\"Rev_scripts/mcmc_${script_name}.Rev\")" >> ${Rev_script_name}
    
echo "#!/bin/bash" > ${bash_script_name}
echo "" >> ${bash_script_name}
echo "mpirun -n 20 rb-mpi ${Rev_script_name}" >> ${bash_script_name}
    
chmod +x ${bash_script_name}
    
echo "${bash_script_name}" >> ${JOB_FILE}
    

parallel -j 1 ::: bash ${SCRIPTS_DIR}/*.sh

Rscript R_scripts/plot_hyperpriors.R



rm -rf ${SCRIPTS_DIR}
rm -rf ${JOB_FILE}


rm -rf ${SCRIPTS_DIR}

echo "done ..."
