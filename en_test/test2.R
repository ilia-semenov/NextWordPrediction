source("functions2.R")


start.time <- Sys.time()
print(start.time)

#load
us_corpus<-loadCorpus("./","^en*")


#clean
us_corpus<-cleanCorpus(us_corpus,badWords('en'))



#unigram dtm
dt1<-unigramFreq(us_corpus)
#bigram dtm
dt2<-ngramFreq(us_corpus,2)
dt3<-ngramFreq(us_corpus,3)

setkey(dt3,w1,w2)
setkey(dt2,w1,w2)
dt3<-dt2[dt3]
setkey(dt3,w2,w3)
dt3<-dt3[dt2]
setkey(dt3,w2)
setkey(dt1,w1)
dt3<-dt3[dt1]
setkey(dt3,w3)
dt3<-dt3[dt1]
names(dt3)[3]<-'freq12'
names(dt3)[5]<-'freq123'
names(dt3)[6]<-'freq23'
names(dt3)[7]<-'freq2'
names(dt3)[8]<-'freq3'
dt3$p123<-dt3$freq123/dt3$freq12
dt3$p23<-dt3$freq23/dt3$freq2
dt3$p3<-dt3$freq3/sum(dt3$freq3)

saveDB(dt3,"dt3q")


end.time<-Sys.time()
print(end.time)