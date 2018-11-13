files = list.files("likelihoods", full.names=TRUE)

methods = c("BDP","DA","SCM")
pairs   = t(combn(methods, 2))

pdf("../figures/likelihoods_over_datasets.pdf", width=3, height=50)

par(mfrow=c(length(files),1))

for(i in 1:length(files)) {

  this_file = files[i]

  dataset = gsub(".csv","",tail(strsplit(this_file,"/")[[1]],1))

  liks = read.table(this_file, header=TRUE, sep="\t")

  lim = range(liks[,2:4], na.rm=TRUE)

  plot(NA, ylim=lim, xlim=lim, type="n", xlab=NA, ylab=NA, main=dataset)
  abline(a=0, b=1, lwd=2, col="grey")

  for(j in 1:nrow(pairs)) {
    ind = seq(1, nrow(liks), 10 * nrow(pairs))
    points(liks[ind,pairs[j,1]], liks[ind,pairs[j,2]], type="p", pch=j, cex=1.0, col=j+1)
  }
  legend("bottomright", legend=paste0(pairs[,1]," vs. ", pairs[,2]), col=2:4, pch=1:3, bty="n")

}
dev.off()