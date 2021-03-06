library(R2jags)
load.module("glm") #improves performance

#inputdata <- read.table("darin_hkeasy.txt", header=T)
#inputdata <- read.table("darin_exopops.txt", header=T)
inputdata <- read.table("tom_hk.txt", header=T)
#inputdata
Ndata <- length(inputdata$H_OBS)

ecc_mixture_cont <- function() {
alpha <- 2.0
sigmae ~ dunif(0.,1.)
for (i in 1:Ndata) { 
 lambda[i] ~ dgamma(alpha/2,alpha/2)
 h[i] ~ dnorm(0.0,lambda[i]/(sigmae*sigmae)) %_% T(-1,1) 
 k[i] ~ dnorm(0.0,lambda[i]/(sigmae*sigmae)) %_% T(-1,1)
 hhat[i] ~ dnorm(h[i],1.0/(sigmahobs[i]*sigmahobs[i])) %_% T(-1,1)
 khat[i] ~ dnorm(k[i],1.0/(sigmakobs[i]*sigmakobs[i])) %_% T(-1,1)
 }
}
model.file = "ecc_heir_cont.txt"
write.model(ecc_mixture_cont, model.file)
#file.show(model.file)

inits = NULL  # initial values

data = list(hhat=inputdata$H_OBS,khat=inputdata$K_OBS,sigmahobs=inputdata$H_SIGMA,sigmakobs=inputdata$K_SIGMA,Ndata=Ndata)
parameters.to.save = c("h", "k", "sigmae","lambda")

sim = jags(data, inits, parameters.to.save, model.file=model.file, n.chains=2, n.iter=100)

#print(sim)
#plot(sim)

colnames(sim$BUGSoutput$sims.matrix)
hist(sim$BUGSoutput$sims.matrix[,"h[1]"], prob=T, breaks=20)
hfirstcol = 2
hlastcol = hfirstcol + length(inputdata$H_OBS)-1
hpred <- sim$BUGSoutput$sims.matrix[,hfirstcol:hlastcol]
hist(hpred, prob=T, breaks=20)
hist(inputdata$H_TRUE, breaks=20)
kfirstcol = hlastcol + 1
klastcol = kfirstcol + length(inputdata$K_OBS)-1
kpred <- sim$BUGSoutput$sims.matrix[,kfirstcol:klastcol]
hist(kpred, prob=T, breaks=20)
hist(inputdata$K_TRUE, breaks=20)

epred <- sqrt(hpred^2+kpred^2)
hist(epred, prob=T, breaks=20)
hist(sqrt(inputdata$H_TRUE^2+inputdata$K_TRUE^2), breaks=20)

sigmae_post <- sim$BUGSoutput$sims.matrix[,"sigmae"]
hist(sigmae_post, prob=T, breaks=20)





hist(inputdata$H_TRUE, prob=T, breaks=20)
colnames(sim$BUGSoutput$sims.matrix)
#hist(sim$BUGSoutput$sims.matrix[,"h[1]"], prob=T, breaks=20)
hfirstcol = 2
hlastcol = hfirstcol + length(inputdata$H_OBS)-1
hist(sim$BUGSoutput$sims.matrix[,hfirstcol:hlastcol], prob=T, breaks=20)

hist(sim$BUGSoutput$sims.matrix[,"sigmae"], prob=T, breaks=20)
