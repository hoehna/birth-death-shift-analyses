#!/bin/bash

N_REPS=1000

rm -rf temp_output
rm -rf simulated_data

if [ ! -d temp_output ]; then
    mkdir temp_output
fi

run_rev() {
    echo "rep=\"${1}\"; NUM_RATE_CATEGORIES=4; source(\"scripts/sim.Rev\");" | \
    rb > temp_output/sim_BDS_${1}.out
}

export -f run_rev


seq 1 ${N_REPS} | parallel -j4 --eta --delay 0.5 run_rev




echo "done ..."
