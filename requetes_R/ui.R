#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#



# Define UI for application that draws a histogram
shinyUI(fluidPage(
    
    # Application title
    titlePanel("Visualisation MongoDB"),
    
    tabPanel("Visualisation Publications",
             fluidRow(
                 sidebarLayout(
                     sidebarPanel(
                        
                     ),
                     mainPanel(
                         tabsetPanel(
                            
                         )
                     )
                 )),
             tabPanel("Visualisation NYfood",
                      fluidRow(
                          sidebarLayout(
                              sidebarPanel(
                                  
                                  selectizeInput('choix_type_cuisine', 'Choix du type de cuisine :',choices=unique(data$id$cuisine)),
                                  
                              ),
                              mainPanel(
                                  tabsetPanel(

                                      tabPanel("Nombres de restaus de ce type dans chaque quartier", plotlyOutput("plot_type")),
                                      tabPanel("2eme graphe", plotlyOutput("plot_2")),
                                     
                                  )
                              )
                          )),
             ))
))
    