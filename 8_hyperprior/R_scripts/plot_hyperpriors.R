#library(viridis)

burnin = 0.25

# settings
H = 0.587405
TL = 1597.287
DATASET             = c("primates")
NUM_RATE_CATEGORIES = 10
EXPECTED_NUM_EVENTS = 10


file = paste0("output/",DATASET,"_FRCBD_stoch_char_map_",NUM_RATE_CATEGORIES,"_num_events_",EXPECTED_NUM_EVENTS,".log")
#file = paste0("output/",DATASET,"_FRCBD_stoch_char_map_",NUM_RATE_CATEGORIES,"_num_events_",EXPECTED_NUM_EVENTS,"_run_1.log")
cat(file,"\n")

samples = read.table(file, sep="\t", stringsAsFactors=FALSE, check.names=FALSE, header=TRUE)

# discard the burnin
samples = samples[-c(1: ceiling(burnin * nrow(samples))),]

speciation = samples$`speciation_mean`
extinction = samples$`extinction_mean`
speciation_sd = samples$`rate_sd`
shift_rate = samples$`event_rate`



cat("#Samples:\t\t\t",length(speciation),"\n")
cat("E[speciation]:\t\t\t",355/TL,"\n")
cat("Mean speciation:\t\t",mean(speciation),"\n")
cat("SD speciation:\t\t\t",mean(speciation_sd),"\n")
cat("E[S]:\t\t\t\t",mean(shift_rate)*TL,"\n")



################
# all together #
################

# speciation rate
speciation_density = density(speciation)

ylim = c(0, tail(pretty(max(speciation_density$y)), 1))
#ylim = c(0, tail(pretty(max(prior_density$y)), 1))
xlim = range(pretty(speciation_density$x))
xlim = c(1E-6,1.2)

pdf("../figures/hyperprior_mean.pdf", height=5)
par(mar=c(5,5,3,5), lend=2)

plot(0, ylim=ylim, xlim=xlim, type="n", xaxt="n", yaxt="n", bty="n", xlab="mean speciation rate", ylab="probability density")
#plot(0, ylim=ylim, xlim=xlim, type="n", xaxt="n", log="x", yaxt="n", bty="n", xlab="mean speciation rate", ylab="probability density")

lines(speciation_density, col="black", lwd=4)
curve(dunif(x,0,100), col="grey90", lty=2, lwd=4, add=TRUE)

box()
axis(1, lwd.tick=1, lwd=0)
axis(2, lwd.tick=1, lwd=0, las=1)

#legend("topleft", legend=c("constant-rate BDP","data augmentation","numerical integration"), lty=c(1,NA,NA), lwd=c(4,NA,NA), pch=c(NA,pch_DA,pch_NI), bty="n", col=c("grey90",1,1))
#legend("topright", legend=EXPECTED_NUM_EVENTS, title="E(S)", fill=colors, bty="n", border=NA)
legend("topright", legend=c("posterior","prior"), lty=c(1,2), lwd=c(4,4), bty="n", col=c("black","grey90"))

dev.off()






# sd speciation rate
sd_density = density(speciation_sd)

ylim = c(0, tail(pretty(max(sd_density$y)), 1))
xlim = c(1E-10,4*H)

pdf("../figures/hyperprior_sd.pdf", height=5)
par(mar=c(5,5,3,5), lend=2)

plot(0, ylim=ylim, xlim=xlim, type="n", xaxt="n", yaxt="n", bty="n", xlab="standard deviation speciation rate", ylab="probability density")

lines(sd_density, col="black", lwd=4)
curve(dexp(x,1.0/H), col="grey90", lty=2, lwd=4, add=TRUE)

box()
axis(1, lwd.tick=1, lwd=0)
axis(2, lwd.tick=1, lwd=0, las=1)

legend("topright", legend=c("posterior","prior"), lty=c(1,2), lwd=c(4,4), bty="n", col=c("black","grey90"))

dev.off()






# sd speciation rate
shift_rate_density = density(shift_rate)

ylim = c(0, tail(pretty(max(shift_rate_density$y)), 1))
#ylim = c(0, tail(pretty(max(prior_density$y)), 1))
#xlim = range(pretty(prior_density$x))
xlim = c(1E-10,100/TL)

pdf("../figures/hyperprior_shift_rate.pdf", height=5)
par(mar=c(5,5,3,5), lend=2)

plot(0, ylim=ylim, xlim=xlim, type="n", xaxt="n", yaxt="n", bty="n", xlab="E(S)", ylab="probability density")

lines(shift_rate_density, col="black", lwd=4)
curve(dunif(x,0,100/TL), col="grey90", lty=2, lwd=4, add=TRUE)

box()
axis(1, lwd.tick=1, lwd=0, at=seq(0,100,by=10)/TL, labels=seq(0,100,by=10))
axis(2, lwd.tick=1, lwd=0, las=1)

legend("topright", legend=c("posterior","prior"), lty=c(1,2), lwd=c(4,4), bty="n", col=c("black","grey90"))

dev.off()







pdf("../figures/hyperprior.pdf", height=2.75, width=3.25 * 3)
layout_mat = matrix(1:3, nrow=1)
layout(layout_mat)

#par(mar=c(5,5,3,5), lend=2)
m = 4
par(mar=c(m,m,0,m), oma=c(0.5,0.5,0.5,0))

ylim = c(0, tail(pretty(max(speciation_density$y)), 1))
xlim = c(1E-6,1.2)



plot(0, ylim=ylim, xlim=xlim, type="n", xaxt="n", yaxt="n", bty="n", xlab="mean speciation rate", ylab="probability density")

lines(speciation_density, col="black", lwd=4)
curve(dunif(x,0,100), col="grey90", lty=2, lwd=4, add=TRUE)

box()
axis(1, lwd.tick=1, lwd=0)
axis(2, lwd.tick=1, lwd=0, las=1)




ylim = c(0, tail(pretty(max(sd_density$y)), 1))
xlim = c(1E-10,4*H)
plot(0, ylim=ylim, xlim=xlim, type="n", xaxt="n", yaxt="n", bty="n", xlab="standard deviation speciation rate", ylab="probability density")

lines(sd_density, col="black", lwd=4)
curve(dexp(x,1.0/H), col="grey90", lty=2, lwd=4, add=TRUE)

box()
axis(1, lwd.tick=1, lwd=0)
axis(2, lwd.tick=1, lwd=0, las=1)

#legend("topright", legend=c("posterior","prior"), lty=c(1,2), lwd=c(4,4), bty="n", col=c("black","grey90"))



ylim = c(0, tail(pretty(max(shift_rate_density$y)), 1))
xlim = c(1E-10,100/TL)
plot(0, ylim=ylim, xlim=xlim, type="n", xaxt="n", yaxt="n", bty="n", xlab="E(S)", ylab="probability density")

lines(shift_rate_density, col="black", lwd=4)
curve(dunif(x,0,100/TL), col="grey90", lty=2, lwd=4, add=TRUE)

box()
axis(1, lwd.tick=1, lwd=0, at=seq(0,100,by=10)/TL, labels=seq(0,100,by=10))
axis(2, lwd.tick=1, lwd=0, las=1)

legend("topright", legend=c("posterior","prior"), lty=c(1,2), lwd=c(4,4), bty="n", col=c("black","grey90"))

dev.off()


