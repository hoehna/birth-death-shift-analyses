#!/bin/bash

SCRIPTS_DIR="scripts_tmp_ESS"
JOB_FILE="jobs_ESS.txt"

if [ -d ${SCRIPTS_DIR} ]; then
  rm -rf ${SCRIPTS_DIR}
fi
mkdir ${SCRIPTS_DIR}

if [ -d runtime ]; then
  rm -rf runtime
fi
mkdir runtime

if [ -d screen_log ]; then
  rm -rf screen_log
fi
mkdir screen_log

ds="primates"
nevents=10
for ncats in 2 4 6 8 10; 
do
    
    for script_name in "FRCBD" "FRCBD_char_mapping";    
    do
    
        Rev_script_name="${SCRIPTS_DIR}/${script_name}_${ds}_n_cats_${ncats}_n_exp_${nevents}.Rev"
        bash_script_name="${SCRIPTS_DIR}/${script_name}_${ds}_n_cats_${ncats}_n_exp_${nevents}.sh"
        
        echo "NUM_RATE_CATEGORIES = ${ncats}" > ${Rev_script_name}
        echo "DATASET = \"${ds}\"" >> ${Rev_script_name}
        echo "EXPECTED_NUM_EVENTS = ${nevents}" >> ${Rev_script_name}
        echo "source(\"Rev_scripts/mcmc_${script_name}.Rev\")" >> ${Rev_script_name}
        
        echo "#!/bin/bash" > ${bash_script_name}
        echo "date_${script_name}_${ds}_${ncats}_1"'=$(date +"%s")' >> ${bash_script_name}
#        echo "rb ${Rev_script_name} > screen_log/${ds}_${script_name}_${ncats}_${nevents}.out" >> ${bash_script_name}
        echo "mpirun -n 4 rb-mpi ${Rev_script_name} > screen_log/${ds}_${script_name}_${ncats}_${nevents}.out" >> ${bash_script_name}
        echo "date_${script_name}_${ds}_${ncats}_2"'=$(date +"%s")' >> ${bash_script_name}
        echo 'diff'"${script_name}_${ds}_${ncats}"'=$(($date_'"${script_name}_${ds}_${ncats}_2-"'$date'"_${script_name}_${ds}_${ncats}_1))" >> ${bash_script_name}
        echo 'echo $diff'"${script_name}_${ds}_${ncats}"' >> '"runtime/${script_name}_${ds}_${ncats}_runtime.txt" >> ${bash_script_name}
        
        chmod +x ${bash_script_name}
        
        echo "${bash_script_name}" >> ${JOB_FILE}
          
    done 

done




ds="primates"
ncats=4
for nevents in 1 20; 
do
    
    for script_name in "FRCBD" "FRCBD_char_mapping";    
    do
    
        Rev_script_name="${SCRIPTS_DIR}/${script_name}_${ds}_n_cats_${ncats}_n_exp_${nevents}.Rev"
        bash_script_name="${SCRIPTS_DIR}/${script_name}_${ds}_n_cats_${ncats}_n_exp_${nevents}.sh"
        
        echo "NUM_RATE_CATEGORIES = ${ncats}" > ${Rev_script_name}
        echo "DATASET = \"${ds}\"" >> ${Rev_script_name}
        echo "EXPECTED_NUM_EVENTS = ${nevents}" >> ${Rev_script_name}
        echo "source(\"Rev_scripts/mcmc_${script_name}.Rev\")" >> ${Rev_script_name}
        
        echo "#!/bin/bash" > ${bash_script_name}
        echo "date_${script_name}_${ds}_${ncats}_1"'=$(date +"%s")' >> ${bash_script_name}
#        echo "rb ${Rev_script_name} > screen_log/${ds}_${script_name}_${ncats}_${nevents}.out" >> ${bash_script_name}
        echo "mpirun -n 4 rb-mpi ${Rev_script_name} > screen_log/${ds}_${script_name}_${ncats}_${nevents}.out" >> ${bash_script_name}
        echo "date_${script_name}_${ds}_${ncats}_2"'=$(date +"%s")' >> ${bash_script_name}
        echo 'diff'"${script_name}_${ds}_${ncats}"'=$(($date_'"${script_name}_${ds}_${ncats}_2-"'$date'"_${script_name}_${ds}_${ncats}_1))" >> ${bash_script_name}
        echo 'echo $diff'"${script_name}_${ds}_${ncats}"' >> '"runtime/${script_name}_${ds}_${ncats}_runtime.txt" >> ${bash_script_name}
        
        chmod +x ${bash_script_name}
        
        echo "${bash_script_name}" >> ${JOB_FILE}
          
    done 

done



nevents=10
ncats=4
for ds in "byttneria" "conifers" "ericaceae" "viburnum" "cetaceans"; 
do
    
    for script_name in "FRCBD" "FRCBD_char_mapping";    
    do
    
        Rev_script_name="${SCRIPTS_DIR}/${script_name}_${ds}_n_cats_${ncats}_n_exp_${nevents}.Rev"
        bash_script_name="${SCRIPTS_DIR}/${script_name}_${ds}_n_cats_${ncats}_n_exp_${nevents}.sh"
        
        echo "NUM_RATE_CATEGORIES = ${ncats}" > ${Rev_script_name}
        echo "DATASET = \"${ds}\"" >> ${Rev_script_name}
        echo "EXPECTED_NUM_EVENTS = ${nevents}" >> ${Rev_script_name}
        echo "source(\"Rev_scripts/mcmc_${script_name}.Rev\")" >> ${Rev_script_name}
        
        echo "#!/bin/bash" > ${bash_script_name}
        echo "date_${script_name}_${ds}_${ncats}_1"'=$(date +"%s")' >> ${bash_script_name}
#        echo "rb ${Rev_script_name} > screen_log/${ds}_${script_name}_${ncats}_${nevents}.out" >> ${bash_script_name}
        echo "mpirun -n 4 rb-mpi ${Rev_script_name} > screen_log/${ds}_${script_name}_${ncats}_${nevents}.out" >> ${bash_script_name}
        echo "date_${script_name}_${ds}_${ncats}_2"'=$(date +"%s")' >> ${bash_script_name}
        echo 'diff'"${script_name}_${ds}_${ncats}"'=$(($date_'"${script_name}_${ds}_${ncats}_2-"'$date'"_${script_name}_${ds}_${ncats}_1))" >> ${bash_script_name}
        echo 'echo $diff'"${script_name}_${ds}_${ncats}"' >> '"runtime/${script_name}_${ds}_${ncats}_runtime.txt" >> ${bash_script_name}
        
        chmod +x ${bash_script_name}
        
        echo "${bash_script_name}" >> ${JOB_FILE}
          
    done 

done

parallel -j 5 ::: bash ${SCRIPTS_DIR}/*.sh

Rscript R_scripts/summarize_results_overall.R


rm -rf ${SCRIPTS_DIR}
rm -rf ${JOB_FILE}


rm -rf ${SCRIPTS_DIR}

echo "done ..."
