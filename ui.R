
if (!require(shiny)) {
  install.packages("shiny")
}
library(shiny)


if (!require(leaflet)) {
  install.packages("leaflet")
}
library(leaflet)


shinyUI(fluidPage(
# Application title
    titlePanel("COVID-MAP"),
    
    sidebarLayout(
        sidebarPanel(
                     h4("アニメーションの設定"),
                     uiOutput("date1"),
                     uiOutput("date2"),
                     numericInput("w",label = h5("累積日数を入力"),value="7"),
                     numericInput("x",label = h5("アニメーションの日数の間隔を入力"),value="3"),
                     numericInput("en",label = h5("円の大きさを指定"),value="10"),
                     actionButton("submit", "描画"),
                     downloadButton('downloadData', 'GIF Download')
                    
                     
                     ),
        
        
        
        # Show a plot of the generated distribution
        mainPanel(
            imageOutput("anime")
        )
    )


)
)
