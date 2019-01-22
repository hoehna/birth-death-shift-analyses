library(viridis)

colors = viridis(3, begin=0.3, end=0.9)

##################################################################
# plot the branch-rate estimates as a function of the event rate #
##################################################################

# the settings
DATASET             = c("primates")
NUM_RATE_CATEGORIES = c(2, 4, 6, 8, 10, 20)
EXPECTED_NUM_EVENTS = 10


# read the posterior distributions
branch_lambdas = vector("list", length(NUM_RATE_CATEGORIES))
for(i in 1:length(NUM_RATE_CATEGORIES)) {

  N = NUM_RATE_CATEGORIES[i]

  cat(N,"\t")

  file = paste0("output/",DATASET,"_FRCBD_rates_num_cats_",N,"_num_events_",EXPECTED_NUM_EVENTS,".log")
  samples = read.table(file, sep="\t", stringsAsFactors=FALSE, check.names=FALSE, header=TRUE)

  # discard some burnin (25%)
  burnin = 0.25
  n_samples = nrow(samples)
  # combine the mcmc output
  lambda_output   = samples[-c(1:ceiling(n_samples * burnin)),grepl("avg_lambda", colnames(samples))]

  # store the parameters
  lambda_mean = colMeans(lambda_output)

  branch_lambdas[[i]] = lambda_mean[-length(lambda_mean)]

  cat("\n")

}


# make the plot
layout_mat = matrix(1:(length(NUM_RATE_CATEGORIES)-1), nrow=1)
range      = range(pretty(unlist(branch_lambdas)))

# = 19
pch = 4
cex = 0.5
f   = 1.5
col = colors[2]
m   = 4

pdf(paste0("../figures/branch_rate_sensitivity_num_categories_",DATASET,"_sequence.pdf"), height=2.75, width=2.4 * (length(NUM_RATE_CATEGORIES)-1))

layout(layout_mat)

par(mar=c(0,0,0,m), oma=c(m,m,m,0))

for(i in 1:(length(NUM_RATE_CATEGORIES)-1)) {

  plot(branch_lambdas[[i+1]], branch_lambdas[[i]], xlim=range, ylim=range, pch=pch, cex=cex * f, xaxt="n", yaxt="n", xlab=NA, ylab=NA)
  abline(a=0, b=1, lty=2)
  axis(1, lwd.tick=1, lwd=0)
  mtext(side=2, text=paste0("k = ",NUM_RATE_CATEGORIES[i]),    line=1.2)
  mtext(side=3, text=paste0("k = ",NUM_RATE_CATEGORIES[i+1]),  line=1.2)
  mtext(side=1, text="branch-specific speciation rate", line=2.5, cex=0.7)

}

axis(4, lwd.tick=1, lwd=0)
mtext(side=4, text="branch-specific speciation rate",  line=2.5, cex=0.7)


dev.off()






