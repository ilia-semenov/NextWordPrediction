library('shiny')
library('sqldf')
library('RSQLite')
library('dplyr')
library('data.table')
library('stringr')
library('shinyjs')



# Using the cars dataset (vehicle speed and corresponding stopping distance
# statistics), train a simple linearregression model. After the model selection
# process the regression through origin model dist=b*speed^2 was chosen:
# coefficient b is significant at 0% level, Adj. R-squared is 0.9025.

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
#dist_pred<-function (s) predict(mod.lm,data.frame(speed=s))


# Define server logic required to output stopping distance
shinyServer(function(input, output,session) {
        
        
        
        # Expression that generates output. renderText is used to
        # use reactivity feature (output changes once the input is changed).
        # Different output is generated for different metric systems.
        
        pr<<-NULL
        g<<-0
        d<<-0
        output$text_out <- renderText({
                input$text
        })
        
        output$word_out <- reactive({ 
                if (g==1) {
                        pr<-predictSBO(input$text,5,"data/ngram4.db")
                        pr<-na.exclude(pr)
                        rand<-sample(1:length(pr),1)
                        updateTextInput(session,"text", 
                                        value = paste(input$text,pr[rand]))
                        paste("<i>Machine predicts that the next word is:</i><b>",
                              pr[rand])
                }
                else{
                        pr<<-predictSBO(input$text,5,"data/ngram4.db")

                        output$w1 <- renderUI({
                                actionButton(style="background-color:white;color:black","preds", pr[1])
                        })
                        if(!is.na(pr[2])){
                        output$w2 <- renderUI({
                                actionButton(style="background-color:white;color:black","preds2", pr[2])
                        })
                        }
                        if(!is.na(pr[3])){
                        output$w3 <- renderUI({
                                actionButton(style="background-color:white;color:black","preds3", pr[3])
                        })
                        }
                        if(!is.na(pr[4])){
                        output$w4 <- renderUI({
                                actionButton(style="background-color:white;color:black","preds4", pr[4])
                        })
                        }
                        if(!is.na(pr[5])){
                        output$w5 <- renderUI({
                                actionButton(style="background-color:white;color:black","preds5", pr[5])
                        })
                        }
                        
                        paste("<i>Machine predicts that the next word is:</i><b>",
                              pr[1])
                        
                        
                        
                }
                
        })
        observeEvent(input$preds, {
                updateTextInput(session,"text", value = paste(input$text, 
                                                              pr[1]))
        })
        observeEvent(input$preds2, {
                updateTextInput(session,"text", value = paste(input$text, 
                                                              pr[2]))
        })
        observeEvent(input$preds3, {
                updateTextInput(session,"text", value = paste(input$text, 
                                                              pr[3]))
        })
        observeEvent(input$preds4, {
                updateTextInput(session,"text", value = paste(input$text, 
                                                              pr[4]))
        })
        observeEvent(input$preds5, {
                updateTextInput(session,"text", value = paste(input$text, 
                                                              pr[5]))
        })
        
        observeEvent(input$gen, {
                g<<-1
                hide(id = "gen_but", anim = TRUE)
                output$stop <- renderUI({
                        actionButton("stop", "Stop")
                })
                updateTextInput(session,"text", value = paste(input$text, 
                                                              pr[1]))
                show(id = "stop_but", anim = TRUE)
                
        })
        
        observeEvent(input$stop, {
                g<<-0
                show(id = "gen_but", anim = TRUE)
                hide(id = "stop_but", anim = TRUE)
        })
        
        observeEvent(input$docb, {
                hide(id = "doc_but", anim = TRUE)
                output$cdocb <- renderUI({
                        actionButton("cdocb", "Hide documentation")
                })
                show(id = "cdoc_but", anim = TRUE)
                show(id = "doc", anim = TRUE)
                
        })
        
        observeEvent(input$cdocb, {
                show(id = "doc_but", anim = TRUE)
                hide(id = "cdoc_but", anim = TRUE)
                hide(id = "doc", anim = TRUE)
        })
        
        
        
        
        
})

