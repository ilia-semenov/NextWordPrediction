
library('sqldf')
library('RSQLite')
library('dplyr')
library('data.table')
library('stringr')
library('tm')
start.time <- Sys.time()
print(start.time)


predictSBO<-function(input,nres,db){

        s<-gsub("[][#$%*<=>@^_`|~.{}]'", "", input)
        s<-gsub("[^[:graph:]]", " ",s)
        s<-gsub("&", " and ",s)
        s<-gsub('[[:digit:]]+', '', s)
        s<-gsub('[[:punct:]]+', '', s)
        s<-gsub("\\s+", " ", str_trim(s))

        s<-unlist(strsplit(s, ' '))
        
        wd1<-tolower(paste0("'",s[length(s)-2],"'"))
        wd2<-tolower(paste0("'",s[length(s)-1],"'"))
        wd3<-tolower(paste0("'",s[length(s)],"'"))
        
        con <- dbConnect(SQLite(), dbname=db)

        g4<-dbGetQuery(con,paste("select w4,freq from db4 where w1=",
                                  wd1," and w2=",wd2," and w3=",wd3,sep=""))
        f43<-sum(g4$freq)
        #g43<-dbGetQuery(con3,paste("select freq from dt3cc where w1=",wd1," and w2=",wd2," and w3=",wd3,sep=""))
        r4<-c()
        p4<-c()
        if(nrow(g4)!=0){
                #g4$p<-g4$freq/g43$freq[[1]]
                g4$p<-g4$freq/f43
                r4<-g4$w4
                p4<-g4$p
        }
        
        g3<-dbGetQuery(con,paste("select w3,freq from db3 where w1=",wd2," and w2=",wd3,sep=""))
        #g32<-dbGetQuery(con2,paste("select freq from dt2cc where w1=",wd2,"and w2=",wd3,sep=""))
        f32<-sum(g3$freq)
        r3<-c()
        p3<-c()
        if(nrow(g3)!=0){
                #g3$p<-g3$freq/g32$freq[[1]]*0.4
                g3$p<-g3$freq/f32*0.4
                r3<-g3$w3
                p3<-g3$p
        }
        
        
        g2<-dbGetQuery(con,paste("select w2,freq from db2 where w1=",wd3,sep=""))
        #g21<-dbGetQuery(con1,paste("select freq from dt1 where w1=",wd3,sep=""))
        f21<-sum(g2$freq)
        r2<-c()
        p2<-c()
        if(nrow(g2)!=0){
                #g2$p<-g2$freq/g21$freq[[1]]*0.4*0.4
                g2$p<-g2$freq/f21*0.4*0.4
                r2<-g2$w2
                p2<-g2$p
        }
        g1<-dbGetQuery(con,"select w1,freq from db1 where freq=(select max(freq) from db1)")
        s1<-dbGetQuery(con,"select sum(freq) from db1")
        r1<-g1$w1[[1]]
        p1<-g1$freq[[1]]/s1[[1]]*0.4*0.4*0.4
        
        r<-c(r4,r3,r2,r1)
        p<-c(p4,p3,p2,p1)
        
        if (length(r)>1) {
                rp<-cbind(r,p)
                rp<-rp[!duplicated(r),]
                res <- data.table(rp)
                res$p<-as.numeric(res$p)
                res<-as.character(res[order(res$p,decreasing=T),]$r)
                
                if(nres>=length(res)){
                        return(res[1:length(res)])
                }
                return(res[1:nres])
        }
        else{
                return (r)
        }
}


test<-readLines("test_corpus.txt")

predictSBO("if i agree",5,"ngram4.db")



predictSBO("may the force be with",5,"ngram4.db")
predictSBO("He     23-32-9- 37373 did??? 23524525 2523534 ////'[[;[;[;[",5,"ngram4.db")
predictSBO("jimmy fallon show my",5,"ngram4.db")
predictSBO(test,5,"ngram4.db")


cleanInput("jimmy fallon show you how to make")

word("Very early observations on the Bills game: Offense still struggling, but, the!", -3:-1)


con2cc <- dbConnect(SQLite(), dbname="dt2cc.db")
dbGetQuery(con2cc,"CREATE INDEX index_w1 ON dt2cc (w1)")

start.time <- Sys.time()
predictSBO("what is love",5,"ngram4.db")
end.time <- Sys.time()

end.time-start.time

dbGetQuery(con1,"select * from dt1 limit 10")



dt4cc<-dbGetQuery(con1,"select w1,w2,w3,w4,freq from dt4c")
saveDB(dt4cc,"dt4cc")



rm(dt3cc)
test <- tbl(src_sqlite("dt4c.db"), "dt4c")



con1c <- dbConnect(SQLite(), dbname="dt1.db")




dt2cc<-dbGetQuery(con1c,"select w1,freq from dt1")

con <- dbConnect(SQLite(), "ngram4.db")
dbGetQuery(con,"CREATE INDEX index_db1_freq ON db1 (freq)")


dbWriteTable(con, "db1", dt2cc)
dbDisconnect(con)



dt2


end.time<-Sys.time()
print(end.time)


library(ggplot2)
accuracy<-c(0.05,0.13,0.15,0.16,0.21)
runtime<-c(0.12,0.12,0.12,0.13,0.5)
storage<-c(0.03,0.13,0.35,0.58,12)
models<-c("1-Gram Full","2-Gram Trunc","3-Gram Trunc","4-Gram Trunc","4-Gram Full")
performance<-as.data.frame(rbind(accuracy,runtime,storage))
names(performance)<-models


qplot(performance)
ggplot(data=performance, aes(x=models, y=storage)) +
        geom_bar(colour="black", stat="identity") +
        guides(fill=FALSE)
barplot(performance)