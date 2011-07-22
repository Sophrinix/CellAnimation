args <- commandArgs(TRUE)

setwd(args[[1]])
library('ada')
d <- read.csv(args[[2]])
d$MeanIntensity <- d$Intensity / d$Area
load(paste("model", args[[3]], ".Rdata", sep=""));

output <- predict(model, newdata=d)

write.csv(output, file=paste(args[[3]],".csv", sep=""))
