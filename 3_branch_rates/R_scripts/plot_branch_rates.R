library(plyr)
library(data.table)
library(ggplot2)

#set taxa and number of finite rate category models to read in
#script will automatically include FRCBD, FRCBD_stoch_char_map, and CBDSP

taxa <- c("primates")
#taxa <- c("cetaceans")
cate <- c(2,4,6,8,10)
#cate <- c(2,4,6,8)
#cate <- c(2)
numtaxa <- c(66,87,492,367)

#read in log files
data <- list()

for (t in taxa) {
  for (n in seq_along(cate)) {
    data[[paste(t,"_FRCBD_",cate[n],sep = "")]] <- fread(file = paste("output/",t,"_FRCBD_",cate[n],".log",sep = ""), header = TRUE, check.names = FALSE, data.table = FALSE)
    data[[paste(t,"_FRCBD_cm_",cate[n],sep = "")]] <- fread(file = paste("output/",t,"_FRCBD_stoch_char_map_",cate[n],".log",sep = ""), header = TRUE, check.names = FALSE, data.table = FALSE)
  }
}

scripts <- c("_FRCBD_","_FRCBD_cm_")

#convert raw data into only speciation parameters
for (t in taxa) {
  
  for (s in scripts) {
  
    namelist <- list()
    namevec <- c()
    
      for (n in cate) {
        columns <- colnames(data[[paste(t,s,n,sep = "")]])
        indices <- grepl("avg_lambda",columns)
        nsamples <- length(data[[paste(t,s,n,sep = "")]][,1])
        assign(paste(t,s,n,"_means",sep = ""),colMeans(data[[paste(t,s,n,sep = "")]][round(0.25*nsamples):nsamples,indices]))
        namevec <- append(namevec,paste(t,s,n,"_means",sep = ""))
        namelist <- append(namelist,paste(t,s,n,"_means",sep = ""))
      }
    
    assign(paste(t,s,"data",sep = ""),do.call(rbind,mget(namevec)))
    do.call(rm,namelist)
  }
  
}

rm(namelist,columns,indices,n,namevec,nsamples,s,t)


scripts <- c("_FRCBD_","_FRCBD_cm_")


for (t in taxa) {

    branch_samples <- as.data.frame(list(cat=c(),DA=c(),SCM=c(),branch=c()))
    for (n in cate) {

        samples_cat <- list(cat=c(),DA=c(),SCM=c(),branch=c())
        
        fn <- paste0(t,"_FRCBD_",n)
        columns <- colnames(data[[fn]])
        indices <- grepl("avg_lambda",columns)
        nsamples <- length(data[[fn]][,1])
        samples_cat[["DA"]] <- as.numeric(colMeans(data[[fn]][round(0.25*nsamples):nsamples,indices]))
        n_branches <- length(samples_cat[["DA"]])
        samples_cat[["branch"]] <- columns[indices]
        samples_cat[["cat"]]    <- rep(as.factor(n),n_branches)
        
        fn <- paste0(t,"_FRCBD_cm_",n)
        columns <- colnames(data[[fn]])
        indices <- grepl("avg_lambda",columns)
        nsamples <- length(data[[fn]][,1])
        samples_cat[["SCM"]] <- as.numeric(colMeans(data[[fn]][round(0.25*nsamples):nsamples,indices]))[1:n_branches]

        
        branch_samples <- rbind(branch_samples,as.data.frame(samples_cat))
  
        rm(columns,indices,nsamples,n_branches,fn)
        
    }

    p0 = ggplot(branch_samples, aes(x=SCM, y=DA, color=cat, shape=cat), alpha = 0.4) + 
         geom_point(size=5, alpha = 0.4) + 
         geom_abline(intercept = 0) +
         xlab("Stochastic Character Mapping") + 
         ylab("Data Augmentation") +
         labs(title="Branch-specific Speciation Rate Estimates",x="Stochastic Character Mapping",y="Data Augmentation") +
         theme(legend.position = c(0.1, 0.85), 
               panel.background = element_blank(), 
               panel.grid.major = element_blank(), 
               panel.grid.minor = element_blank(), 
               axis.line = element_line(colour = "black"),
               axis.text=element_text(size=12,face="bold"),
               axis.title=element_text(size=14,face="bold"),
               plot.title = element_text(size=16,face="bold"))
#     theme(legend.position = c(0.1, 0.85), panel.background = element_blank()) + 
#     theme(legend.position = c(0.1, 0.85)) + 
#     theme_bw(legend.position = c(0.1, 0.85))

    ggsave(filename=paste0("../figures/branch_rates_",t,".pdf"), plot=p0)
    dev.off()
        

}



