library(ExomeDepth)
source('R/plot_CNVs_method.R')
data(ExomeCount)


######################33
ExomeCount.dafr <- as(ExomeCount[,  colnames(ExomeCount)], 'data.frame')
ExomeCount.dafr$chromosome <- gsub(as.character(ExomeCount.dafr$space),
                                   pattern = 'chr',
                                   replacement = '')  ##remove the annoying chr letters
print(head(ExomeCount.dafr))

data(Conrad.hg19)
data(exons.hg19)

exons.hg19.GRanges <- GRanges(seqnames = exons.hg19$chromosome,
                              IRanges(start=exons.hg19$start,end=exons.hg19$end),
                              names = exons.hg19$name)


#### ExomeCount
ExomeCount.mat <- as.matrix(ExomeCount.dafr[, grep(names(ExomeCount.dafr), pattern = 'Exome.*')])
nsamples <- ncol(ExomeCount.mat)
for (i in 1:nsamples) {

  #### creating the aggregate reference set for this sample
  my.choice <- select.reference.set (test.counts =  ExomeCount.mat[,i],
                                     reference.counts = ExomeCount.mat[,-i],
                                     bin.length = (ExomeCount.dafr$end - ExomeCount.dafr$start)/1000,
                                     n.bins.reduced = 10000)

  my.reference.selected <- apply(X = ExomeCount.mat[, my.choice$reference.choice],
                                 MAR = 1,
                                 FUN = sum)

  message('Now creating the ExomeDepth object')
  all.exons <- new('ExomeDepth',
                   test = ExomeCount.mat[,i],
                   reference = my.reference.selected,
                   formula = 'cbind(test, reference) ~ 1')
  
  ################3 Now call the CNVs
  all.exons <- CallCNVs(x = all.exons,
                        transition.probability = 10^-4,
                        chromosome = ExomeCount.dafr$space,
                        start = ExomeCount.dafr$start,
                        end = ExomeCount.dafr$end,
                        name = ExomeCount.dafr$names)

  ########################### Now annotate the ExomeDepth object
  all.exons <- AnnotateExtra(x = all.exons,
                             reference.annotation = Conrad.hg19.common.CNVs,
                             min.overlap = 0.5,
                             column.name = 'Conrad.hg19')

  all.exons <- AnnotateExtra(x = all.exons,
                             reference.annotation = exons.hg19.GRanges,
                             min.overlap = 0.0001,
                             column.name = 'exons.hg19')
  
  
  output.file <- paste('Exome_', i, 'csv', sep = '')
  write.csv(file = output.file, x = all.exons@CNV.calls, row.names = FALSE)

}











ExomeCount <- as(ExomeCount[,  colnames(ExomeCount)], 'data.frame')



ExomeCount <- as(ExomeCount[,  colnames(ExomeCount)], 'data.frame')
ExomeCount$chromosome <- gsub(as.character(ExomeCount$space), 
                              pattern = 'chr', 
                              replacement = '')  ##remove the annoying chr letters
print(head(ExomeCount))
data(exons.hg19)
print(head(exons.hg19))


test <- new('ExomeDepth',
            test = ExomeCount$camfid.033ahw_sorted_unique.bam,
            reference = ExomeCount$camfid.035if_sorted_unique.bam,
            formula = 'cbind(test, reference) ~ 1',
            subset.for.speed = seq(1, nrow(ExomeCount), 100))

show(test)

my.test <- ExomeCount$camfid.034pc_sorted_unique.bam
my.ref.samples <- c('camfid.032KA_sorted_unique.bam', 'camfid.033ahw_sorted_unique.bam', 'camfid.035if_sorted_unique.bam')
my.reference.set <- as.matrix(ExomeCount[, my.ref.samples])
my.choice <- select.reference.set (test.counts = my.test, 
                                   reference.counts = my.reference.set, 
                                   bin.length = (ExomeCount$end - ExomeCount$start)/1000, 
                                   n.bins.reduced = 10000)

print(my.choice[[1]])
my.reference.selected <- apply(X = as.matrix( ExomeCount[, my.choice$reference.choice] ), 
                               MAR = 1, 
                               FUN = sum)

all.exons <- new('ExomeDepth',
                 test = my.test,
                 reference = my.reference.selected,
                 formula = 'cbind(test, reference) ~ 1')

all.exons <- CallCNVs(x = all.exons, 
                      transition.probability = 10^-4, 
                      chromosome = ExomeCount$space, 
                      start = ExomeCount$start, 
                      end = ExomeCount$end, 
                      name = ExomeCount$names)
print(head(all.exons@CNV.calls))


source('R/plot_CNVs_method.R')

pdf('RHD_example.pdf')
plot (all.exons,
      sequence = '1',
      xlim = c(25598981 - 100000, 25633433 + 100000),
      count.threshold = 20,
      main = 'RHD gene',
      with.gene = TRUE)
dev.off()
