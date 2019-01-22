# setwd("~/repos/revbayes_birth-death-shift/analysis/ess_tests/")

library(ape)
library(parallel)
library(coda)
library(viridis)

colors = viridis(3, begin=0.3, end=0.9)[c(2,1)]

burnin = 0.25

######################
# read the job table #
######################

# job_table = read.table("src/job_table.tsv", header=TRUE, sep="\t", stringsAsFactors=FALSE, check.names=FALSE)

#####################
# make the analyses #
#####################

# experiment 1: iterating over num_cats

DATASET             = c("primates")
NUM_RATE_CATEGORIES = c(2, 4, 6, 8, 10)
EXPECTED_NUM_EVENTS = c(10)
INT_METHOD          = c("numerical_integration","data_augmentation")

grid_1 = expand.grid(EXPECTED_NUM_EVENTS = EXPECTED_NUM_EVENTS,
                     NUM_RATE_CATEGORIES = NUM_RATE_CATEGORIES,
                     INT_METHOD          = INT_METHOD,
                     DATASET             = DATASET,
                     stringsAsFactors    = FALSE)

# experiment 2: iterating over expected number of shifts

DATASET             = c("primates")
NUM_RATE_CATEGORIES = c(4)
EXPECTED_NUM_EVENTS = c(1, 10, 20)
INT_METHOD          = c("numerical_integration","data_augmentation")

grid_2 = expand.grid(EXPECTED_NUM_EVENTS = EXPECTED_NUM_EVENTS,
                     NUM_RATE_CATEGORIES = NUM_RATE_CATEGORIES,
                     INT_METHOD          = INT_METHOD,
                     DATASET             = DATASET,
                     stringsAsFactors    = FALSE)

# experiment 3: try different empirical datasets

DATASET             = c("byttneria", "conifers", "primates", "ericaceae", "viburnum", "cetaceans")
NUM_RATE_CATEGORIES = c(4)
EXPECTED_NUM_EVENTS = c(10)
INT_METHOD          = c("numerical_integration","data_augmentation")

grid_3 = expand.grid(EXPECTED_NUM_EVENTS = EXPECTED_NUM_EVENTS,
                     NUM_RATE_CATEGORIES = NUM_RATE_CATEGORIES,
                     INT_METHOD          = INT_METHOD,
                     DATASET             = DATASET,
                     stringsAsFactors    = FALSE)

# combine the experiments
grid = rbind(grid_1, grid_2, grid_3)

# remove non-unique analyses
grid = unique(grid)

if ( file.exists( "ESS_summary.Rda" ) == FALSE ) {

summary = do.call(rbind,mclapply(1:nrow(grid), function(x) {

   # setTxtProgressBar(bar, i / nrow(grid))
   # i <<- i + 1

   # get the variables

   row = grid[x,]

   cat(x,"\n")

   D = row["DATASET"]
   N = as.numeric(row["NUM_RATE_CATEGORIES"])
   E = as.numeric(row["EXPECTED_NUM_EVENTS"])
   I = row["INT_METHOD"]

  if ( I == "data_augmentation" ) {

    file_name       = paste0("output/",D,"_FRCBD_",N,"_",E,".log")
    sceen_log_file  = paste0("screen_log/",D,"_FRCBD_",N,"_",E,".out")

  } else {

    file_name       = paste0("output/",D,"_FRCBD_stoch_char_map_",N,"_",E,".log")
    sceen_log_file  = paste0("screen_log/",D,"_FRCBD_char_mapping_",N,"_",E,".out")

  }

   if ( file.exists(file_name) == FALSE ) {
       cat("File not found!\t\t\t",file_name,"\n")
       return(NULL)
   }

   # read the output file
   samples = read.table(file_name, header=TRUE, stringsAsFactors=FALSE, sep="\t", check.names=FALSE)

   # discard burnin
   samples = samples[-c(1:floor(burnin * nrow(samples))),]

   if ( file.exists(sceen_log_file) == FALSE ) {
       cat("File not found!\t\t\t",sceen_log_file,"\n")
       return(NULL)
   }
   
   # # get the screen log
   screen_log      = readLines(sceen_log_file)
   screen_log_tail = tail(screen_log)


   # determine if the run finished
   run_finished = any(grepl("Processing of file", screen_log_tail))

   # get the run time
   if ( run_finished == TRUE ) {
     last_line = grep("10000", screen_log_tail, value=TRUE)
   } else {
     last_line = tail(screen_log_tail, 1)
   }
   run_time   = gsub(" ","",strsplit(last_line,"\\|")[[1]][5])
   seconds    = sum(as.numeric(strsplit(run_time,":")[[1]]) * c(3600, 60, 1))
   num_cycles = as.numeric(gsub(" ","",strsplit(last_line,"\\|")[[1]][1]))

   # compute the ESS scores
   branch_rates = samples[,grepl("avg_lambda", colnames(samples))]

   # remove the root rate, if it is present
   if ( I == "numerical_integration" ) {
     branch_rates = branch_rates[,-ncol(branch_rates)]
   }

   branch_rate_ess = effectiveSize(branch_rates)

   # remove branches that never change categories
   branch_rate_ess = branch_rate_ess[branch_rate_ess != 0]

   # compute the relevant ESS summaries
   min_ESS  = min(branch_rate_ess)
   mean_ESS = mean(branch_rate_ess)

   res = data.frame(EXPECTED_NUM_EVENTS = E,
                    NUM_RATE_CATEGORIES = N,
                    INT_METHOD          = I,
                    DATASET             = D,
                    min_ESS             = min_ESS,
                    mean_ESS            = mean_ESS,
                    run_time            = seconds,
                    num_cycles          = num_cycles,
                    run_finished        = run_finished,
                    stringsAsFactors    = FALSE)

   return(res)

 }, mc.cores=4, mc.preschedule=FALSE))

save(summary, file="ESS_summary.Rda")

} else {

    load("ESS_summary.Rda")

}

summary$min_ESS_per_second  = summary$min_ESS  / summary$run_time
summary$mean_ESS_per_second = summary$mean_ESS / summary$run_time
summary$min_ESS_per_cycle   = summary$min_ESS  / summary$num_cycles
summary$mean_ESS_per_cycle  = summary$mean_ESS / summary$num_cycles

#####################################################
# normalize by the mean ESS under data augmentation #
#####################################################

DATASET = "primates"

rescaled_min  = numeric(nrow(summary))
rescaled_mean = numeric(nrow(summary))

for(i in 1:nrow(summary)) {
  
  N = summary[i,]$NUM_RATE_CATEGORIES
  E = summary[i,]$EXPECTED_NUM_EVENTS
  
  const = mean(summary[summary$EXPECTED_NUM_EVENTS == E & summary$NUM_RATE_CATEGORIES == N & summary$DATASET == DATASET & summary$INT_METHOD == "data_augmentation",]$min_ESS_per_second)

  rescaled_min[i]  = summary[i,]$min_ESS_per_second / const
  rescaled_mean[i] = summary[i,]$mean_ESS_per_second / const
  
}

summary$min_ESS_per_second  = rescaled_min
summary$mean_ESS_per_second = rescaled_mean



#################################
# ESS as a function of num_cats #
#################################

range = range(pretty(c(summary$min_ESS_per_second, summary$mean_ESS_per_second)))
range = range(pretty(c(summary$min_ESS_per_second)))

# plot the ESS per second as a function of the number of discrete rate categories

DATASET             = "primates"
EXPECTED_NUM_EVENTS = 10
NUM_RATE_CATEGORIES = c(2, 4, 6, 8, 10)

summary_num_cats = summary[summary$DATASET == DATASET & summary$EXPECTED_NUM_EVENTS == EXPECTED_NUM_EVENTS,]

summary_num_cats_data_augmentation = summary_num_cats[summary_num_cats$INT_METHOD == "data_augmentation",]

num_cats_min_ess_data_augmentation = sapply(split(summary_num_cats_data_augmentation, list(summary_num_cats_data_augmentation$NUM_RATE_CATEGORIES)), function(x){
  mean(x$min_ESS_per_second)
})

num_cats_mean_ess_data_augmentation = sapply(split(summary_num_cats_data_augmentation, list(summary_num_cats_data_augmentation$NUM_RATE_CATEGORIES)), function(x){
  mean(x$mean_ESS_per_second)
})

summary_num_cats_numerical_integration = summary_num_cats[summary_num_cats$INT_METHOD == "numerical_integration",]

num_cats_min_ess_numerical_integration = sapply(split(summary_num_cats_numerical_integration, list(summary_num_cats_numerical_integration$NUM_RATE_CATEGORIES)), function(x){
  mean(x$min_ESS_per_second)
})

num_cats_mean_ess_numerical_integration = sapply(split(summary_num_cats_numerical_integration, list(summary_num_cats_numerical_integration$NUM_RATE_CATEGORIES)), function(x){
  mean(x$mean_ESS_per_second)
})

###################################
# ESS as a function of event_rate #
###################################

DATASET             = "primates"
EXPECTED_NUM_EVENTS = c(1,10,20)
NUM_RATE_CATEGORIES = 4

summary_event_rate = summary[summary$DATASET == DATASET & summary$NUM_RATE_CATEGORIES == NUM_RATE_CATEGORIES,]

summary_event_rate_data_augmentation = summary_event_rate[summary_event_rate$INT_METHOD == "data_augmentation",]

event_rate_min_ess_data_augmentation = sapply(split(summary_event_rate_data_augmentation, list(summary_event_rate_data_augmentation$EXPECTED_NUM_EVENTS)), function(x){
  mean(x$min_ESS_per_second)
})

event_rate_mean_ess_data_augmentation = sapply(split(summary_event_rate_data_augmentation, list(summary_event_rate_data_augmentation$EXPECTED_NUM_EVENTS)), function(x){
  mean(x$mean_ESS_per_second)
})

summary_event_rate_numerical_integration = summary_event_rate[summary_event_rate$INT_METHOD == "numerical_integration",]

event_rate_min_ess_numerical_integration = sapply(split(summary_event_rate_numerical_integration, list(summary_event_rate_numerical_integration$EXPECTED_NUM_EVENTS)), function(x){
  mean(x$min_ESS_per_second)
})

event_rate_mean_ess_numerical_integration = sapply(split(summary_event_rate_numerical_integration, list(summary_event_rate_numerical_integration$EXPECTED_NUM_EVENTS)), function(x){
  mean(x$mean_ESS_per_second)
})

################################
# ESS as a function of dataset #
################################

DATASET             = c("byttneria", "conifers", "primates", "ericaceae", "viburnum", "cetaceans")
EXPECTED_NUM_EVENTS = 10
NUM_RATE_CATEGORIES = 4

# compute the number of taxa
n_taxa = numeric()
for(i in 1:length(DATASET)) {

  D = DATASET[i]

  tree = try(read.tree(paste0("../data/",D,".tre")), silent=TRUE)
  if ( class(tree) == "try-error" ) {
    tree = try(read.nexus(paste0("../data/",D,".tre")), silent=TRUE)
  }

  n_taxa[i] = length(tree$tip.label)

}
names(n_taxa) = DATASET
n_taxa = sort(n_taxa)

summary_dataset = summary[summary$EXPECTED_NUM_EVENTS == EXPECTED_NUM_EVENTS & summary$NUM_RATE_CATEGORIES == NUM_RATE_CATEGORIES,]

summary_dataset_data_augmentation = summary_dataset[summary_dataset$INT_METHOD == "data_augmentation",]

dataset_min_ess_data_augmentation = sapply(split(summary_dataset_data_augmentation, list(summary_dataset_data_augmentation$DATASET)), function(x){
  mean(x$min_ESS_per_second)
})
dataset_min_ess_data_augmentation = dataset_min_ess_data_augmentation[names(n_taxa)]

dataset_mean_ess_data_augmentation = sapply(split(summary_dataset_data_augmentation, list(summary_dataset_data_augmentation$DATASET)), function(x){
  mean(x$mean_ESS_per_second)
})
dataset_mean_ess_data_augmentation = dataset_mean_ess_data_augmentation[names(n_taxa)]

summary_dataset_numerical_integration = summary_dataset[summary_dataset$INT_METHOD == "numerical_integration",]

dataset_min_ess_numerical_integration = sapply(split(summary_dataset_numerical_integration, list(summary_dataset_numerical_integration$DATASET)), function(x){
  mean(x$min_ESS_per_second)
})
dataset_min_ess_numerical_integration = dataset_min_ess_numerical_integration[names(n_taxa)]

dataset_mean_ess_numerical_integration = sapply(split(summary_dataset_numerical_integration, list(summary_dataset_numerical_integration$DATASET)), function(x){
  mean(x$mean_ESS_per_second)
})
dataset_mean_ess_numerical_integration = dataset_mean_ess_numerical_integration[names(n_taxa)]

############################
# plot everything together #
############################

dataset_min_ess_numerical_integration = dataset_min_ess_numerical_integration/dataset_min_ess_data_augmentation
dataset_min_ess_data_augmentation     = dataset_min_ess_data_augmentation/dataset_min_ess_data_augmentation

range = c(0,max(dataset_min_ess_numerical_integration,num_cats_min_ess_numerical_integration,event_rate_min_ess_numerical_integration))

DATASET             = c("byttneria", "conifers", "primates", "ericaceae", "viburnum", "cetaceans")
EXPECTED_NUM_EVENTS = c(1,10,20)
NUM_RATE_CATEGORIES = c(2, 4, 6, 8, 10)

pch_DA = 3
pch_NI = 4
colors = viridis(3, begin=0.3, end=0.9)[c(2,1)]

pdf("../figures/ESS_comparison.pdf", height=3.5, width=8)

par(mfrow=c(1,3), mar=c(7,0,0.2,0.5), oma=c(0,5,3,0))

plot(NUM_RATE_CATEGORIES, NUM_RATE_CATEGORIES, type="n", xlab=NA, ylab=NA, xaxt="n", yaxt="n", ylim=range, log="")

points(NUM_RATE_CATEGORIES, num_cats_min_ess_data_augmentation,     pch=pch_DA)
points(NUM_RATE_CATEGORIES, num_cats_min_ess_numerical_integration, pch=pch_NI)

axis(1, lwd.ticks=1, lwd=0)
axis(2, lwd.ticks=1, lwd=0, las=1)
mtext(side=1, text="number of categories", line=3, cex=0.8)
mtext(side=3, text="primates, E(S) = 10", line=1, cex=0.8)
mtext(side=2, text="ESS (numerical integration) / ESS (data augmentation)", line=3, cex=0.7)


plot(EXPECTED_NUM_EVENTS, EXPECTED_NUM_EVENTS, type="n", xlab=NA, ylab=NA, xaxt="n", yaxt="n", ylim=range)

points(EXPECTED_NUM_EVENTS, event_rate_min_ess_data_augmentation,    pch=pch_DA)
points(EXPECTED_NUM_EVENTS, event_rate_min_ess_numerical_integration, pch=pch_NI)

axis(1, at=EXPECTED_NUM_EVENTS, lwd.ticks=1, lwd=0)
mtext(side=1, text="E(S)", line=3, cex=0.8)
mtext(side=3, text="primates, N = 4", line=1, cex=0.8)

plot(1:length(DATASET), 1:length(DATASET), type="n", xlab=NA, ylab=NA, xaxt="n", yaxt="n", ylim=range, log="")

points(1:length(DATASET), dataset_min_ess_data_augmentation,     pch=pch_DA)
points(1:length(DATASET), dataset_min_ess_numerical_integration/dataset_min_ess_data_augmentation, pch=pch_NI)

axis(1, at=1:length(n_taxa), labels=paste0(names(n_taxa),"\n(", n_taxa,")"), lwd.ticks=1, lwd=0, las=2)
mtext(side=3, text="E(S) = 10, N = 4", line=1, cex=0.8)
mtext(side=1, text="dataset", line=5.5, adj=0.5, cex=0.8)

dev.off()


