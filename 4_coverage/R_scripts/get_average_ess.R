library(coda)

ess_values = vector()

for (i in 1:100) {

    in_file = paste("output/", i, ".log", sep="")
    data = read.table(in_file, sep="\t", header=TRUE, skip=0)

    x = as.mcmc(data$Posterior)
    ess_values = c(ess_values, effectiveSize(x))

}

print(mean(ess_values))

