library(ggtree)
library(ggplot2)
library(tidytree)
library(treeio)
library(gridExtra)
library(ape)
# library(viridis)
source("R_scripts/utility_functions.R")

H = 0.587405

# settings
DATASET             = c("primates")
NUM_RATE_CATEGORIES = 10
EXPECTED_NUM_EVENTS = c(1, 10, 20)


# read the posterior distributions
branch_lambdas = vector("list", length(EXPECTED_NUM_EVENTS))
for(i in 1:length(EXPECTED_NUM_EVENTS)) {

  E = EXPECTED_NUM_EVENTS[i]

  cat(E,"\t")

  file = paste0("output/",DATASET,"_FRCBD_rates_num_cats_",NUM_RATE_CATEGORIES,"_num_events_",E,".log")
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


################
# tree figures #
################

# read the tree
tree = try(read.tree(paste0("../data/",DATASET,".tre")), silent=TRUE)
if ( class(tree) == "try-error"  ) {
  tree = try(read.nexus(paste0("../data/",DATASET,".tre")), silent=TRUE)
}
map = matchNodes(tree)

#as.treedata.phylo(tree)
#read.beast(paste0("../data/",DATASET,".tre"))

# compute the intervals
lambda_intervals = pretty(unlist(branch_lambdas), n=1001)
# lambda_colors = viridis(length(lambda_intervals))

tree_tbl = as_data_frame(tree)


# compute the legend
legend_intervals = pretty(lambda_intervals)
legend_intervals = legend_intervals[legend_intervals > min(lambda_intervals) & legend_intervals < max(lambda_intervals)]
legend_intervals_at = (legend_intervals - min(lambda_intervals)) / diff(range(lambda_intervals))

# make the directory
dir = paste0("../figures/")
#dir.create(dir, recursive=TRUE)

plots = vector("list", length(EXPECTED_NUM_EVENTS))

# for the speciation rate
for(i in 1:length(EXPECTED_NUM_EVENTS)) {

  # get the branch rates
  these_lambdas = branch_lambdas[[i]]
  these_lambdas = these_lambdas[paste0("avg_lambda[",map$Rev[match(tree$edge[,2], map$R)],"]")]

  lambda_tree = tree
  lambda_tree$edge.length = these_lambdas
  lambda_tbl = as_data_frame(lambda_tree)
  
  tree_tbl  = as_data_frame(tree)
  tree_tbl$rates = lambda_tbl$branch.length
  
  this_tree = as.treedata(tree_tbl)
  
  if (i == 1) {
    plots[[i]] = ggtree(this_tree, aes(color=rates)) + scale_color_continuous("branch-specific speciation rate", low="blue", high="orange", limits=range(lambda_intervals)) + theme(legend.position=c(0.4,0.85), legend.background=element_blank()) + ggtitle(paste0("E(S) = ",EXPECTED_NUM_EVENTS[i])) + theme(plot.title = element_text(lineheight=.8, face="bold", hjust = 0.5))
    # ggtree(this_tree, aes(color=rates)) + scale_color_continuous("branch-specific speciation rate", low="blue", high="orange", limits=range(lambda_intervals)) + theme(legend.position=c(0.2,0.8), legend.background=element_blank()) + ggtitle(paste0("E(S) = ",EXPECTED_NUM_EVENTS[i])) + theme(plot.title = element_text(lineheight=.8, face="bold", hjust = 0.5))
  } else {
    plots[[i]] = ggtree(this_tree, aes(color=rates)) + scale_color_continuous("branch-specific speciation rate", low="blue", high="orange", limits=range(lambda_intervals)) + ggtitle(paste0("E(S) = ",EXPECTED_NUM_EVENTS[i])) + theme(plot.title = element_text(lineheight=.8, face="bold", hjust = 0.5))
  }
    
}

this_fig = paste0(dir,"/branch_speciation_rates_tree.pdf")
pdf(this_fig, height=6, width=10)

grid.arrange(plots[[1]], plots[[2]], plots[[3]], layout_matrix=matrix(1:3, nrow=1))

dev.off()























