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
