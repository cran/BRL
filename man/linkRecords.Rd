% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/linkRecords.R
\name{linkRecords}
\alias{linkRecords}
\title{Bayes Estimates of Bipartite Matchings}
\usage{
linkRecords(Zchain, n1, lFNM = 1, lFM1 = 1, lFM2 = 2, lR = Inf)
}
\arguments{
\item{Zchain}{matrix as the output \code{$Z} of the function \code{\link{bipartiteGibbs}}, with \code{n2} rows and \code{nIter} columns containing a chain 
of draws from a posterior distribution on bipartite matchings.  Each column indicates the records in datafile 1 to which the records in datafile 2 are matched according to that draw.}

\item{n1}{number of records in datafile 1.}

\item{lFNM}{individual loss of a false non-match in the loss functions of Sadinle (2017), default \code{lFNM=1}.}

\item{lFM1}{individual loss of a false match of type 1 in the loss functions of Sadinle (2017), default \code{lFM1=1}.}

\item{lFM2}{individual loss of a false match of type 2 in the loss functions of Sadinle (2017), default \code{lFM2=2}.}

\item{lR}{individual loss of 'rejecting' to make a decision in the loss functions of Sadinle (2017), default \code{lR=Inf}.}
}
\value{
A vector containing the point estimate of the bipartite matching.  If \code{lR != Inf} the output might be a partial estimate.
		A number smaller or equal to \code{n1} in entry \code{j} indicates the record in datafile 1 to which record \code{j} in datafile 2 
		gets linked, a number \code{n1+j} indicates that record \code{j} does not get linked to any record in datafile 1, and the value \code{-1} 
		indicates a 'rejection' to link, meaning that the correct linkage decision is not clear.
}
\description{
Bayes point estimates of bipartite matchings that can be obtained 
in closed form according to Theorems 1, 2 and 3 of Sadinle (2017).
}
\details{
Not all combinations of losses \code{lFNM, lFM1, lFM2, lR} 
			are supported.  The losses have to be positive numbers and satisfy one of three conditions:
\enumerate{
			\item Conditions of Theorem 1 of Sadinle (2017):
		\code{(lR == Inf) & (lFNM <= lFM1) & (lFNM + lFM1 <= lFM2)}
			\item Conditions of Theorem 2 of Sadinle (2017):
		\code{((lFM2 >= lFM1) & (lFM1 >= 2*lR)) | ((lFM1 >= lFNM) & (lFM2 >= lFM1 + lFNM))}
			\item Conditions of Theorem 3 of Sadinle (2017):
		\code{(lFM2 >= lFM1) & (lFM1 >= 2*lR) & (lFNM >= 2*lR)}
}
If one of the last two conditions is satisfied, the point estimate might be partial, meaning that there
might be some records in datafile 2 for which the point estimate does not include a linkage decision.
For combinations of losses not supported here, the linear sum assignment problem outlined by Sadinle (2017)
needs to be solved.
}
\examples{
data(twoFiles)

myCompData <- compareRecords(df1, df2, flds=c("gname", "fname", "age", "occup"), 
                             types=c("lv","lv","bi","bi"))

chain <- bipartiteGibbs(myCompData)

## discard first 100 iterations of Gibbs sampler

## full estimate of bipartite matching (full linkage)
fullZhat <- linkRecords(chain$Z[,-c(1:100)], n1=nrow(df1), lFNM=1, lFM1=1, lFM2=2, lR=Inf)

## partial estimate of bipartite matching (partial linkage), where 
## lR=0.5, lFNM=1, lFM1=1 mean that we consider not making a decision for 
## a record as being half as bad as a false non-match or a false match of type 1
partialZhat <- linkRecords(chain$Z[,-c(1:100)], n1=nrow(df1), lFNM=1, lFM1=1, lFM2=2, lR=.5)

## for which records the decision is not clear according to this set-up of the losses? 
undecided <- which(partialZhat == -1)
df2[undecided,]

## compute frequencies of link options observed in the chain 
linkOptions <- apply(chain$Z[undecided, -c(1:100)], 1, table)
linkOptions <- lapply(linkOptions, sort, decreasing=TRUE)
linkOptionsInds <- lapply(linkOptions, names)
linkOptionsInds <- lapply(linkOptionsInds, as.numeric)
linkOptionsFreqs <- lapply(linkOptions, function(x) as.numeric(x)/sum(x))

## first record without decision
df2[undecided[1],]

## options for this record; row of NAs indicates possibility that record has no match in df1
cbind(df1[linkOptionsInds[[1]],], prob = round(linkOptionsFreqs[[1]],3) )
}
\references{
Mauricio Sadinle (2017). Bayesian Estimation of Bipartite Matchings for Record Linkage. \emph{Journal of the
American Statistical Association} 112(518), 600-612. [\href{https://doi.org/10.1080/01621459.2016.1148612}{Published}] [\href{https://arxiv.org/abs/1601.06630}{arXiv}]
}
