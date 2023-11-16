library(RColorBrewer)
#library(viridis)


args <- commandArgs(TRUE)

burnin = 0.25

# settings
H = 0.587405
TL = 1597.287
DATASET             = c("primates")
NUM_RATE_CATEGORIES = as.numeric(args[1])
NUM_REPS            = 4

colors_rep  <- brewer.pal(n=NUM_REPS,name="Set1")[1:(NUM_REPS+0)]


speciation    = list()
extinction    = list()
speciation_sd = list()
extinction_sd = list()
shift_rate    = list()

for ( rep in 1:NUM_REPS) {

    file = paste0("output/",DATASET,"_BDS_SCM_",NUM_RATE_CATEGORIES,"_run_",rep,".log")

    samples = read.table(file, sep="\t", stringsAsFactors=FALSE, check.names=FALSE, header=TRUE)

    # discard the burnin
    samples = samples[-c(1: ceiling(burnin * nrow(samples))),]

    speciation[[rep]]    = samples$`speciation_mean`
    extinction[[rep]]    = samples$`extinction_mean`
    speciation_sd[[rep]] = samples$`speciation_sd`
    extinction_sd[[rep]] = samples$`extinction_sd`
    shift_rate[[rep]]    = samples$`shift_rate`

}




################
# all together #
################



pdf(paste0("figures/hyperprior_",NUM_RATE_CATEGORIES,".pdf"), height=2.75, width=3.25 * 5)
layout_mat = matrix(1:5, nrow=1)
layout(layout_mat)

m = 4
par(mar=c(m,m,0,1), oma=c(0.5,0.5,0.5,0))


y_max = 0
for (rep in 1:NUM_REPS) {
    speciation_mean_density   = density(speciation[[rep]])
    y_max = max(y_max, tail(pretty(max(speciation_mean_density$y)), 1))
}
ylim = c(0, y_max)
xlim = c(1E-6,1.2)

plot(0, ylim=ylim, xlim=xlim, type="n", xaxt="n", yaxt="n", bty="n", xlab="mean speciation rate", ylab="probability density")

for (rep in 1:NUM_REPS) {
    speciation_mean_density   = density(speciation[[rep]])
	lines(speciation_mean_density, col=colors_rep[rep], lwd=4)
}
curve(dunif(x,0,100), col="grey90", lty=2, lwd=4, add=TRUE)

box()
axis(1, lwd.tick=1, lwd=0)
axis(2, lwd.tick=1, lwd=0, las=1)




y_max = 0
for (rep in 1:NUM_REPS) {
    speciation_sd_density   = density(speciation_sd[[rep]])
    y_max = max(y_max, tail(pretty(max(speciation_sd_density$y)), 1))
}
ylim = c(0, y_max)
xlim = c(1E-10,4*H)

plot(0, ylim=ylim, xlim=xlim, type="n", xaxt="n", yaxt="n", bty="n", xlab="standard deviation speciation rate", ylab="probability density")

for (rep in 1:NUM_REPS) {
    speciation_sd_density   = density(speciation_sd[[rep]])
	lines(speciation_sd_density, col=colors_rep[rep], lwd=4)
}
curve(dexp(x,1.0/H), col="grey90", lty=2, lwd=4, add=TRUE)

box()
axis(1, lwd.tick=1, lwd=0)
axis(2, lwd.tick=1, lwd=0, las=1)




y_max = 0
for (rep in 1:NUM_REPS) {
    extinction_mean_density   = density(extinction[[rep]])
    y_max = max(y_max, tail(pretty(max(extinction_mean_density$y)), 1))
}
ylim = c(0, y_max)
xlim = c(1E-6,2.5)

plot(0, ylim=ylim, xlim=xlim, type="n", xaxt="n", yaxt="n", bty="n", xlab="mean extinction rate", ylab="probability density")

for (rep in 1:NUM_REPS) {
    extinction_mean_density   = density(extinction[[rep]])
	lines(extinction_mean_density, col=colors_rep[rep], lwd=4)
}
curve(dunif(x,0,100), col="grey90", lty=2, lwd=4, add=TRUE)

box()
axis(1, lwd.tick=1, lwd=0)
axis(2, lwd.tick=1, lwd=0, las=1)




y_max = 0
for (rep in 1:NUM_REPS) {
    extinction_sd_density   = density(extinction_sd[[rep]])
    y_max = max(y_max, tail(pretty(max(extinction_sd_density$y)), 1))
}
ylim = c(0, y_max)
xlim = c(1E-10,8*H)

plot(0, ylim=ylim, xlim=xlim, type="n", xaxt="n", yaxt="n", bty="n", xlab="standard deviation extinction rate", ylab="probability density")

for (rep in 1:NUM_REPS) {
    extinction_sd_density   = density(extinction_sd[[rep]])
	lines(extinction_sd_density, col=colors_rep[rep], lwd=4)
}
curve(dexp(x,1.0/H), col="grey90", lty=2, lwd=4, add=TRUE)

box()
axis(1, lwd.tick=1, lwd=0)
axis(2, lwd.tick=1, lwd=0, las=1)



y_max = 0
for (rep in 1:NUM_REPS) {
    shift_rate_density   = density(shift_rate[[rep]])
    y_max = max(y_max, tail(pretty(max(shift_rate_density$y)), 1))
}
ylim = c(0, y_max)
xlim = c(1E-10,100/TL)
plot(0, ylim=ylim, xlim=xlim, type="n", xaxt="n", yaxt="n", bty="n", xlab="E(S)", ylab="probability density")

for (rep in 1:NUM_REPS) {
    shift_rate_density   = density(shift_rate[[rep]])
	lines(shift_rate_density, col=colors_rep[rep], lwd=4)
}
curve(dunif(x,0,100/TL), col="grey90", lty=2, lwd=4, add=TRUE)

box()
axis(1, lwd.tick=1, lwd=0, at=seq(0,100,by=10)/TL, labels=seq(0,100,by=10))
axis(2, lwd.tick=1, lwd=0, las=1)

legend("topright", legend=c(paste0("posterior rep ",1:NUM_REPS),"prior"), lty=c(rep(1,NUM_REPS),2), lwd=c(rep(4,NUM_REPS),4), bty="n", col=c(colors_rep,"grey90"))

dev.off()
