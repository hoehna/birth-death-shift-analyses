#!/bin/bash

# Compute all the likelihoods
rb Rev_scripts/likelihoods_all_datasets.Rev

# plot the likelihood curves
Rscript R_scripts/plot_likelihood_surface.R
Rscript R_scripts/plot_all_likelihood_surfaces.R


echo "done ..."
