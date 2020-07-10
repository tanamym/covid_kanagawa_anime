#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

if (!require(shiny)) {
  install.packages("shiny")
}
library(shiny)


if (!require(leaflet)) {
  install.packages("leaflet")
}
library(leaflet)

#tmp.enc <- options()$encoding #標準コーディングを記録（native.encであることが多いです）
#options(encoding = "UTF-8") #エンコーディングをUTF-8に変更
#deployApp()
#options(encoding = tmp.enc) #エンコーディングをもとに戻す
# Define UI for application that draws a histogram
shinyUI(fluidPage(
# Application title
    titlePanel("COVID-MAP"),
    
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
                     h4("アニメーションの設定"),
                     dateInput("z",label = h5("アニメーションが終わる日付を入力"),value = Sys.Date()),
                     numericInput("w",label = h5("アニメーションの日数の間隔を入力"),value="5")
                     
                     ),
        
        
        
        # Show a plot of the generated distribution
        mainPanel(
            h5("アニメーション"),
            imageOutput("anime")
        )
    )


)
)
