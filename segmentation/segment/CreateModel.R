args <- commandArgs(TRUE)
setwd(args[[1]])
library('ada')
d<-read.csv(args[[2]])
d$MeanIntensity <- d$Intensity / d$Area

f <- formula(paste(args[[3]], " ~ Area + MajorAxisLength + MinorAxisLength +
						 		  Eccentricity + ConvexArea + FilledArea + 
						 		  EulerNumber + EquivDiameter + Solidity +
						 		  Perimeter + Intensity + MeanIntensity"))

model <- ada(f,
			 data=d,
			 iter=100,
			 type="discrete",
			 control=rpart.control(maxdepth=8))

save(model, file=args[[4]])
