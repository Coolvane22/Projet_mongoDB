#### CONTENU DES PAGES
publication <- fluidRow(
    box(
      title =tagList(icon("book-reader"), "  Publication"), 
      status = "info", 
      solidHeader = TRUE, 
      width = 12,
      collapsible = TRUE, 
      align="justify",
      "La base de données 'publications' contient les informations relatives 
    aux publications de scientifiques du laboratoire IRISA pour l'année 2021.", br(),
      "Le graphique ci-dessous permet de visualiser les liens entre les auteurs
    de ces publications. Nous avons uniquement gardé les 20 auteurs qui ont 
    participé à l'écriture du plus grand nombre d'articles.", br(),
      "Vous pouvez choisir de visualiser plus particulièrement un groupe d'auteurs.
    En effet, nous avons regroupé les auteurs en 3 catégories, selon leur nombres de
    publications. Les auteurs ayant un nombre de publication supérieur à 12 sont 
    considérés commes 'High'. Ceux qui ont participés à 11 ou 12 publications comme 
    'Medium' et enfin ceux qui ont un nombre de publications inférieur à 11 comme 'Low' ", 
      br(), "Aussi, l'épaisseur des traits varie en fonction du nombre de publication en commun
    entre auteurs."
    ),
    box(
      title = tagList(icon("project-diagram"), "  Représentation des liens"), 
      status = "info", 
      solidHeader = TRUE,
      collapsible = TRUE,
      width = 12,
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
  tabBox(
    width = 12,
    title = "Graphiques",
    status = "purple",
    collapsible = TRUE,
    id = "tabset1",
    side = "right",
    tabPanel(
      tagList(icon("chart-pie"), "  Graph 1"),
      selectizeInput(
        'choix_type_cuisine', 
        'Choix du type de cuisine :',
        choices = unique(food$id$cuisine)
      ),
      plotlyOutput("plot_type")
    ),
    tabPanel(
      tagList(icon("chart-pie"), "  Graph 2"),
      "bla bla"
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
        "Base NYfood",tabName = "nyfood", icon = icon("fas fa-utensils", lib="font-awesome")
      ),
      menuItem(
        "Page présentation",tabName = "nyfood", icon = icon("home", lib="font-awesome")
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
