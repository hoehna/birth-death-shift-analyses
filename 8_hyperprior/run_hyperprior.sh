#!/bin/bash

N_CORES=4
MCMC_ITER=50000
ds="primates"
NUM_CATS=$1


echo "NUM_RATE_CATEGORIES = ${NUM_CATS}; DATASET = \"${ds}\"; N_RUNS=${N_CORES}; NUM_MCMC_ITERATIONS=${MCMC_ITER}; source(\"Rev_scripts/mcmc_BDS.Rev\")" | mpirun -n ${N_CORES} rb-mpi

Rscript R_scripts/plot_hyperpriors.R


echo "done ..."
