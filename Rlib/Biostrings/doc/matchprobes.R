### R code from vignette source 'matchprobes.Rnw'
### Encoding: UTF-8

###################################################
### code chunk number 1: startup
###################################################
library(Biostrings)
library(hgu95av2probe)
library(hgu95av2cdf)


###################################################
### code chunk number 2: matchprobes
###################################################
pm <- DNAStringSet(hgu95av2probe)
dict <- pm[3801:4000]
pdict <- PDict(dict)
m <- vcountPDict(pdict, pm)
dim(m)
table(rowSums(m))
which(rowSums(m) == 3)
ii <- which(m[77, ] != 0)
pm[ii]


###################################################
### code chunk number 3: basecontent
###################################################
bcpm <- alphabetFrequency(pm, baseOnly=TRUE)
head(bcpm)
alphabetFrequency(pm, baseOnly=TRUE, collapse=TRUE)


###################################################
### code chunk number 4: hgu95av2dim
###################################################
nc = hgu95av2dim$NCOL
nr = hgu95av2dim$NROW


###################################################
### code chunk number 5: matchprobes.Rnw:176-182
###################################################
library(affy)
abseq = rep(as.character(NA), nc*nr) 
ipm = with(hgu95av2probe, xy2indices(x, y, nc=nc))
any(duplicated(ipm))  # just a sanity check
abseq[ipm] = hgu95av2probe$sequence
table(is.na(abseq))


###################################################
### code chunk number 6: pm2mm
###################################################
mm <- pm
subseq(mm, start=13, width=1) <- complement(subseq(mm, start=13, width=1))
cat(as.character(pm[[1]]), as.character(mm[[1]]), sep="\n")


###################################################
### code chunk number 7: mismatchSeq
###################################################
imm = with(hgu95av2probe, xy2indices(x, y+1, nc=nc))
intersect(ipm, imm)  # just a sanity check
abseq[imm] = as.character(mm)
table(is.na(abseq))


###################################################
### code chunk number 8: bc
###################################################
freqs <- alphabetFrequency(DNAStringSet(abseq[!is.na(abseq)]), baseOnly=TRUE)
bc <- matrix(nrow=length(abseq), ncol=5)
colnames(bc) <- colnames(freqs)
bc[!is.na(abseq), ] <- freqs
head(na.omit(bc))


###################################################
### code chunk number 9: GC
###################################################
GC = ordered(bc[,"G"] + bc[,"C"])
colores = rainbow(nlevels(GC))


###################################################
### code chunk number 10: abatch
###################################################
library(affydata)
f <- system.file("extracelfiles", "CL2001032020AA.cel", package="affydata")
pd <- new("AnnotatedDataFrame", data=data.frame(fromFile=I(f), row.names="f"))
abatch <- read.affybatch(filenames=f, compress=TRUE, phenoData=pd)


###################################################
### code chunk number 11: bap
###################################################
barplot(table(GC), col=colores, xlab="GC", ylab="number")


###################################################
### code chunk number 12: bxp
###################################################
boxplot(log2(exprs(abatch)[,1]) ~ GC, outline=FALSE,
  col=colores, , xlab="GC", ylab=expression(log[2]~intensity))


###################################################
### code chunk number 13: p2p
###################################################
png("matchprobes-p2p.png", width=900, height=480)
plot(exprs(abatch)[ipm,1], exprs(abatch)[imm,1], asp=1, pch=".", log="xy",
     xlab="PM", ylab="MM", col=colores[GC[ipm]])
abline(a=0, b=1, col="#404040", lty=3)
dev.off()


