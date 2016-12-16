library(SNPRelate)

args = commandArgs(trailingOnly=TRUE)

snpgdsVCF2GDS(args[1], args[2], method="biallelic.only")
genofile <- snpgdsOpen(args[2])
pcaz <- snpgdsPCA(genofile, autosome.only=F)

metaz <- read.csv("HSEM031-040_samplesNoF1F2NoPCoutliers_fullMeta_noMammothSiskiyouNoCattleTank", sep="\t", header=T)

png(args[3])
plot(pcaz$eigenvect[,1][snpgdsSampMissRate(genofile) < 0.5], pcaz$eigenvect[,2][snpgdsSampMissRate(genofile) < 0.5], xlab=paste("PC1=", pcaz$varprop[1]*100, "%", sep=""), ylab=paste("PC2=", pcaz$varprop[2]*100, "%", sep=""),col=as.character(metaz$Color[order(as.character(metaz$Individual))])[snpgdsSampMissRate(genofile) < 0.5], pch=20)
dev.off()
