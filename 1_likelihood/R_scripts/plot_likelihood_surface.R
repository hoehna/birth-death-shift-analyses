colors = rep(1,2)

likelihoods = read.table("likelihoods/primates.csv",header=TRUE)

x_vals = likelihoods$Rel.Ext

space = 30
lwd   = 4
cex   = 0.7
pch   = c(1,3)
f     = 1.2

pdf(paste0("../figures/Likelihood_surface.pdf"),width=7.5, height=5)

par(lend=2, mar=c(5,6,0.3,0.3))
plot(x_vals, likelihoods$BDP, type="l", lwd=lwd, col="grey90", xaxt="n", yaxt="n", xlab=NA, ylab=NA)
points(x_vals[seq(1, length(x_vals), space)], y=likelihoods$DA[seq(1, length(x_vals), space)], pch=pch[1], col=colors[1], cex=cex)
points(x_vals[seq(1 + 0.5 * space, length(x_vals), space)], y=likelihoods$SCM[seq(1 + 0.5 * space, length(x_vals), space)], pch=pch[2], col=colors[2], cex=cex)
axis(1, lwd.tick=1, lwd=0)
axis(2, lwd.tick=1, lwd=0, las=2)
#xlab=, ylab="", 
mtext(side=2, text="log likelihood",  line=4.0, cex=1.4)
mtext(side=1, text="relative extinction",  line=2.5, cex=1.4)
legend("topleft", legend=c("analytical","data-augmentation","numerical integration"), bty="n", lty=c(1,NA,NA), pch=c(NA, pch[1], pch[2]), col=c("grey90",colors[1], colors[2]), lwd=c(lwd,1,1))

dev.off()

