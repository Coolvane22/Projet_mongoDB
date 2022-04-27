################################################################################
#### librairies
lib <- c("shiny", "bs4Dash","shinyWidgets","tidyverse", "mongolite", "rlist", 
         "visNetwork", "plotly", "shinyjs", "jsonlite")
sapply(lib, require, character = TRUE)


################################################################################
#### base publications

### connexion a la base de donnees
mdb_publi = mongo(
  collection = "hal_irisa_2021",
  url = "mongodb+srv://etudiant:ur2@clusterm1.0rm7t.mongodb.net/publications",
  verbose = TRUE
)

### on garde uniquement les 20 auteurs qui ont participe a l'ecriture du plus grand nombre d'articles et pour chaque auteur on recupere la liste de ses publications
req2 <- '[
  {"$unwind" : "$authors"},
  {"$group" : {"_id" : "$authors",
               "liste_publi" : {"$push" : {"halId" : "$halId"} },
               "nb": {"$sum" : 1} }
  },
  {"$sort" : {"nb" : -1} },
  {"$limit" : 20}
]'

publi = mdb_publi$aggregate(pipeline = req2)

# on stocke dans un tibble avec une structure plus claire (une colonne pour name et firstname)
publi <- tibble(
  name = publi$"_id"$name,
  firstname = publi$"_id"$firstname,
  liste_publi = publi$liste_publi,
  nb = publi$nb
) %>%
  # on ajoute une colonne qui contient le nom et prenom de chaque auteur
  mutate("nom_prenom" = paste(name, firstname, sep = " ")) 


### liens entre auteurs (co-publications)
publi_final <- publi %>%
  # on souhaites qu'il y ai autant de lignes par auteur qu'il a participe a des publications
  select(nom_prenom, liste_publi) %>%
  unnest_longer(liste_publi)

## les differentes paires d'auteurs possible
v <- distinct(publi_final, nom_prenom) %>% pull()
paires_auteurs <- expand.grid("auteur1" = v , "auteur2" = v) %>% 
  filter(auteur1 != auteur2)

## on veut le nombre de publications en commun entre chaque paire d'auteurs
crosstable <- table(publi_final$liste_publi$halId, publi_final$nom_prenom)

paires_auteurs$nb_publi_commun <- apply(paires_auteurs, MARGIN = 1, FUN = function(x){
  i = 1
  vec = c()
  while(i <= nrow(crosstable)){
    vec = c(vec, sum(crosstable[i,c(x[1],x[2])][1] == 1 & crosstable[i,c(x[1],x[2])][2] == 1))
    i = i +1
  }
  x[3] = sum(vec)
})

### donnees pour visualisation
## noeuds 
nodes <- publi %>% 
  select(nom_prenom, nb) %>% 
  # ajout d'un groupe pour chaque auteur en fonction du nombre de publications
  mutate(group = ifelse(nb>12,"High", ifelse(nb>10, "Medium", "Low"))) %>% 
  select(-nb) %>% 
  dplyr::rename(id = nom_prenom) %>% 
  mutate("title" = id)

## liens
edges <- paires_auteurs %>% 
  filter(nb_publi_commun != 0) %>% 
  dplyr::rename(from = auteur1, to = auteur2, weight = nb_publi_commun) %>% 
  mutate(value = weight)


################################################################################
#### base NYfood
mdb_food = mongo(
  collection = "NYfood",
  url = "mongodb+srv://etudiant:ur2@clusterm1.0rm7t.mongodb.net/food",
  verbose = TRUE
)
### requete du premier graphique
req31 <- '[
{"$group": {"_id" : {"cuisine" : "$cuisine", "quartier" :  "$borough"},
                "nb" : {"$sum" : 1}}
},
    {"$match": {"nb": {"$gt": 150}}},
    {"$sort" : {"nb" : -1}}
]'

food <- mdb_food$aggregate(pipeline = req31) %>% 
  dplyr::rename("id" = "_id")

### requete du deuxieme graphique
# {$month: "$grades.date"}
# 'lubridate::month('   ')'
req32 <- '[
  {"$unwind": "$grades"},
  {"$match": {"grades.grade": {"$ne": "Not Yet Graded"}}},
  {"$match": {"borough": {"$ne": "Missing"}}},
  {"$group":{
     "_id": {
            "month" : {"$month": "$grades.date"},
            "name" : "$name",
            "borough" : "$borough"
     },
     "nb": {"$sum":1}
    }
  },
  {"$group":{
    "_id": {
          "month" : "$_id.month",
          "borough" : "$_id.borough"
    },
    "nb_max" : {"$max" : "$nb"}
    }
  },
  {"$sort": {"_id.month":1,"_id.borough":1}}       
]'

food2 <- mdb_food$aggregate(pipeline = req32) %>% 
  dplyr::rename("id" = "_id")
