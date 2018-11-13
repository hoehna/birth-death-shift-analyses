Finalized figures:
==================


Likelihood_surface
------------------
* Comparing the likelihood under 3 models when eta=0 and all diversification rate categories are equal.
	- constant-rate birth-death process
	- birth-death-shift process with data augmentation
	- birth-death-shift process with numerical integration
* Files:
	- 0_likelihood
	- likelihoods_all_datasets.Rev
	- plot_likelihood_surface.R
	- Figure 5




num_shifts
----------
* Comparing the prior distribution on the of rate-shift events with the posterior distribution if all diversification rate categories are equal.
* Note: I cranked up the number of time-slices to 5000 (nTimeSlices=5000) to get the numerical integration close enough.
* Files:
	- 2_shift_prior
	- run_shift_prior.sh
	- Figure 6




branch_rate_num_categories_sequence
-----------------------------------
* Note: The DA method regularly fails to converge for k=2 because we disallow changes to the same category which makes adding and removing shift events difficult. 
* Comparing the estimated branch-specific diversification rates between the stochastic character mapping and data augmentation methods.
* Files:
	- 3_branch_rates
	- run_branch_rates.sh
	- Figure 7




hpd_width_vs_coverage_prior & sim_net_div
-----------------------------------------
* Started new run on Nov 8th at 4:20PM on corvus.
* Testing if we can recover the true parameters used in simulations. 
* Files:
	- 4_coverage
	- run_parallel_validations.sh
	- Figure 8-9




ESS_comparison
--------------
* Not run yet. 
* Comparing the efficiency in terms of ESS between the stochastic character mapping and data augmentation methods.
* Files:
	- 5_ESS
	- ???
	- Figure 10




branch_rate_sensitivity_num_categories_primates_sequence
--------------------------------------------------------
* Assessing the sensitivity of the number of diversification-rate categories (k) on branch-rate estimates.
* Files:
	- 6_prior_sensitivity_num_cats
	- run_prior_sensitivity_num_cats.sh
	- Figure 11



prior_sensitivity_num_shifts & branch_rate_sensitivity_num_shifts_primates_sequence & branch_speciation_rates_tree
------------------------------------------------------------------------------------------------------------------
* Assessing the prior sensitivity of the shift prior on
	a) number of estimated diversification-rate shifts.
	b) branch-rate estimates.
* Files:
	- 7_prior_sensitivity_shifts
	- run_prior_sensitivity_shifts.sh
	- Figure 12-14



hyperprior
----------
* Estimating hyperprior parameters under primates phylogeny.
* Files:
	- 8_hyperprior
	- run_hyperprior.sh
	- Figure 16




