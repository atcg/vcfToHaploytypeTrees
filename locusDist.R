library(SNPRelate)


args = commandArgs(trailingOnly=TRUE)

metaz <- read.csv("HSEM031-040_samplesNoF1F2NoPCoutliers_fullMeta_noMammothSiskiyouNoCattleTank", sep="\t", header=T)



genofile <- snpgdsOpen(args[1])
pcaz <- snpgdsPCA(genofile, autosome.only=F)

metazRed <- metaz[!is.na(match(metaz$Individual, pcaz$sample.id)),]
ibs.hc <- snpgdsHCluster(snpgdsIBS(genofile, sample.id=pcaz$sample.id[match(metazRed$Individual, pcaz$sample.id)]))

# Color dots by GVGSP, 5*FF, or other
ibs.hc.cut <- snpgdsCutTree(ibs.hc, samp.group=as.factor(metaz$Color[match(pcaz$sample.id[match(metazRed$Individual, pcaz$sample.id)], metaz$Individual)]))
race <- as.factor(metaz$Color[match(pcaz$sample.id[match(metazRed$Individual, pcaz$sample.id)], metaz$Individual)])


png(args[2], width=1000, height=500, units=px)
plot(ibs.hc.cut$dendrogram, leaflab="none")
legend("topright", legend=levels(race), col=1:nlevels(race), pch=19, ncol=4)
dev.off()
