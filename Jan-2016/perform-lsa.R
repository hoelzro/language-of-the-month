#!/usr/bin/env Rscript

library(Matrix)

tf_idf <- function(TF) {
    N <- dim(TF)[2]
    IDF <- log(N / rowSums(TF > 0))

    return(TF * IDF)
}

make_matrix <- function(row_list, col_list, value_list) {
    M <- matrix(0, nrow=max(row_list), ncol=max(col_list))
    M[cbind(row_list, col_list)] <- value_list

    return(M)
}

terms <- readLines('terms')
lines <- readLines('lines')

n_terms <- length(terms)
n_lines <- length(lines)

Table <- read.table('term-matrix', col.names=c('term', 'line', 'count'))
TF <- make_matrix(Table$term, Table$line, Table$count)
TFIDF <- tf_idf(TF)

svd_result <- svd(TFIDF)
S <- make_matrix(1:length(svd_result$d), 1:length(svd_result$d), svd_result$d)
diag(S)[3001:length(svd_result$d)] <- 0

X <- svd_result$u %*% S %*% t(svd_result$v)
TermSimilarity <- X %*% t(X)
DocSimilarity <- t(X) %*% X

diag(TermSimilarity) <- 0
diag(DocSimilarity) <- 0

similar_term_values <- TermSimilarity[cbind(1:n_terms, max.col(TermSimilarity))]
similar_doc_values <- DocSimilarity[cbind(1:n_lines, max.col(DocSimilarity))]

similar_terms <- matrix(0, nrow=n_terms, ncol=3)
similar_terms[,1] <- terms[sort.int(similar_term_values, index.return=T)$ix]
similar_terms[,2] <- terms[max.col(TermSimilarity)[sort.int(similar_term_values, index.return=T)$ix]]
similar_terms[,3] <- sort(similar_term_values)

similar_docs <- matrix(0, nrow=n_lines, ncol=3)
similar_docs[,1] <- lines[sort.int(similar_doc_values, index.return=T)$ix]
similar_docs[,2] <- lines[max.col(DocSimilarity)[sort.int(similar_doc_values, index.return=T)$ix]]
similar_docs[,3] <- sort(similar_doc_values)

write.table(similar_terms, file='gtd-similar-terms')
write.table(similar_docs, file='gtd-similar-docs')
