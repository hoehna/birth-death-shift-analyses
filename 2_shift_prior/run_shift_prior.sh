#!/bin/bash

SCRIPTS_DIR="scripts_tmp_shift_prior"
JOB_FILE="jobs_shift_prior.txt"

if [ -d ${SCRIPTS_DIR} ]; then
  rm -rf ${SCRIPTS_DIR}
fi
mkdir ${SCRIPTS_DIR}

if [ -d runtime ]; then
  rm -rf runtime
fi
mkdir runtime


ncats="4" 
ds="primates"

for n_exp in 1 5 10 20; 
do

    for script_name in "FRCBD_char_mapping_shift_prior" "FRCBD_DA_shift_prior";
    do
    
        Rev_script_name="${SCRIPTS_DIR}/${script_name}_${ds}_n_cats_${ncats}_n_events_${n_exp}.Rev"
        bash_script_name="${SCRIPTS_DIR}/${script_name}_${ds}_n_cats_${ncats}_n_events_${n_exp}.sh"
    
        echo "NUM_RATE_CATEGORIES = ${ncats}" > ${Rev_script_name}
        echo "EXPECTED_NUM_EVENTS = ${n_exp}" >> ${Rev_script_name}
        echo "DATASET = \"${ds}\"" >> ${Rev_script_name}
        echo "source(\"Rev_scripts/mcmc_${script_name}.Rev\")" >> ${Rev_script_name}

        echo "#!/bin/bash" > ${bash_script_name}
        echo "" >> ${bash_script_name}
        
        if [[ $script_name == "FRCBD_DA_shift_prior" ]] ; then
            echo "mpirun -n 8 rb-mpi ${Rev_script_name}" >> ${bash_script_name}
        else
            echo "rb ${Rev_script_name}" >> ${bash_script_name}
        fi

        chmod +x ${bash_script_name}

        echo "${bash_script_name}" >> ${JOB_FILE}
	
    done

done


parallel -j 8 ::: bash ${SCRIPTS_DIR}/*.sh

Rscript R_scripts/plot_shift_prior.R


rm -rf ${SCRIPTS_DIR}
rm -rf ${JOB_FILE}

echo "done ..."
