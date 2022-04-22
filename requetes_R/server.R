#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
   
    
    output$plot_type <- renderPlotly({

       type <- data%>% filter(id$cuisine == input$choix_type_cuisine)
       plot_ly(type, labels = ~id$quartier, values = ~nb, type = 'pie')%>%
           layout(title = "Distribution par quartier" )
       
       
       
       
   })

})


