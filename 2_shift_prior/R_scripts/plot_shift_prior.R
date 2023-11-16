library(viridis)


#####
plot.shift.prior <- function ( DATASET = "primates" ) {

NUM_RATE_CATEGORIES = 4
EXPECTED_NUM_EVENTS = c(1, 10, 20)
INT_METHOD          = c("DA","SCM")

# make the grid
grid = expand.grid(EXPECTED_NUM_EVENTS = EXPECTED_NUM_EVENTS,
                   NUM_RATE_CATEGORIES = NUM_RATE_CATEGORIES,
                   INT_METHOD          = INT_METHOD,
                   DATASET             = DATASET,
                   stringsAsFactors    = FALSE)

summary = do.call(rbind, apply(grid, 1, function(row){

  D = row["DATASET"]
  N = as.numeric(row["NUM_RATE_CATEGORIES"])
  E = as.numeric(row["EXPECTED_NUM_EVENTS"])
  I = row["INT_METHOD"]

  cat(as.character(row), "\n")

  if ( I == "DA" ) {

    file = paste0("output_shift_prior/",D,"_BDS_DA_",N,"_",E,".log")
    samples = read.table(file, sep="\t", stringsAsFactors=FALSE, check.names=FALSE, header=TRUE)
    num_events = samples$total_num_events

  } else {

    file = paste0("output_shift_prior/",D,"_BDS_SCM_",N,"_",E,".log")
    samples = read.table(file, sep="\t", stringsAsFactors=FALSE, check.names=FALSE, header=TRUE)
    samples = samples[,grepl("num_shifts", colnames(samples))]
    num_events = rowSums(samples)

  }

  burnin = round(0.2*nrow(samples))
  posterior_dist = table(num_events[burnin:nrow(samples)]) / (nrow(samples)-burnin+1)

  res = data.frame(EXPECTED_NUM_EVENTS = E,
                   NUM_RATE_CATEGORIES = N,
                   INT_METHOD          = I,
                   DATASET             = D,
                   num_events          = I(list(num_events)),
                   posterior_dist      = I(list(posterior_dist)),
                   stringsAsFactors    = FALSE)

  return(res)

}))




################
# all together #
################

pch_DA = 3
pch_NI = 4
pch    = c(pch_DA, pch_NI)

colors = viridis(length(EXPECTED_NUM_EVENTS), begin=0.3)

xlim = c(0,max(qpois(0.99, EXPECTED_NUM_EVENTS)))
ylim = c(0,0.4)
nums = xlim[1]:xlim[2]

pdf(paste0("../figures/num_shifts.pdf"), height=5)
par(mar=c(5,5,3,5))

plot(0, ylim=ylim, xlim=xlim, type="n", xaxt="n", yaxt="n", bty="n", xlab="number of shifts", ylab="probability")

for(i in 1:length(EXPECTED_NUM_EVENTS)) {

  prior = EXPECTED_NUM_EVENTS[i]

  this_summary = summary[summary$EXPECTED_NUM_EVENTS == prior,]
  this_summary = split(this_summary, list(this_summary$INT_METHOD))

  da_num = unlist(this_summary$DA$num_events)
  ni_num = unlist(this_summary$SCM$num_events)

  da_post = tabulate(da_num+1, nbins=1+xlim[2]) / length(da_num)
  ni_post = tabulate(ni_num+1, nbins=1+xlim[2]) / length(ni_num)

  lines(nums, dpois(nums, prior, log=FALSE), type="l", pch=19, col=colors[i], lty=1)
  points(nums, da_post, type="p", col=colors[i], pch=pch[1], lwd=1)
  points(nums, ni_post, type="p", col=colors[i], pch=pch[2], lwd=1)

}

box()
axis(1, lwd.tick=1, lwd=0)
axis(2, lwd.tick=1, lwd=0, las=1)

legend("top", legend=c("prior","data augmentation","numerical integration"), lwd=c(1,NA,NA), pch=c(NA,pch_DA,pch_NI), bty="n")
legend("topright", legend=EXPECTED_NUM_EVENTS, title="E(S)", fill=colors, bty="n", border=NA)

dev.off()

}



plot.shift.prior("primates")
