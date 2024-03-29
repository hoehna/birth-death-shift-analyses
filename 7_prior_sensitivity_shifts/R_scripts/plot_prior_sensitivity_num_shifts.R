library(viridis)

colors = viridis(3, begin=0.3)
SD = 0.587405

##################################################################
# plot the estimated number of events as a function of the prior #
# for a given number of rate categories                          #
##################################################################

# the settings
DATASET             = c("primates")
NUM_RATE_CATEGORIES = 10
EXPECTED_NUM_EVENTS = c(1, 10, 20)

nbins = 41
all_values = 1:nbins - 1


# read the posterior distributions
posterior_distributions = vector("list", length(EXPECTED_NUM_EVENTS))

for(i in 1:length(EXPECTED_NUM_EVENTS)) {

  E = EXPECTED_NUM_EVENTS[i]

  cat(E,"\t")

  file = paste0("output/",DATASET,"_BDS_SCM_rates_num_cats_",NUM_RATE_CATEGORIES,"_num_events_",E,".log")
  samples = read.table(file, sep="\t", stringsAsFactors=FALSE, check.names=FALSE, header=TRUE)

  # discard some burnin (20%)
  burnin = 0.20
  n_samples = nrow(samples)

  samples = samples[-c(1:ceiling(n_samples * burnin)),grepl("num_shifts", colnames(samples))]
  num_events = rowSums(samples)

  # compute the posterior distribution
  posterior_distribution = tabulate(num_events+1, nbins=nbins) / length(num_events)

  posterior_distributions[[i]] = posterior_distribution

  cat("\n")

}



# plot the number of events

# set the x range
x_range = c(0, 40)

# compute the y range
max_post_density  = max(unlist(posterior_distributions))
max_prior_density = 1.3 * max_post_density
y_range = c(0, max(max_post_density, max_prior_density))

pdf(paste0("../figures/prior_sensitivity_num_shifts.pdf"), height=4.5, width=6)
par(mar=c(4,4,0.2,0.1))

# plot the densities
plot(NA, xlim=x_range, ylim=y_range, xlab="", ylab="", las=1, xaxt="n", bty="n", xaxt="n", yaxt="n")

# the posteriors
for(j in 1:length(EXPECTED_NUM_EVENTS)) {
  barplot(posterior_distributions[[j]], names.arg=all_values, col=colors[j], xaxt="n", bty="n", xaxt="n", yaxt="n", space=0, border=NA, density=50, angle=45*j, add=TRUE)
}


# the priors
for(j in 1:length(EXPECTED_NUM_EVENTS)) {
  prior = EXPECTED_NUM_EVENTS[j]
  lines(all_values, dpois(x_range[1]:x_range[2], prior, log=FALSE), type="s", pch=19, col=colors[j], lty=1, lwd=2)
}

axis(1)
mtext("number of shifts", side=1, line=2.5)
mtext("probability", side=2, line=2.5)

legend("topright", legend=EXPECTED_NUM_EVENTS, title="E(S)", lty=1, col=colors, bty="n")

box()

axis(1, lwd.tick=1, lwd=0)
axis(2, lwd.tick=1, lwd=0)

dev.off()
