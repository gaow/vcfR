# create.chromR tests.

# detach(package:vcfR, unload=T)
#library(testthat)
library(vcfR)
context("create.chromR functions")

data("vcfR_example")

#library(testthat)
#data(vcfR_example)

test_that("Create a null chromR",{
  chrom <- new(Class="chromR")
  expect_is(chrom, "chromR")
  expect_is(chrom@vcf, "vcfR")
  expect_is(chrom@seq, "NULL")
  expect_is(chrom@ann, "data.frame")
  
  expect_equal(ncol(chrom@vcf@fix), 8)
  expect_equal(nrow(chrom@vcf@fix), 0)
  expect_equal(length(chrom@seq), 0)
  expect_equal(ncol(chrom@ann), 9)
  expect_equal(nrow(chrom@ann), 0)
})



#vcf_file <- system.file("extdata", "pinf_sc1_100_sub.vcf.gz", package = "vcfR")
#seq_file <- system.file("extdata", "pinf_sc100.fasta", package = "vcfR")
#gff_file <- system.file("extdata", "pinf_sc100.gff", package = "vcfR")

#vcf <- read.vcfR(vcf_file, verbose = FALSE)
#dna <- ape::read.dna(seq_file, format = "fasta")
#gff <- read.table(gff_file, sep="\t")


test_that("We can create a Chrom, no sequence or annotation",{
  chrom <- create.chromR(name="Supercontig_1.50", vcf=vcf, verbose=FALSE)
  expect_is(chrom, "chromR")
  expect_is(chrom@vcf, "vcfR")
  expect_is(chrom@seq, "NULL")
  expect_is(chrom@ann, "data.frame")
  expect_is(chrom@var.info, "data.frame")
  expect_is(chrom@var.info[,'POS'], "integer")
  
  expect_equal(ncol(chrom@vcf@fix), 8)
  expect_equal(nrow(chrom@vcf@fix) > 0, TRUE)
  expect_equal(length(chrom@seq), 0)
  expect_equal(ncol(chrom@ann), 9)
  expect_equal(nrow(chrom@ann), 0)
  expect_equal(ncol(chrom@var.info), 5)
  expect_equal(nrow(chrom@var.info)>0, TRUE)
})


test_that("We can create a chromR, no annotation",{
  chrom <- create.chromR(name="Supercontig_1.50", vcf=vcf, seq=dna, verbose=FALSE)
  expect_is(chrom, "chromR")
  expect_is(chrom@vcf, "vcfR")
  expect_is(chrom@seq, "DNAbin")
  expect_is(chrom@ann, "data.frame")
  expect_is(chrom@var.info, "data.frame")
  
  expect_equal(ncol(chrom@vcf@fix), 8)
  expect_equal(nrow(chrom@vcf@fix) > 0, TRUE)
  expect_equal(length(chrom@seq)>0, TRUE)
  expect_equal(ncol(chrom@ann), 9)
  expect_equal(nrow(chrom@ann), 0)
})


test_that("We can create a chromR, no sequence",{
  chrom <- create.chromR(name="Supercontig_1.50", vcf=vcf, ann=gff, verbose=FALSE)
  expect_is(chrom, "chromR")
  expect_is(chrom@vcf, "vcfR")
  expect_is(chrom@seq, "NULL")
  expect_is(chrom@ann, "data.frame")
  expect_is(chrom@var.info, "data.frame")
  
  expect_equal(ncol(chrom@vcf@fix), 8)
  expect_equal(nrow(chrom@vcf@fix) > 0, TRUE)
  expect_equal(length(chrom@seq), 0)
  expect_equal(ncol(chrom@ann), 9)
  expect_equal(nrow(chrom@ann)>0, TRUE)
})


test_that("We can create a chromR, no sequence, annotation greater than vcf POS",{
  gff2 <- gff
  gff2[23,5] <- 100000
  chrom <- create.chromR(name="Supercontig_1.50", vcf=vcf, ann=gff2, verbose=FALSE)
  expect_equal( chrom@len, 100000)
})


test_that("We can create a chromR",{
  chrom <- create.chromR(name="Supercontig_1.50", vcf=vcf, seq=dna, ann=gff, verbose=FALSE)
  expect_is(chrom, "chromR")
  expect_is(chrom@vcf, "vcfR")
  expect_is(chrom@seq, "DNAbin")
  expect_is(chrom@ann, "data.frame")
  expect_is(chrom@var.info, "data.frame")
  
  expect_equal(ncol(chrom@vcf@fix), 8)
  expect_equal(nrow(chrom@vcf@fix) > 0, TRUE)
  expect_equal(length(chrom@seq)>0, TRUE)
  expect_equal(ncol(chrom@ann), 9)
  expect_equal(nrow(chrom@ann)>0, TRUE)
})


##### ##### ##### ##### #####
# seq2chromR

#test_that("seq2chromR works",{
#
#})




##### ##### ##### ##### #####
# masker

chrom <- create.chromR(name="Supercontig_1.50", vcf=vcf, seq=dna, ann=gff, verbose=FALSE)
chrom <- masker(chrom, min_DP = 300, max_DP = 700)

test_that("We implemented the mask",{
  expect_true( sum(chrom@var.info[,'mask']) < nrow(chrom@var.info) )
})



##### ##### ##### ##### #####
# proc.chromR


test_that("proc.chromR works",{
  chrom <- proc.chromR(chrom, verbose = FALSE)
  
  expect_true( ncol(chrom@var.info) >= 3 )
  chrom <- proc.chromR(chrom, verbose = FALSE)
  expect_true( ncol(chrom@var.info) >= 3 )
})


##### ##### ##### ##### #####
# seq2rects

data("vcfR_example")
chrom <- create.chromR(name="Supercontig_1.50", vcf=vcf, seq=dna, ann=gff, verbose=FALSE)


test_that("seq2rects works for test data",{
  rects1 <- seq2rects(chrom)
  
  expect_is( rects1, "matrix" )
  expect_true( nrow(rects1) > 0 )
})


test_that("seq2rects works with ns",{
  rects2 <- seq2rects(chrom, chars="n")
  
  expect_is( rects2, "matrix" )
  expect_true( nrow(rects2) > 0 )
})


test_that("seq2rects works when seq has no Ns",{
  # Replace n with a.
  seq2 <- as.character( chrom@seq )
  seq2[ seq2 == 'n' ] <- 'a'
  chrom@seq <- ape::as.DNAbin(seq2)
  
  rects2 <- seq2rects(chrom, chars="n")
  
  expect_is( rects2, "matrix" )
  expect_true( nrow(rects2) == 0 )
})


##### ##### ##### ##### #####
# regex.win






##### ##### ##### ##### #####
# chromR2vcfR

test_that("chromR2vcfR works",{
  chrom <- create.chromR(name="Supercontig_1.50", vcf=vcf, seq=dna, ann=gff, verbose=FALSE)
  chrom <- masker(chrom, min_DP = 300, max_DP = 700)
  
  test <- chromR2vcfR(chrom, use.mask = TRUE)

  sum(chrom@var.info$mask)
nrow(test)
})

##### ##### ##### ##### #####
# EOF.