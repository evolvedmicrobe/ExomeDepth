
setGeneric("AnnotateExtra", def = function(x, reference.annotation, min.overlap = 0.5, column.name = 'overlap') standardGeneric('AnnotateExtra'))


setMethod("AnnotateExtra", "ExomeDepth", function( x, reference.annotation, min.overlap, column.name) {
  
  my.calls.GRanges <- GenomicRanges::GRanges(seqnames = factor(x@CNV.calls$chromosome),
                              IRanges::IRanges(start=x@CNV.calls$start,end= x@CNV.calls$end))
  ##browser()
  print(my.calls.GRanges)
  test <- GenomicRanges::findOverlaps(query = my.calls.GRanges, subject = reference.annotation)
  #test <- data.frame(calls = test@queryHits, ref = test@subjectHits)
  test <- data.frame(calls = GenomicRanges::queryHits(test), ref = GenomicRanges::subjectHits(test))

  #print(test)
###add info about the CNV calls
  test$call.start <- x@CNV.calls$start[ test$calls ]
  test$call.end <- x@CNV.calls$end[ test$calls ]
  test$chromosome.end <- x@CNV.calls$chromosome[ test$calls ]
  
  ## info about the reference calls
  test$callsref.start <- GenomicRanges::start(reference.annotation) [ test$ref ]
  test$callsref.end<- GenomicRanges::end(reference.annotation) [ test$ref ]
  
### estimate the overlap
  test$overlap <- pmin (test$callsref.end, test$call.end) -  pmax( test$call.start, test$callsref.start)
  test <- subset(test, overlap > min.overlap*(test$call.end - test$call.start))

  print(test)
  
  my.split <-  split(as.character(GenomicRanges::elementMetadata(reference.annotation)$names)[ test$ref], f = test$calls)
  my.overlap.frame <- data.frame(call = names(my.split),  target = sapply(my.split, FUN = paste, collapse = ','))
  my.overlap.frame <- data.frame(call = names(my.split),  target = sapply(my.split, FUN = paste, collapse = ','))
  
  
  x@CNV.calls[, column.name] <- as.character(my.overlap.frame$target)[ match(1:nrow(x@CNV.calls), table = my.overlap.frame$call) ]
  return(x)
})

