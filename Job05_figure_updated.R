setwd   #path to severity data

library(ggplot2)

bulk <- read.csv("Job04_bulk_figure.csv")
bleed<- read.csv("Job04_bleed_figure.csv")
pain <- read.csv("Job04_pain_figure.csv")

table(bulk$bulk_score_v2)
mean(bulk$C_DX_BULK)

pdf("Job05_Severity_Score_By_Diagnosis_Code_updated.pdf")

#par(mfrow=c(1,2))
par(mfrow=c(3,2))
#
#BULK SCORE
#
hist(bulk$bulk_score_v2,col=rgb(1,0,0,0.5),cex.main=0.9,main="(a) Bulk Score",xlab="Bulk Severity Score")

#Looking at Bleeding score not icluding
data_high <- subset(bulk,bulk$C_DX_BULK==1)
data_low  <- subset(bulk,bulk$C_DX_BULK==0) 
hist(data_high$bulk_score_v2,col=rgb(1,0,0,0.5),cex.main=0.9,main="(d) Bulk Score By Bulk Diagnosis Code at Surgery",xlab="Bulk Severity Score",xlim=c(0,14),ylim=c(0,1200))
hist(data_low$bulk_score_v2, col=rgb(0,0,1,0.5),add=T)
legend("topright", c("Diagnosis Code Present", "Diagnosis Code Absent"), col=c(rgb(1,0,0,0.5),rgb(0,0,1,0.5)), lwd=8)

#
#BLEEDING SCORE
#
hist(bleed$bleed_score,col=rgb(1,0,0,0.5),cex.main=0.9,main="(b) Bleeding Score",xlab="Bleeding Severity Score")

#Looking at Bleeding score not icluding
data_high <- subset(bleed,bleed$C_DX_MENORRHAGIA==1)
data_low  <- subset(bleed,bleed$C_DX_MENORRHAGIA==0)
hist(data_high$bleed_score,col=rgb(1,0,0,0.5),cex.main=0.9,main="(e) Bleeding Score By Vaginal Bleeding Diagnosis Code at Surgery",xlab="Bleeding Severity Score",ylim=c(0,1200))
hist(data_low$bleed_score, col=rgb(0,0,1,0.5),add=T)
legend("topright", c("Diagnosis Code Present", "Diagnosis Code Absent"), col=c(rgb(1,0,0,0.5),rgb(0,0,1,0.5)), lwd=8)


#
#PAIN SCORE
#
hist(pain$pain_score,col=rgb(1,0,0,0.5),cex.main=0.9,main="Pain Score",xlab="(c) Pain Severity Score",ylim=c(0,800))

#Looking at Bleeding score not icluding
data_high <- subset(pain,pain$C_DX_PAIN==1)
data_low  <- subset(pain,pain$C_DX_PAIN==0)
hist(data_high$pain_score,col=rgb(1,0,0,0.5),cex.main=0.9,main="(f) Pain Score By Pain Diagnosis Code at Surgery",xlab="Pain Severity Score",xlim=c(0,30),ylim=c(0,800))
hist(data_low$pain_score, col=rgb(0,0,1,0.5),add=T)

legend("topright", c("Diagnosis Code Present", "Diagnosis Code Absent"), col=c(rgb(1,0,0,0.5),rgb(0,0,1,0.5)), lwd=8)

dev.off()
