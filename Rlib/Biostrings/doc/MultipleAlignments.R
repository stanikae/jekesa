### R code from vignette source 'MultipleAlignments.Rnw'
### Encoding: UTF-8

###################################################
### code chunk number 1: objectCreation
###################################################
library(Biostrings)
origMAlign <-
  readDNAMultipleAlignment(filepath =
                           system.file("extdata",
                                       "msx2_mRNA.aln",
                                       package="Biostrings"),
                           format="clustal")

phylipMAlign <-
  readAAMultipleAlignment(filepath =
                          system.file("extdata",
                                      "Phylip.txt",
                                      package="Biostrings"),
                          format="phylip")


###################################################
### code chunk number 2: renameRows
###################################################
rownames(origMAlign)
rownames(origMAlign) <- c("Human","Chimp","Cow","Mouse","Rat",
                          "Dog","Chicken","Salmon")
origMAlign


###################################################
### code chunk number 3: detail (eval = FALSE)
###################################################
## detail(origMAlign)


###################################################
### code chunk number 4: usingMasks
###################################################
maskTest <- origMAlign
rowmask(maskTest) <- IRanges(start=1,end=3)
rowmask(maskTest)
maskTest

colmask(maskTest) <- IRanges(start=c(1,1000),end=c(500,2343))
colmask(maskTest)
maskTest


###################################################
### code chunk number 5: nullOut masks
###################################################
rowmask(maskTest) <- NULL
rowmask(maskTest)
colmask(maskTest) <- NULL
colmask(maskTest)
maskTest


###################################################
### code chunk number 6: invertMask
###################################################
rowmask(maskTest, invert=TRUE) <- IRanges(start=4,end=8)
rowmask(maskTest)
maskTest
colmask(maskTest, invert=TRUE) <- IRanges(start=501,end=999)
colmask(maskTest)
maskTest


###################################################
### code chunk number 7: setup
###################################################
## 1st lets null out the masks so we can have a fresh start.
colmask(maskTest) <- NULL
rowmask(maskTest) <- NULL


###################################################
### code chunk number 8: appendMask
###################################################
## Then we can demonstrate how the append argument works
rowmask(maskTest) <- IRanges(start=1,end=3)
maskTest

rowmask(maskTest,append="intersect") <- IRanges(start=2,end=5)
maskTest

rowmask(maskTest,append="replace") <- IRanges(start=5,end=8)
maskTest

rowmask(maskTest,append="replace",invert=TRUE) <- IRanges(start=5,end=8)
maskTest

rowmask(maskTest,append="union") <- IRanges(start=7,end=8)
maskTest


###################################################
### code chunk number 9: maskMotif
###################################################
tataMasked <- maskMotif(origMAlign, "TATA")
colmask(tataMasked)


###################################################
### code chunk number 10: maskGaps
###################################################
autoMasked <- maskGaps(origMAlign, min.fraction=0.5, min.block.width=4)
autoMasked


###################################################
### code chunk number 11: asmatrix
###################################################
full = as.matrix(origMAlign)
dim(full)
partial = as.matrix(autoMasked)
dim(partial)


###################################################
### code chunk number 12: alphabetFreq
###################################################
alphabetFrequency(autoMasked)


###################################################
### code chunk number 13: consensus
###################################################
consensusMatrix(autoMasked, baseOnly=TRUE)[, 84:90]
substr(consensusString(autoMasked),80,130)
consensusViews(autoMasked)


###################################################
### code chunk number 14: cluster
###################################################
sdist <- stringDist(as(origMAlign,"DNAStringSet"), method="hamming")
clust <- hclust(sdist, method = "single")
pdf(file="badTree.pdf")
plot(clust)
dev.off()


###################################################
### code chunk number 15: cluster2
###################################################
sdist <- stringDist(as(autoMasked,"DNAStringSet"), method="hamming")
clust <- hclust(sdist, method = "single")
pdf(file="goodTree.pdf")
plot(clust)
dev.off()
fourgroups <- cutree(clust, 4)
fourgroups


###################################################
### code chunk number 16: fastaExample (eval = FALSE)
###################################################
## DNAStr = as(origMAlign, "DNAStringSet")
## writeXStringSet(DNAStr, file="myFile.fa")


###################################################
### code chunk number 17: write.phylip (eval = FALSE)
###################################################
## write.phylip(phylipMAlign, filepath="myFile.txt")


###################################################
### code chunk number 18: sessinfo
###################################################
sessionInfo()


