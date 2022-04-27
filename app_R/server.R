#### SERVER
shinyServer(function(input, output) {
  
  ### graphique du reseaux des publications
  output$reseaux <- renderVisNetwork({
    visNetwork(nodes, edges) %>% 
      visInteraction(dragView = TRUE, navigationButtons = TRUE) %>%
      visPhysics(solver = "forceAtlas2Based", 
                 forceAtlas2Based = list(gravitationalConstant = -60)) %>%
      visLayout(randomSeed = 12) %>% 
      # choix du groupe 
      visOptions(selectedBy = "group", highlightNearest = list(enabled = T, degree = 1, hover = T))
  })
  
  ### graphique proportion d'un type de restaurant par quartier
  output$plot_type <- renderPlotly({
    type <- food %>%
      filter(id$cuisine == input$choix_type_cuisine)

    plot_ly(type, labels = ~id$quartier, values = ~nb, type = 'pie') %>%
      layout(title = "Distribution par quartier" )
  })
  
  ### graphique 2
  
})

