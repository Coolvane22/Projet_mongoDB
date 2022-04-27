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

    plot_ly(type, labels = ~id$quartier, values = ~nb, type = 'pie',
            marker = list(colors = c("#EC8C74", "#E76F51", "#F4A261", "#E9C46A", "#2A9D8F"),
                          line = list(color = '#FFFFFF', width = 1))) %>%
      layout(title = "Distribution du type de restaurant par quartier" )
  })
  
  ### graphique nombre maximal de notes d'un mois par quartier
  output$plot_mois <- renderPlotly({
    mois <- food2 %>%
      filter(id$month == as.integer(input$choix_mois))

    plot_ly(mois, x = ~id$borough, y = ~nb_max, type = 'bar', color=~id$borough) %>%
      layout(title = "Nombre maximum de notes en fonction du quartier pour le mois choisi",
             xaxis = list(title="Quartiers"), 
             yaxis = list(title="Nombre maximum de notes"))
  })
  
})

