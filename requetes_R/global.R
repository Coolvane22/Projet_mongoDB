library(shiny)
library(tidyverse)
library(mongolite)
library(rlist)
library(shinyWidgets)
library(plotly)

mdb = mongo(
  collection = "NYfood",
  url = "mongodb+srv://etudiant:ur2@clusterm1.0rm7t.mongodb.net/food",
  verbose = TRUE
)
req <- '[
{"$group": {"_id" : {"cuisine" : "$cuisine", "quartier" :  "$borough"},
                "nb" : {"$sum" : 1}}
    },
    {"$sort" : {"nb" : -1}}
]'

data <- mdb$aggregate(pipeline = req)
data <- data %>% rename("id" = "_id")