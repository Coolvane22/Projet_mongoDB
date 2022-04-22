#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

loadData <- function(qry){
    mdb = mongo(
        collection = "NYfood",
        url = "mongodb+srv://etudiant:ur2@clusterm1.0rm7t.mongodb.net/food",
        verbose = TRUE
    )
    
    df <- mdb$aggregate(pipeline = qry)
    return(df)
}

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    data <- reactive({
      qry <-  paste0('[
            {"$group": {"_id" : {"cuisine" : "', input$choix_type_cuisine ,'" , "quartier" :  "$borough"},
                "nb" : {"$sum" : 1}}
            },
            {"$sort" : {"nb" : -1}}
            ]')
        data <- loadData(qry)
        return(data)
        
    })

    
    output$plot_type <- renderPlotly({
        data <- data() %>% rename("id" = "_id")
        
      # type <- data %>% filter(id$cuisine == input$choix_type_cuisine)
       plot_ly(data(), labels = ~id$quartier, values = ~nb, type = 'pie')%>%
           layout(title = "Distribution par quartier pour",input$choix_type_cuisine )
       
       
       
       
   })

})


