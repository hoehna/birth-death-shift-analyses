library(coda)
library(ggplot2)

NUM_REPS = 1000

coverage_probs = data.frame(total_count=numeric(0), in_count=numeric(0), hpd_width=numeric(0), stringsAsFactors=FALSE)
hpd_width = seq(from=0.0, to=1.0, by=0.05)
for (i in 1:21) {
    coverage_probs[i,] = c(total_count=0, in_count=0, hpd_width=hpd_width[i])
}

pb <- txtProgressBar(min = 0, max = NUM_REPS, style = 3)

for (i in 1:NUM_REPS) {

    setTxtProgressBar(pb, i)

    in_file = paste0("output_prior/", i, ".log")
    if ( file.exists(in_file) == FALSE ) next
    data = read.table(in_file, sep="\t", header=TRUE, skip=0)

    for (j in 1:398) {
    
        column = paste0("relative_error.", j, ".")
        
        x = as.mcmc(data[,column])
        for (k in 1:21) {
            hpd = HPDinterval(x, prob=hpd_width[k])
            if (0 >= round(hpd[1,1], 2) && 0 <= round(hpd[1,2], 2)) {
                coverage_probs[k,]$in_count = coverage_probs[k,]$in_count + 1
            }
            coverage_probs[k,]$total_count = coverage_probs[k,]$total_count + 1
        }
    }   
}

close(pb)

coverage_probs$freq = coverage_probs$in_count / coverage_probs$total_count

p = ggplot(coverage_probs) +
    geom_bar(stat="identity", aes(x=hpd_width, y=freq), colour="lightgray", fill="lightgray") +
    theme_classic() +
    xlab("HPD width") + ylab("coverage probability") +
    geom_segment(aes(x=0, y=0, xend=1, yend=1), linetype="dashed", size = 1.5, show.legend=FALSE) +
    theme(legend.position="none")
ggsave("../figures/hpd_width_vs_coverage.pdf", width=10, height=10, units="cm")
