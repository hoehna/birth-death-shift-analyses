#!/bin/bash

# Compute all the likelihoods
rb Rev_scripts/likelihoods_primates.Rev

# plot the likelihood curves
Rscript R_scripts/plot_likelihood_surface.R


echo "done ..."
