#!/bin/bash

N_CORES=4
JOB_DIR="jobs"
LOG_DIR="logs"
MCMC_ITER=12500

if [ ${JOB_DIR} != "" ]; then
  if [ ! -d ${JOB_DIR} ]; then
    mkdir ${JOB_DIR}
#  else
#    rm -f ${JOB_DIR}/*
  fi
fi

if [ ${LOG_DIR} != "" ]; then
  if [ ! -d ${LOG_DIR} ]; then
    mkdir ${LOG_DIR}
#  else
#    rm -f ${LOG_DIR}/*
  fi
fi

#prior="uniform"
#for prior in "uniform" "loguniform" "exponential";
for prior in "exponential";
do

    for ds in `seq 11 50`;
    do
	    echo "#!/bin/bash
#SBATCH --job-name=RB_BDS_sim_${ds}_${prior}
#SBATCH --output=RB_BDS_sim_${ds}_${prior}.log
#SBATCH --error=RB_BDS_sim_${ds}_${prior}.err
#SBATCH --ntasks=${N_CORES}
#SBATCH --nodes=1
#SBATCH --mem=${N_CORES}G
#SBATCH --qos=low
#SBATCH --time=28-00:00:00
#
#SBATCH --mail-user sebastian.hoehna@gmail.com
#SBATCH --mail-type=ALL


echo \"NUM_RATE_CATEGORIES = 4; DATA_DIR = \\\"simulated_data_large_jumps\\\"; DATASET = \\\"sim_${ds}\\\"; PRIORS = \\\"${prior}\\\"; RATES=\\\"both_var\\\"; OUTPUT_DIR = \\\"output_${prior}\\\"; N_RUNS=${N_CORES}; NUM_MCMC_ITERATIONS=${MCMC_ITER}; source(\\\"scripts/mcmc_BDS.Rev\\\")\" | mpirun -np ${N_CORES} rb-mpi > ${LOG_DIR}/${ds}_${prior}.out
" > ${JOB_DIR}/${ds}_${prior}.sh
        sbatch ${JOB_DIR}/${ds}_${prior}.sh

	done

done

echo "done ..."
