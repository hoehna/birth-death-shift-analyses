#!/bin/bash

TMP_OUTPUT_DIR="output_coverage_tmp"

rm -rf ${TMP_OUTPUT_DIR}
mkdir ${TMP_OUTPUT_DIR}

run_rev() {
    echo "rep = ${1}; source(\"Rev_scripts/sim_validation_prior.Rev\");" | rb > output_coverage_tmp/${1}.out
}

export -f run_rev


seq 1 1000 | parallel -j28 --eta --delay 0.5 run_rev 


Rscript R_scripts/plot_hpd_width_vs_coverage_prior.R 
Rscript R_scripts/plot_rates.R 


rm -rf ${TMP_OUTPUT_DIR}
rm history.txt
