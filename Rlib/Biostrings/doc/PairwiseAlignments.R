### R code from vignette source 'PairwiseAlignments.Rnw'
### Encoding: UTF-8

###################################################
### code chunk number 1: options
###################################################
options(width=72)


###################################################
### code chunk number 2: main1
###################################################
library(Biostrings)
pairwiseAlignment(pattern = c("succeed", "precede"), subject = "supersede")


###################################################
### code chunk number 3: main2
###################################################
pairwiseAlignment(pattern = c("succeed", "precede"), subject = "supersede",
                  type = "local")


###################################################
### code chunk number 4: main3
###################################################
pairwiseAlignment(pattern = c("succeed", "precede"), subject = "supersede",
                  gapOpening = 0, gapExtension = 1)


###################################################
### code chunk number 5: main4
###################################################
submat <-
  matrix(-1, nrow = 26, ncol = 26, dimnames = list(letters, letters))
diag(submat) <- 0
pairwiseAlignment(pattern = c("succeed", "precede"), subject = "supersede",
                  substitutionMatrix = submat,
                  gapOpening = 0, gapExtension = 1)


###################################################
### code chunk number 6: main5
###################################################
submat <-
  matrix(-1, nrow = 26, ncol = 26, dimnames = list(letters, letters))
diag(submat) <- 0
pairwiseAlignment(pattern = c("succeed", "precede"), subject = "supersede",
                  substitutionMatrix = submat,
                  gapOpening = 0, gapExtension = 1, scoreOnly = TRUE)


###################################################
### code chunk number 7: classes1
###################################################
pa1 <- pairwiseAlignment(pattern = c("succeed", "precede"), subject = "supersede")
class(pa1)


###################################################
### code chunk number 8: classes2
###################################################
summary(pa1)
class(summary(pa1))


###################################################
### code chunk number 9: classes3
###################################################
class(pattern(pa1))
submat <-
  matrix(-1, nrow = 26, ncol = 26, dimnames = list(letters, letters))
diag(submat) <- 0
pa2 <-
  pairwiseAlignment(pattern = c("succeed", "precede"), subject = "supersede",
                    substitutionMatrix = submat,
                    gapOpening = 0, gapExtension = 1)
class(pattern(pa2))


###################################################
### code chunk number 10: helper1
###################################################
submat <-
  matrix(-1, nrow = 26, ncol = 26, dimnames = list(letters, letters))
diag(submat) <- 0
pa2 <-
  pairwiseAlignment(pattern = c("succeed", "precede"), subject = "supersede",
                    substitutionMatrix = submat,
                    gapOpening = 0, gapExtension = 1)
score(pa2)
nedit(pa2)
nmatch(pa2)
nmismatch(pa2)
nchar(pa2)
aligned(pa2)
as.character(pa2)
as.matrix(pa2)
consensusMatrix(pa2)


###################################################
### code chunk number 11: helper2
###################################################
summary(pa2)
mismatchTable(pa2)
mismatchSummary(pa2)


###################################################
### code chunk number 12: helper3
###################################################
class(pattern(pa2))
aligned(pattern(pa2))
nindel(pattern(pa2))
start(subject(pa2))
end(subject(pa2))


###################################################
### code chunk number 13: editdist1
###################################################
agrepBioC <-
function(pattern, x, ignore.case = FALSE, value = FALSE, max.distance = 0.1)
{
  if (!is.character(pattern)) pattern <- as.character(pattern)
  if (!is.character(x)) x <- as.character(x)
  if (max.distance < 1)
    max.distance <- ceiling(max.distance / nchar(pattern))
  characters <- unique(unlist(strsplit(c(pattern, x), "", fixed = TRUE)))
  if (ignore.case)
    substitutionMatrix <-
      outer(tolower(characters), tolower(characters), function(x,y) -as.numeric(x!=y))
  else
    substitutionMatrix <-
      outer(characters, characters, function(x,y) -as.numeric(x!=y))
  dimnames(substitutionMatrix) <- list(characters, characters)
  distance <-
    - pairwiseAlignment(pattern = x, subject = pattern,
                        substitutionMatrix = substitutionMatrix,
                        type = "local-global",
                        gapOpening = 0, gapExtension = 1,
                        scoreOnly = TRUE)
  whichClose <- which(distance <= max.distance)
  if (value)
    whichClose <- x[whichClose]
  whichClose
}
cbind(base = agrep("laysy", c("1 lazy", "1", "1 LAZY"), max = 2, value = TRUE),
      bioc = agrepBioC("laysy", c("1 lazy", "1", "1 LAZY"), max = 2, value = TRUE))
cbind(base = agrep("laysy", c("1 lazy", "1", "1 LAZY"), max = 2, ignore.case = TRUE),
      bioc = agrepBioC("laysy", c("1 lazy", "1", "1 LAZY"), max = 2, ignore.case = TRUE))


###################################################
### code chunk number 14: lkblo
###################################################
data(BLOSUM50)
BLOSUM50[1:4,1:4]
nwdemo <- 
  pairwiseAlignment(AAString("PAWHEAE"), AAString("HEAGAWGHEE"), substitutionMatrix = BLOSUM50,
                    gapOpening = 0, gapExtension = 8)
nwdemo
compareStrings(nwdemo)
pid(nwdemo)


###################################################
### code chunk number 15: adapter1
###################################################
simulateReads <-
function(N, adapter, experiment, substitutionRate = 0.01, gapRate = 0.001) {
  chars <- strsplit(as.character(adapter), "")[[1]]
  sapply(seq_len(N), function(i, experiment, substitutionRate, gapRate) {
    width <- experiment[["width"]][i]
    side <- experiment[["side"]][i]
    randomLetters <-
      function(n) sample(DNA_ALPHABET[1:4], n, replace = TRUE) 
    randomLettersWithEmpty <-
      function(n)
      sample(c("", DNA_ALPHABET[1:4]), n, replace = TRUE,
             prob = c(1 - gapRate, rep(gapRate/4, 4)))
    nChars <- length(chars)
    value <-
      paste(ifelse(rbinom(nChars,1,substitutionRate), randomLetters(nChars), chars),
            randomLettersWithEmpty(nChars),
            sep = "", collapse = "")
    if (side)
      value <-
        paste(c(randomLetters(36 - width), substring(value, 1, width)),
                sep = "", collapse = "")
    else
      value <-
        paste(c(substring(value, 37 - width, 36), randomLetters(36 - width)),
                sep = "", collapse = "")
    value
  }, experiment = experiment, substitutionRate = substitutionRate, gapRate = gapRate)
}

adapter <- DNAString("GATCGGAAGAGCTCGTATGCCGTCTTCTGCTTGAAA")
set.seed(123)
N <- 1000
experiment <-
  list(side = rbinom(N, 1, 0.5), width = sample(0:36, N, replace = TRUE))
table(experiment[["side"]], experiment[["width"]])
adapterStrings <-
  simulateReads(N, adapter, experiment, substitutionRate = 0.01, gapRate = 0.001)
adapterStrings <- DNAStringSet(adapterStrings)


###################################################
### code chunk number 16: adapter2
###################################################
M <- 5000
randomStrings <-
  apply(matrix(sample(DNA_ALPHABET[1:4], 36 * M, replace = TRUE),
               nrow = M), 1, paste, collapse = "")
randomStrings <- DNAStringSet(randomStrings)


###################################################
### code chunk number 17: adapter3
###################################################
## Method 1:  Use edit distance with an FDR of 1e-03
submat1 <- nucleotideSubstitutionMatrix(match = 0, mismatch = -1, baseOnly = TRUE)
randomScores1 <-
  pairwiseAlignment(randomStrings, adapter, substitutionMatrix = submat1,
                    gapOpening = 0, gapExtension = 1, scoreOnly = TRUE)
quantile(randomScores1, seq(0.99, 1, by = 0.001))
adapterAligns1 <-
  pairwiseAlignment(adapterStrings, adapter, substitutionMatrix = submat1,
                    gapOpening = 0, gapExtension = 1)
table(score(adapterAligns1) > quantile(randomScores1, 0.999), experiment[["width"]])


###################################################
### code chunk number 18: adapter4
###################################################
## Method 2:  Use consecutive matches anywhere in string with an FDR of 1e-03
submat2 <- nucleotideSubstitutionMatrix(match = 1, mismatch = -Inf, baseOnly = TRUE)
randomScores2 <-
  pairwiseAlignment(randomStrings, adapter, substitutionMatrix = submat2,
                    type = "local", gapOpening = 0, gapExtension = Inf,
                    scoreOnly = TRUE)
quantile(randomScores2, seq(0.99, 1, by = 0.001))
adapterAligns2 <-
  pairwiseAlignment(adapterStrings, adapter, substitutionMatrix = submat2,
                    type = "local", gapOpening = 0, gapExtension = Inf)
table(score(adapterAligns2) > quantile(randomScores2, 0.999), experiment[["width"]])
# Determine if the correct end was chosen
table(start(pattern(adapterAligns2)) > 37 - end(pattern(adapterAligns2)),
      experiment[["side"]])


###################################################
### code chunk number 19: adapter5
###################################################
## Method 3:  Use consecutive matches on the ends with an FDR of 1e-03
submat3 <- nucleotideSubstitutionMatrix(match = 1, mismatch = -Inf, baseOnly = TRUE)
randomScores3 <-
  pairwiseAlignment(randomStrings, adapter, substitutionMatrix = submat3,
                    type = "overlap", gapOpening = 0, gapExtension = Inf,
                    scoreOnly = TRUE)
quantile(randomScores3, seq(0.99, 1, by = 0.001))
adapterAligns3 <-
  pairwiseAlignment(adapterStrings, adapter, substitutionMatrix = submat3,
                    type = "overlap", gapOpening = 0, gapExtension = Inf)
table(score(adapterAligns3) > quantile(randomScores3, 0.999), experiment[["width"]])
# Determine if the correct end was chosen
table(end(pattern(adapterAligns3)) == 36, experiment[["side"]])


###################################################
### code chunk number 20: adapter6
###################################################
## Method 4:  Allow mismatches and indels on the ends with an FDR of 1e-03
randomScores4 <-
  pairwiseAlignment(randomStrings, adapter, type = "overlap", scoreOnly = TRUE)
quantile(randomScores4, seq(0.99, 1, by = 0.001))
adapterAligns4 <-
  pairwiseAlignment(adapterStrings, adapter, type = "overlap")
table(score(adapterAligns4) > quantile(randomScores4, 0.999), experiment[["width"]])
# Determine if the correct end was chosen
table(end(pattern(adapterAligns4)) == 36, experiment[["side"]])


###################################################
### code chunk number 21: adapter7
###################################################
## Method 4 continued:  Remove adapter fragments
fragmentFound <-
  score(adapterAligns4) > quantile(randomScores4, 0.999)
fragmentFoundAt1 <-
  fragmentFound & (start(pattern(adapterAligns4)) == 1)
fragmentFoundAt36 <-
  fragmentFound & (end(pattern(adapterAligns4)) == 36)
cleanedStrings <- as.character(adapterStrings)
cleanedStrings[fragmentFoundAt1] <-
  as.character(narrow(adapterStrings[fragmentFoundAt1], end = 36,
         width = 36 - end(pattern(adapterAligns4[fragmentFoundAt1]))))
cleanedStrings[fragmentFoundAt36] <-
  as.character(narrow(adapterStrings[fragmentFoundAt36], start = 1,
         width = start(pattern(adapterAligns4[fragmentFoundAt36])) - 1))
cleanedStrings <- DNAStringSet(cleanedStrings)
cleanedStrings


###################################################
### code chunk number 22: genome1
###################################################
data(phiX174Phage)
genBankPhage <- phiX174Phage[[1]]
nchar(genBankPhage)

data(srPhiX174)
srPhiX174
quPhiX174
summary(wtPhiX174)

fullShortReads <- rep(srPhiX174, wtPhiX174)
srPDict <- PDict(fullShortReads)
table(countPDict(srPDict, genBankPhage))


###################################################
### code chunk number 23: genome2
###################################################
genBankSubstring <- substring(genBankPhage, 2793-34, 2811+34)

genBankAlign <-
  pairwiseAlignment(srPhiX174, genBankSubstring,
                    patternQuality = SolexaQuality(quPhiX174),
                    subjectQuality = SolexaQuality(99L),
                    type = "global-local")
summary(genBankAlign, weight = wtPhiX174)

revisedPhage <-
  replaceLetterAt(genBankPhage, c(2793, 2811), "TT")
table(countPDict(srPDict, revisedPhage))


###################################################
### code chunk number 24: genome3
###################################################
genBankCoverage <- coverage(genBankAlign, weight = wtPhiX174)
plot((2793-34):(2811+34), as.integer(genBankCoverage), xlab = "Position", ylab = "Coverage",
     type = "l")
nchar(genBankSubstring)
slice(genBankCoverage, lower = 1)


###################################################
### code chunk number 25: profiling1
###################################################
N <- as.integer(seq(500, 5000, by = 500))
timings <- rep(0, length(N))
names(timings) <- as.character(N)
for (i in seq_len(length(N))) {
  string1 <- DNAString(paste(sample(DNA_ALPHABET[1:4], N[i], replace = TRUE), collapse = ""))
  string2 <- DNAString(paste(sample(DNA_ALPHABET[1:4], N[i], replace = TRUE), collapse = ""))
  timings[i] <- system.time(pairwiseAlignment(string1, string2, type = "global"))[["user.self"]]
}
timings
coef(summary(lm(timings ~ poly(N, 2))))
plot(N, timings, xlab = "String Size, Both Strings", ylab = "Timing (sec.)", type = "l",
     main = "Global Pairwise Sequence Alignment Timings")


###################################################
### code chunk number 26: profiling2
###################################################
scoreOnlyTimings <- rep(0, length(N))
names(scoreOnlyTimings) <- as.character(N)
for (i in seq_len(length(N))) {
  string1 <- DNAString(paste(sample(DNA_ALPHABET[1:4], N[i], replace = TRUE), collapse = ""))
  string2 <- DNAString(paste(sample(DNA_ALPHABET[1:4], N[i], replace = TRUE), collapse = ""))
  scoreOnlyTimings[i] <- system.time(pairwiseAlignment(string1, string2, type = "global", scoreOnly = TRUE))[["user.self"]]
}
scoreOnlyTimings
round((timings - scoreOnlyTimings) / timings, 2)


###################################################
### code chunk number 27: doal
###################################################
file <- system.file("extdata", "someORF.fa", package="Biostrings")
orf <- readDNAStringSet(file)
orf
orf10 <- DNAStringSet(orf, end=10)
consensusMatrix(orf10, as.prob=TRUE, baseOnly=TRUE)


###################################################
### code chunk number 28: infco
###################################################
informationContent <- function(Lmers) {
 zlog <- function(x) ifelse(x==0,0,log(x))
 co <- consensusMatrix(Lmers, as.prob=TRUE)
 lets <- rownames(co)
 fr <- alphabetFrequency(Lmers, collapse=TRUE)[lets]
 fr <- fr / sum(fr)
 sum(co*zlog(co/fr), na.rm=TRUE)
}
informationContent(orf10)


###################################################
### code chunk number 29: ans1a
###################################################
pairwiseAlignment("zyzzyx", "syzygy")
pairwiseAlignment("zyzzyx", "syzygy", type = "local")
pairwiseAlignment("zyzzyx", "syzygy", type = "overlap")


###################################################
### code chunk number 30: ans1b
###################################################
pairwiseAlignment("zyzzyx", "syzygy", type = "overlap", gapExtension = Inf)


###################################################
### code chunk number 31: ans2a
###################################################
ex2 <- summary(pairwiseAlignment("zyzzyx", "syzygy"))
nmatch(ex2) / nmismatch(ex2)


###################################################
### code chunk number 32: ans3
###################################################
ex3 <- pairwiseAlignment("zyzzyx", "syzygy", type = "overlap")


###################################################
### code chunk number 33: ans3a
###################################################
nmatch(ex3)
nmismatch(ex3)


###################################################
### code chunk number 34: ans3b
###################################################
compareStrings(ex3)


###################################################
### code chunk number 35: ans3c
###################################################
as.character(ex3)


###################################################
### code chunk number 36: ans3d
###################################################
mismatch(pattern(ex3))


###################################################
### code chunk number 37: ans3e
###################################################
aligned(subject(ex3))


###################################################
### code chunk number 38: ans4a
###################################################
submat <- matrix(-1, nrow = 26, ncol = 26, dimnames = list(letters, letters))
diag(submat) <- 0
- pairwiseAlignment("zyzzyx", "syzygy", substitutionMatrix = submat,
                    gapOpening = 0, gapExtension = 1, scoreOnly = TRUE)


###################################################
### code chunk number 39: ans4b
###################################################
stringDist(c("zyzzyx", "syzygy", "succeed", "precede", "supersede"))


###################################################
### code chunk number 40: ans5a
###################################################
data(BLOSUM62)
pairwiseAlignment(AAString("PAWHEAE"), AAString("HEAGAWGHEE"), substitutionMatrix = BLOSUM62,
                  gapOpening = 12, gapExtension = 4)


###################################################
### code chunk number 41: ans6a
###################################################
adapter <- DNAString("GATCGGAAGAGCTCGTATGCCGTCTTCTGCTTGAAA")
set.seed(123)
N <- 1000
experiment <-
  list(side = rbinom(N, 1, 0.5), width = sample(0:36, N, replace = TRUE))
table(experiment[["side"]], experiment[["width"]])
ex6Strings <-
  simulateReads(N, adapter, experiment, substitutionRate = 0.005, gapRate = 0.0005)
ex6Strings <- DNAStringSet(ex6Strings)
ex6Strings

## Method 1:  Use edit distance with an FDR of 1e-03
submat1 <- nucleotideSubstitutionMatrix(match = 0, mismatch = -1, baseOnly = TRUE)
quantile(randomScores1, seq(0.99, 1, by = 0.001))
ex6Aligns1 <-
  pairwiseAlignment(ex6Strings, adapter, substitutionMatrix = submat1,
                    gapOpening = 0, gapExtension = 1)
table(score(ex6Aligns1) > quantile(randomScores1, 0.999), experiment[["width"]])

## Method 2:  Use consecutive matches anywhere in string with an FDR of 1e-03
submat2 <- nucleotideSubstitutionMatrix(match = 1, mismatch = -Inf, baseOnly = TRUE)
quantile(randomScores2, seq(0.99, 1, by = 0.001))
ex6Aligns2 <-
  pairwiseAlignment(ex6Strings, adapter, substitutionMatrix = submat2,
                    type = "local", gapOpening = 0, gapExtension = Inf)
table(score(ex6Aligns2) > quantile(randomScores2, 0.999), experiment[["width"]])
# Determine if the correct end was chosen
table(start(pattern(ex6Aligns2)) > 37 - end(pattern(ex6Aligns2)),
      experiment[["side"]])

## Method 3:  Use consecutive matches on the ends with an FDR of 1e-03
submat3 <- nucleotideSubstitutionMatrix(match = 1, mismatch = -Inf, baseOnly = TRUE)
ex6Aligns3 <-
  pairwiseAlignment(ex6Strings, adapter, substitutionMatrix = submat3,
                    type = "overlap", gapOpening = 0, gapExtension = Inf)
table(score(ex6Aligns3) > quantile(randomScores3, 0.999), experiment[["width"]])
# Determine if the correct end was chosen
table(end(pattern(ex6Aligns3)) == 36, experiment[["side"]])

## Method 4:  Allow mismatches and indels on the ends with an FDR of 1e-03
quantile(randomScores4, seq(0.99, 1, by = 0.001))
ex6Aligns4 <- pairwiseAlignment(ex6Strings, adapter, type = "overlap")
table(score(ex6Aligns4) > quantile(randomScores4, 0.999), experiment[["width"]])
# Determine if the correct end was chosen
table(end(pattern(ex6Aligns4)) == 36, experiment[["side"]])


###################################################
### code chunk number 42: ans6b
###################################################
simulateReads <-
function(N, left, right = left, experiment, substitutionRate = 0.01, gapRate = 0.001) {
  leftChars <- strsplit(as.character(left), "")[[1]]
  rightChars <- strsplit(as.character(right), "")[[1]]
  if (length(leftChars) != length(rightChars))
    stop("left and right adapters must have the same number of characters")
  nChars <- length(leftChars)
  sapply(seq_len(N), function(i) {
    width <- experiment[["width"]][i]
    side <- experiment[["side"]][i]
    randomLetters <-
      function(n) sample(DNA_ALPHABET[1:4], n, replace = TRUE) 
    randomLettersWithEmpty <-
      function(n)
      sample(c("", DNA_ALPHABET[1:4]), n, replace = TRUE,
             prob = c(1 - gapRate, rep(gapRate/4, 4)))
    if (side) {
      value <-
        paste(ifelse(rbinom(nChars,1,substitutionRate), randomLetters(nChars), rightChars),
              randomLettersWithEmpty(nChars),
              sep = "", collapse = "")
      value <-
        paste(c(randomLetters(36 - width), substring(value, 1, width)),
                sep = "", collapse = "")
    } else {
      value <-
        paste(ifelse(rbinom(nChars,1,substitutionRate), randomLetters(nChars), leftChars),
              randomLettersWithEmpty(nChars),
              sep = "", collapse = "")
      value <-
        paste(c(substring(value, 37 - width, 36), randomLetters(36 - width)),
                sep = "", collapse = "")
    }
    value
  })
}

leftAdapter <- adapter
rightAdapter <- reverseComplement(adapter)
ex6LeftRightStrings <- simulateReads(N, leftAdapter, rightAdapter, experiment)
ex6LeftAligns4 <- 
  pairwiseAlignment(ex6LeftRightStrings, leftAdapter, type = "overlap")
ex6RightAligns4 <- 
  pairwiseAlignment(ex6LeftRightStrings, rightAdapter, type = "overlap")
scoreCutoff <- quantile(randomScores4, 0.999)
leftAligned <-
  start(pattern(ex6LeftAligns4)) == 1 & score(ex6LeftAligns4) > pmax(scoreCutoff, score(ex6RightAligns4))
rightAligned <-
  end(pattern(ex6RightAligns4)) == 36 & score(ex6RightAligns4) > pmax(scoreCutoff, score(ex6LeftAligns4))
table(leftAligned, rightAligned)
table(leftAligned | rightAligned, experiment[["width"]])


###################################################
### code chunk number 43: ans7a
###################################################
genBankFullAlign <-
  pairwiseAlignment(srPhiX174, genBankPhage,
                    patternQuality = SolexaQuality(quPhiX174),
                    subjectQuality = SolexaQuality(99L),
                    type = "global-local")
summary(genBankFullAlign, weight = wtPhiX174)


###################################################
### code chunk number 44: ans7b
###################################################
genBankFullCoverage <- coverage(genBankFullAlign, weight = wtPhiX174)
plot(as.integer(genBankFullCoverage), xlab = "Position", ylab = "Coverage", type = "l")
slice(genBankFullCoverage, lower = 1)


###################################################
### code chunk number 45: ans7c
###################################################
genBankFullAlignRevComp <-
  pairwiseAlignment(srPhiX174, reverseComplement(genBankPhage),
                    patternQuality = SolexaQuality(quPhiX174),
                    subjectQuality = SolexaQuality(99L),
                    type = "global-local")
table(score(genBankFullAlignRevComp) > score(genBankFullAlign))


###################################################
### code chunk number 46: ans8a
###################################################
N <- as.integer(seq(5000, 50000, by = 5000))
newTimings <- rep(0, length(N))
names(newTimings) <- as.character(N)
for (i in seq_len(length(N))) {
  string1 <- DNAString(paste(sample(DNA_ALPHABET[1:4], 35, replace = TRUE), collapse = ""))
  string2 <- DNAString(paste(sample(DNA_ALPHABET[1:4], N[i], replace = TRUE), collapse = ""))
  newTimings[i] <- system.time(pairwiseAlignment(string1, string2, type = "global"))[["user.self"]]
}
newTimings
coef(summary(lm(newTimings ~ poly(N, 2))))
plot(N, newTimings, xlab = "Larger String Size", ylab = "Timing (sec.)",
     type = "l", main = "Global Pairwise Sequence Alignment Timings")


###################################################
### code chunk number 47: ans8b
###################################################
newScoreOnlyTimings <- rep(0, length(N))
names(newScoreOnlyTimings) <- as.character(N)
for (i in seq_len(length(N))) {
  string1 <- DNAString(paste(sample(DNA_ALPHABET[1:4], 35, replace = TRUE), collapse = ""))
  string2 <- DNAString(paste(sample(DNA_ALPHABET[1:4], N[i], replace = TRUE), collapse = ""))
  newScoreOnlyTimings[i] <- system.time(pairwiseAlignment(string1, string2, type = "global", scoreOnly = TRUE))[["user.self"]]
}
newScoreOnlyTimings
round((newTimings - newScoreOnlyTimings) / newTimings, 2)


###################################################
### code chunk number 48: sessinfo
###################################################
sessionInfo()


