args <- commandArgs(TRUE)

setwd(args[[1]])
library('ada')
d <- read.csv(args[[2]])
d$MeanIntensity <- d$Intensity / d$Area
load(args[[3]])
model
d$nucleus <- predict(model, newdata=d)

write.csv(d, file=args[[2]])

