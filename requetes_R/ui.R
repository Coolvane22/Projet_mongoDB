# #### LIBRAIRIES
# library(shiny)
# library(bs4Dash)
# library(tidyverse)
# library(shinyjs)
# library(visNetwork)

#### CONTENU DES PAGES
publication <- fluidRow(
  box(
    title ="Publications", 
    status = "info", 
    solidHeader = TRUE, 
    width = 12,
    collapsible = TRUE, 
    align="justify",
    "Bla bla",
    visNetworkOutput("reseaux")
  )
)
  
food <- fluidRow(
  box(
    title ="NYfood", 
    status = "info", 
    solidHeader = TRUE, 
    width = 12,
    collapsible = TRUE, 
    align="justify",
    "Bla bla"
  ),
  sidebarPanel(
    selectizeInput(
      'choix_type_cuisine', 
      'Choix du type de cuisine :',
      # choices = unique(data$id$cuisine)
      choices = c("1","2")
    )
  ),
  tabsetPanel(
    tabPanel(
      "Nombres de restaus de ce type dans chaque quartier", 
      plotlyOutput("plot_type")
    ),
    tabPanel(
      "2eme graphe", 
      plotlyOutput("plot_2")
    )
  )
)

#### UI
ui <- dashboardPage(
  options = list(sidebarExpandOnHover = FALSE),
  
  ## en-tete de la page
  dashboardHeader(
    title = "MongoDB",
    status = "teal"
  ),
  
  ## contenu de la barre de navigation
  dashboardSidebar(
    minified = TRUE,
    collapsed = TRUE,
    status = "teal",
    sidebarMenu(
      menuItem(
        "Base publications", tabName = "publi", icon = icon("book", lib="font-awesome")
      ),
      menuItem(
        "Base NYfood",tabName = "nyfood", icon = icon("cutlery", lib="font-awesome")
      )
    )
  ),
  
  ## contenu des pages
  dashboardBody(
    useShinyjs(),
    tabItems(
      # page donnees
      tabItem(tabName = "publi", publication
      ),
      
      # page carte
      tabItem(tabName = "nyfood", food
      )
    )
  ),
  
  ## parametres generaux
  dashboardControlbar(
    collapsed = TRUE,
    div(class = "p-3", skinSelector()),
    pinned = FALSE
  ),
  
  ## pied de page
  dashboardFooter(
    left = "Amélie GOUTARD, Evane Thivend",
    right = "2022"
  ),
  
  ## titre de la page dans le navigateur
  title = "MongoDB"
)



# # Define UI for application that draws a histogram
# shinyUI(fluidPage(
# 
#   # Application title
#   titlePanel("Visualisation MongoDB"),
# 
#   tabPanel("Visualisation Publications",
#            fluidRow(
#              sidebarLayout(
#                sidebarPanel(
# 
#                ),
#                mainPanel(
#                  tabsetPanel(
# 
#                  )
#                )
#              )),
#            tabPanel("Visualisation NYfood",
#                     fluidRow(
#                       sidebarLayout(
#                         sidebarPanel(
# 
#                           selectizeInput('choix_type_cuisine', 'Choix du type de cuisine :',choices=unique(data$id$cuisine)),
# 
#                         ),
#                         mainPanel(
#                           tabsetPanel(
# 
#                             tabPanel("Nombres de restaus de ce type dans chaque quartier", plotlyOutput("plot_type")),
#                             tabPanel("2eme graphe", plotlyOutput("plot_2")),
# 
#                           )
#                         )
#                       )),
#            ))
# ))
