### Projet MongoDB ###
### Goutard Amélie - Thivend Evane ###

### Importation  librairie ###
from nbformat import read
from pymongo import MongoClient
from sqlalchemy import null
import pandas as pd
from bokeh.plotting import figure, output_file, show, ColumnDataSource
from bokeh.tile_providers import get_provider, Vendors
import numpy as np
import datetime


with open('identifiant.txt') as f:
    id = f.readlines()
### Connexion BDD
db_uri = id
client = MongoClient(db_uri)

# Acces bdd doctolib
db = client["doctolib"]

#print(db.list_collection_names())

# On se place dans la collection dump_Jan_2022
coll = db["dump_Jan2022"]


# Recuperation des centres de vaccination situees à moins de 50 km de Rennes:
Rennes  = {'type': 'Point', 'coordinates' :[-1.68002 , 48.111339]}
# On décide de ne garder que l'id, et les coordonées
filter_loc = {"location": {'$near': {'$geometry': Rennes, '$maxDistance': 50000}}}
filter_att = {"name": 1, "location.coordinates" : 1} 
cursor_centre_50 = coll.find(filter_loc,filter_att)
#print(len(list(cursor_centre_50)))


#Creation de la liste des noms des centres de vaccinations et des coordonnees

liste_nom = []
liste_lon = [] 
liste_lat = [] 

for rep in cursor_centre_50:
    for k, v in rep.items():

        if k == 'name':
            liste_nom.append(v)
     
        if k == 'location':
            for v1 in v.values():
                liste_lon.append(v1[0])
                liste_lat.append(v1[1])

dico = {
    'Nom': liste_nom,
    'Longitude' : liste_lon,
    'Latitude' : liste_lat
}

#Recuperation des creneaux entre le 26 et 29 janvier 2022 inclus 
filter_geoNear = {'$geoNear': {'near': Rennes,'key' : "location",'distanceField': "distance",'maxDistance': 50000}}
filter1_unwind = {'$unwind': "$visit_motives"}
filter2_unwind = {'$unwind': "$visit_motives.slots"}
filter_match = {'$match': {"visit_motives.slots":{'$gte':datetime.datetime.strptime("2022-01-26", "%Y-%m-%d"),'$lte':datetime.datetime.strptime("2022-01-29", "%Y-%m-%d")}}}


cursor_creneaux = coll.aggregate([filter_geoNear, filter1_unwind, filter2_unwind,filter_match , {'$group': {'_id': {' nom' : "$name"}, 'nb': {'$sum':1}}}, ])

#On calcule la moyenne pour déterminer le seuil orange/vert
cursor_moyenne = coll.aggregate([filter_geoNear, filter1_unwind, filter2_unwind,filter_match , {'$group': {'_id': {' nom' : "$name"}, 'nb': {'$sum':1}}},    {'$group': {'_id': { 'nom' : "$name"},'nb': {'$avg':"$nb"}}}, ])

for rep in cursor_moyenne:
    moyenne = rep['nb']

liste_nom_ouvert = []
for rep in cursor_creneaux:
     for k, v in rep.items():
         if k == 'name':
             liste_nom_ouvert.append(v)
         if k == ''
# #Creation dun dataset pour l'utilisation des cartes Bokeh
# data = pd.DataFrame(dico)


# # Création de l'output HTML
# output_file("Projet_MongoDB_Python.html")

# #Creation de la figure 
# ## Nous transformons donc les points GPS:
# k = 6378137

# data['Longitude'] = data['Longitude']  * (k * np.pi / 180.0)
# data['Latitude'] = np.log(np.tan((90 + data['Latitude']) * np.pi / 360.0)) * k

# data_source = ColumnDataSource(data)

# # ## Chargement du fond de carte 
# tile_provider = get_provider(Vendors.CARTODBPOSITRON)

# # # Creation tools
# tools = "pan,wheel_zoom,box_zoom,reset"
# TOOLTIPS = [
#     ('Nom', '@Nom'),
#     ]

# # Initialisation figure
# c = figure(
#            x_axis_type="mercator", y_axis_type="mercator",
#            title = "Carte des centres de vaccinations autour de Rennes",
#            tooltips=TOOLTIPS,
#            tools=tools,
#            plot_width=900,
#            plot_height=600
#            )

# # Ajout du fond de carte 
# c.add_tile(tile_provider)

# #Ajout point 
# c.scatter(x='Longitude', y='Latitude', size=12, alpha=0.5, source=data_source,  
#                 )
# show(c)
