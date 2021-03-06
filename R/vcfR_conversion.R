#' @title Convert vcfR objects to other formats
#' @name Format conversion
#' @rdname vcfR_conversion
#' @description
#' Convert vcfR objects to objects supported by other R packages
#'  
#' @param x an object of class chromR or vcfR
#' 
#' @details 
#' After processing vcf data in vcfR, one will likely proceed to an analysis step.
#' Within R, three obvious choices are:
#' \href{http://cran.r-project.org/package=pegas}{pegas},
#' \href{http://cran.r-project.org/package=adegenet}{adegenet} 
#' and \href{http://cran.r-project.org/package=poppr}{poppr}.
#' The package pegas uses objects of type loci.
#' The function \strong{vcfR2loci} calls extract.gt to create a matrix of genotypes which is then converted into an object of type loci.
#' 
#' The packages adegenet and poppr use the genind object.
#' The function \strong{vcfR2genind} uses extract.gt to create a matrix of genotypes and uses the adegenet function df2genind to create a genind object.
#' The package poppr additionally uses objects of class genclone which can be created from genind objects using poppr::as.genclone.
#' A genind object can be converted to a genclone object with the function poppr::as.genclone.
#' 
#' 
#' The function vcfR2genlight calls the 'new' method for the genlight object.
#' This method implements multi-threading through calls to the function \code{\link[parallel]{mclapply}}.
#' Because 'forks' do not exist in the windows environment, this will only work for windows users when n.cores=1.
#' In the Unix environment, users may increase this number to allow the use of multiple threads (i.e., cores).
#' 
#' 
#' 
#' @seealso
#' \code{\link{extract.gt}},
#' \code{\link{alleles2consensus}},
#' \code{\link[adegenet]{df2genind}},
#' \code{\link[adegenet]{genind}},
#' \href{http://cran.r-project.org/package=pegas}{pegas},
#' \href{http://cran.r-project.org/package=adegenet}{adegenet},
#' and 
#' \href{http://cran.r-project.org/package=poppr}{poppr}.
#' To convert to objects of class \strong{DNAbin} see \code{\link{vcfR2DNAbin}}.
#'



#' @rdname vcfR_conversion
#' @aliases vcfR2genind
#' 
#' @param sep character (to be used in a regular expression) to delimit the alleles of genotypes
#' 
#' @export
vcfR2genind <- function(x, sep="[|/]") {
  locNames <- x@fix[,'ID']
  x <- extract.gt(x)
  x[grep('.', x, fixed = TRUE)] <- NA
#  x[grep('\\.', x)] <- NA
#  x[x == "./."] <- NA
#  x[x == ".|."] <- NA

#  x <- adegenet::df2genind(t(x), sep=sep)
  if( requireNamespace('adegenet') ){
    x <- adegenet::df2genind(t(x), sep=sep)
#    x <- df2genind(t(x), sep=sep)
  } else {
    warning("adegenet not installed")
  }
  x
}


#' @rdname vcfR_conversion
#' @aliases vcfR2loci
#' 
#' @export
vcfR2loci <- function(x)
{
#  if(class(x) == "chromR")
#  {
#    x <- x@vcf
#  }
  x <- extract.gt(x)
  # modified from pegas::as.loci.genind
  x <- as.data.frame(t(x))
  icol <- 1:ncol(x)
  for (i in icol) x[, i] <- factor(x[, i] )
  class(x) <- c("loci", "data.frame")
  attr(x, "locicol") <- icol
  x
}







#' @rdname vcfR_conversion
#' @aliases vcfR2genlight
#' 
#' @param n.cores integer specifying the number of cores to use.
#' 
#' @export
vcfR2genlight <- function(x, n.cores=1){

  bi <- is.biallelic(x)
  if(sum(!bi) > 0){
    msg <- paste("Found", sum(!bi), "loci with more than two alleles.")
    msg <- c(msg, "\n", paste("Objects of class genlight only support loci with two alleles."))
    msg <- c(msg, "\n", paste(sum(!bi), 'loci will be omitted from the genlight object.'))
    warning(msg)
    x <- x[bi,]
  }
  
  x <- addID(x)
  
  CHROM <- x@fix[,'CHROM']
  POS   <- x@fix[,'POS']
  ID    <- x@fix[,'ID']
  
  x <- extract.gt(x)
  x[x=="0|0"] <- 0
  x[x=="0|1"] <- 1
  x[x=="1|0"] <- 1
  x[x=="1|1"] <- 2
  x[x=="0/0"] <- 0
  x[x=="0/1"] <- 1
  x[x=="1/0"] <- 1
  x[x=="1/1"] <- 2

  #  dim(x)
  if( requireNamespace('adegenet') ){
    x <- new('genlight', t(x), n.cores=n.cores)
  } else {
    warning("adegenet not installed")
  }
#  x <- adegenet::as.genlight(t(x), n.cores=3)
#  x <- adegenet::as.genlight(t(x))
  adegenet::chromosome(x) <- CHROM
  adegenet::position(x)   <- POS
  adegenet::locNames(x)   <- ID
  
  return(x)
}


