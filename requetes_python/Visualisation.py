### Projet MongoDB ###
### Goutard Amélie - Thivend Evane ###

### Importation  librairie ###
from nbformat import read
from pymongo import MongoClient

with open('identifiant.txt') as f:
    id = f.readlines()
### Connexion BDD
db_uri = id
client = MongoClient(db_uri)

# Accès bdd doctolib
db = client["doctolib"]

print(db.list_collection_names())

# On se place dans la collection dump_Jan_2022
coll = db["dump_Jan2022"]

#Test de connexion 
query = {"name" : {"$regex": "^R"}}
cursor = coll.find(query)
print(list(cursor))

# Récupération des centres de vaccination situées à moins de 50 km de Rennes:
# On décide de ne garder que l'id, et les coordonées
