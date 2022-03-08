
if (!require(htmltools)) {
  install.packages("htmltools")
}
library(htmltools)

if (!require(dplyr)) {
  install.packages("dplyr")
}
library(dplyr)
if (!require(data.table)) {
  install.packages("data.table")
}
library(data.table)

if (!require(lubridate)) {
  install.packages("lubridate")
}
library(lubridate)

if (!require(rsconnect)) {
  install.packages("rsconnect")
}
library(rsconnect)

if (!require(mapview)) {
    install.packages("mapview")
}
library(mapview)
if (!require(magick)) {
    install.packages("magick")
}
library(stringr)
if (!require(stringr)) {
  install.packages("stringr")
}
library(magick)
if (!require(webshot)) {
    install.packages("webshot")
   
}


webshot :: install_phantomjs()




shinyServer(function(input, output, session) {

  data2020 <-
    fread("https://raw.githubusercontent.com/tanamym/covid19_colopressmap_isehara/main/data2020.csv",encoding="UTF-8")
  
  data202106 <-
    fread("https://raw.githubusercontent.com/tanamym/covid19_colopressmap_isehara/main/data202106.csv",encoding="UTF-8")
  data202109 <-
    fread("https://raw.githubusercontent.com/tanamym/covid19_colopressmap_isehara/main/data202109.csv",encoding="UTF-8")
  
  data202201 <-
    fread("https://raw.githubusercontent.com/tanamym/covid19_colopressmap_isehara/main/data202201.csv",encoding="UTF-8")
  data20220215 <-
    fread("https://raw.githubusercontent.com/tanamym/covid19_colopressmap_isehara/main/data20220215.csv",encoding="UTF-8")
  data20220228 <-
    fread("https://raw.githubusercontent.com/tanamym/covid19_colopressmap_isehara/main/data20220228.csv",encoding="UTF-8")
  data2022 <-
    fread("https://raw.githubusercontent.com/tanamym/covid19_colopressmap_isehara/main/data2022.csv",encoding="UTF-8")
  ycd <-
    fread("https://raw.githubusercontent.com/tanamym/covid19_colopressmap_isehara/main/yoko_covid.csv",encoding="UTF-8") %>%
    mutate(Fixed_Date=as.Date(Date),
           Residential_City=City)
  data7 <-
    rbind(data2020,data202106,data202109,data202201,data20220215,data20220228,data2022) %>%
    mutate(Fixed_Date=as.Date(Fixed_Date)) %>%
    arrange(desc(Fixed_Date),Hos,hos)%>%
    count(Fixed_Date,Residential_City,hos,X,Y)%>%
    full_join(ycd%>%
                mutate(hos="yokohama"))%>%
    mutate(Residential_City=ifelse(!is.na(City),City,Residential_City)) %>%
    mutate(n=ifelse(!is.na(City),count,n))
  
  
 
  date<-
    data7%>%
    data.frame()%>%
    arrange(desc(Fixed_Date))%>%
    distinct(Fixed_Date)
    output$date1<-
      renderUI({
        dateInput("z1",
                  label = h5("アニメーションの開始日を入力"),
                  max = date[1,1],value = date[1,1])
      })
    output$date2<-
      renderUI({
        dateInput("z2",
                  label = h5("アニメーションの終了日を入力"),
                  max = date[1,1],value = date[1,1])
      })
    

    jinko<-read.csv("jinko.csv")
    jinko<-data.frame(jinko)

    l1=function(a,b){
       #集計
       data7.1<-data7%>%
         filter(Fixed_Date>=a,Fixed_Date<=b)%>%
         group_by(Residential_City,X,Y)%>%
         summarise(count=sum(n))%>%
         filter(X>0,Y>0)
       jinko2<-left_join(data7.1,jinko,by=c("Residential_City"="City"))
       jinko3<-jinko2%>%
         mutate(count_j=count/jinko*100000)
       leaflet(jinko3) %>% addTiles() %>%
         addProviderTiles(providers$CartoDB.Positron) %>%
         #setView(lng=139.4025,lat=35.4478,zoom=10)%>%
         fitBounds(lng1=139.124343, lat1=35.117843, lng2=139.652899, lat2=35.665052)%>%
         addCircleMarkers(~X, ~Y, stroke=FALSE,
                          radius =sqrt(jinko3$count_j)*input$en,
                          label = ~htmlEscape(Residential_City),
                          labelOptions = labelOptions(direction = 'auto',noHide = T, textOnly = TRUE,textsize = "10px"))%>%
         addCircleMarkers(~X, ~Y, stroke=FALSE,
                          radius =sqrt(jinko3$count_j)*input$en,
                          label = ~htmlEscape(round(count_j,digits = 4)),
                          labelOptions = labelOptions(direction = 'bottom',noHide = T, textOnly = TRUE,textsize = "10px")
                          
                          
         )%>%addControl(tags$div(HTML(paste(a,b,sep = "~")))  , position = "topright")
       
       
    }
    
   output$anime<-renderImage({
     num<-
         as.numeric(lubridate::ymd(input$z2)-lubridate::ymd(input$z1))
       num2<-
         num%/%input$x
     action<-eventReactive(input$submit,{
       
      for (i in 1:num2) {
        date<-lubridate::ymd(input$z2)-input$x*(num2-i)
       date2<-lubridate::ymd(input$z2)-input$w-input$x*(num2-i)+1
       map<-l1(date2,date)
       mapshot(map, file =paste0("map_", formatC(i,width=2,flag="0"), ".png"))
      }
      
     file_names <- list.files(pattern = "map_\\d+.png$", full.names = TRUE)

     image_read(file_names) %>%
       image_animate(fps = 1) %>%
       image_write("output.gif")
     width  <- session$clientData$output_anime_width
     height <- session$clientData$output_anime_height
     list(src = "output.gif",
          contentType = 'image/gif',
          width = width,
          height = height,
          alt = "This is alternate text")
     })
     action()
     
     
   }, deleteFile = TRUE)
   
   output$downloadData <- downloadHandler(
     filename = "covid.gif",
     contentType = 'image/gif',
     content = function(file){
       num<-
         as.numeric(lubridate::ymd(input$z2)-lubridate::ymd(input$z1))
       num2<-
         num%/%input$x
       for (i in 1:num2) {
         date<-lubridate::ymd(input$z2)-input$x*(num2-i)
         date2<-lubridate::ymd(input$z2)-input$w-input$x*(num2-i)+1
         map<-l1(date2,date)
         mapshot(map, file =paste0("map_", formatC(i,width=2,flag="0"), ".png"))
       }
       
       
       file_names <- list.files(pattern = "map_\\d+.png$", full.names = TRUE)

       g1<-image_read(file_names) %>%
         image_animate(fps = 1)%>%
         image_write(file)


     }
     
   )

   
})
