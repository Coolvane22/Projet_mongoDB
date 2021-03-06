### Projet MongoDB ###
### Goutard Amélie - Thivend Evane ###

### Importation  librairie ###
from os import kill
from nbformat import read
from pymongo import MongoClient
from sqlalchemy import null, true
import pandas as pd
from bokeh.plotting import figure, output_file, show, ColumnDataSource
from bokeh.tile_providers import get_provider, Vendors
from bokeh.layouts import row, column
from bokeh.models.widgets import Tabs, Panel
from bokeh.models import  Div
import numpy as np
import datetime
import statistics


# Ouverture du fichier avec identifiant de connexion
with open('identifiant.txt') as f:
    id = f.readlines()

### Connexion BDD
db_uri = id
client = MongoClient(db_uri)

# Acces bdd doctolib
db = client["doctolib"]

# On se place dans la collection dump_Jan_2022
coll = db["dump_Jan2022"]


# Recuperation des centres de vaccination situees à moins de 50 km de Rennes:
Rennes  = {'type': 'Point', 'coordinates' :[-1.68002 , 48.111339]}

# On décide de ne garder que le nom  et les coordonnées
filter_loc = {"location": {'$near': {'$geometry': Rennes, '$maxDistance': 50000}}}
filter_att = {"name": 1, "location.coordinates" : 1} 
cursor_centre_50 = coll.find(filter_loc,filter_att)


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



#Recuperation des creneaux entre le 26 et 29 janvier 2022 inclus 
filter_geoNear = {'$geoNear': {'near': Rennes,'key' : "location",'distanceField': "distance",'maxDistance': 50000}}
filter1_unwind = {'$unwind': "$visit_motives"}
filter2_unwind = {'$unwind': "$visit_motives.slots"}
filter_match = {'$match': {"visit_motives.slots":{'$gte':datetime.datetime.strptime("2022-01-26", "%Y-%m-%d"),'$lte':datetime.datetime.strptime("2022-01-29", "%Y-%m-%d")}}}


cursor_creneaux = coll.aggregate([filter_geoNear, filter1_unwind, filter2_unwind,filter_match , {'$group': {'_id': {' nom' : "$name"}, 'nb': {'$sum':1}}}, ])

#On calcule la moyenne pour déterminer le seuil orange/vert
cursor_moyenne = coll.aggregate([filter_geoNear, filter1_unwind, filter2_unwind,filter_match , {'$group': {'_id': {' nom' : "$name"}, 'nb': {'$sum':1}}},    {'$group': {'_id': { 'nom' : "$name"},'nb': {'$avg':"$nb"}}}, ])

# for rep in cursor_moyenne:
#     moyenne = rep['nb']

# #On voit que la moyenne est tres eleve a cause de la valeur egal a 328
# #On décide donc d'utiliser la médiane pour la valeur de seuil
# #L'opérateur médiane n'existe pas dans les opérateurs d'aggregation en mongoDB
# #On la calcule grâce au package statistics sur python 

liste_nom_ouvert = []
liste_creneau = []
for rep in cursor_creneaux:    
    for k, v in rep.items():
        if k == '_id':
            for v1 in v.values():
                liste_nom_ouvert.append(v1)
        if k == 'nb':
            liste_creneau.append(v)
mediane = statistics.median(liste_creneau)

# # # # Creation dun dataset pour l'utilisation des cartes Bokeh
# Creation d'un dictionnnaire nom du centre : creneaux disponibles
keys_list = liste_nom_ouvert
values_list = liste_creneau
zip_iterator = zip(keys_list, values_list)
dico_creneau = dict(zip_iterator)

dico_creneau_tot = {}
for nom in liste_nom:
    if nom in dico_creneau.keys():
        dico_creneau_tot[nom] = dico_creneau[nom]
    else:
        dico_creneau_tot[nom] = 0

# Creation d'une liste des couleurs correspondants aux creneaux disposnibles
# Rouge si aucun créneau disponible, orange si inférieur à la médiane et vert si supérieur à la médiane
color = []
for v in dico_creneau_tot.values():
    if int(v) == 0:
        color.append('red')
    elif  int(v) > mediane:
        color.append('green')
    else:
        color.append('orange')


dico = {
    'Nom': liste_nom,
    'Longitude' : liste_lon,
    'Latitude' : liste_lat,
    'Creneau' : dico_creneau_tot.values() ,
    'Color' : color
}
data = pd.DataFrame(dico)

# Création de l'output HTML
output_file("Projet_MongoDB_Python.html")

#Creation de la figure 
# # Nous transformons donc les points GPS:
k = 6378137

data['Longitude'] = data['Longitude']  * (k * np.pi / 180.0)
data['Latitude'] = np.log(np.tan((90 + data['Latitude']) * np.pi / 360.0)) * k

data_source = ColumnDataSource(data)

# # # Chargement du fond de carte 
tile_provider = get_provider(Vendors.CARTODBPOSITRON)

# # Creation tools
tools = "pan,wheel_zoom,box_zoom,reset"
TOOLTIPS = [
    ('Nom', '@Nom'),
    ('Créneau','@Creneau')
    ]

# Initialisation figure
c = figure(
           x_axis_type="mercator", y_axis_type="mercator",
           title = "Carte des centres de vaccinations autour de Rennes",
           tooltips=TOOLTIPS,
           tools=tools,
           plot_width=900,
           plot_height=600
           )

# Ajout du fond de carte 
c.add_tile(tile_provider)

#Ajout des points avec la couleur  adaptee

c.scatter(x='Longitude', y='Latitude', size=12, alpha=0.5, source=data_source,  color = 'Color'        )


### 2eme visualisation : Première dose du vaccin 

## On recupere les nombres de créneau disponible pour les premieres doses  pour les 1 eres doses
filter_match_first_shot = {'$match' :{ "visit_motives.first_shot_motive" : True}}
filter_match_date = {'$match': {"visit_motives.slots":{'$gte':datetime.datetime.strptime("2022-01-01", "%Y-%m-%d"),'$lte':datetime.datetime.strptime("2022-06-01", "%Y-%m-%d")}}}

cursor_creneaux_1 = coll.aggregate([filter_geoNear, filter1_unwind, filter_match_first_shot, filter2_unwind,filter_match_date , {'$group': {'_id': {' nom' : "$name"}, 'nb': {'$sum':1}}}, ])

liste_nom_ouvert_1 = []
liste_creneau_1 = []
for rep in cursor_creneaux_1:    
    for k, v in rep.items():
        if k == '_id':
            for v1 in v.values():
                liste_nom_ouvert_1.append(v1)
        if k == 'nb':
            
            liste_creneau_1.append(v)
mediane = statistics.median(liste_creneau_1)

# # # Creation dun dataset pour l'utilisation des cartes Bokeh
# Creation d'un dictionnnaire nom du centre : creneaux disponibles
keys_list = liste_nom_ouvert_1
values_list = liste_creneau_1
zip_iterator = zip(keys_list, values_list)
dico_creneau_1 = dict(zip_iterator)

dico_creneau_tot_1 = {}
for nom in liste_nom:
    if nom in dico_creneau_1.keys():
        dico_creneau_tot_1[nom] = dico_creneau_1[nom]
    else:
        dico_creneau_tot_1[nom] = 0

# Creation d'une liste des couleurs correspondants aux creneaux disposnibles
# Rouge si aucun créneau disponible, orange si inférieur à la médiane et vert si supérieur à la médiane
color_1 = []
for v in dico_creneau_tot_1.values():
    if int(v) == 0:
        color_1.append('red')
    elif  int(v) > mediane:
        color_1.append('green')
    else:
        color_1.append('orange')


dico_1 = {
    'Nom': liste_nom,
    'Longitude' : liste_lon,
    'Latitude' : liste_lat,
    'Creneau' : dico_creneau_tot_1.values() ,
    'Color' : color_1
}
data_1 = pd.DataFrame(dico_1)


# Création de l'output HTML
output_file("Projet_MongoDB_Python.html")

#Creation de la figure 
# # Nous transformons donc les points GPS:
k = 6378137

data_1['Longitude'] = data_1['Longitude']  * (k * np.pi / 180.0)
data_1['Latitude'] = np.log(np.tan((90 + data_1['Latitude']) * np.pi / 360.0)) * k

data_source = ColumnDataSource(data_1)

# # # Chargement du fond de carte 
tile_provider = get_provider(Vendors.CARTODBPOSITRON)

# # Creation tools
tools = "pan,wheel_zoom,box_zoom,reset"
TOOLTIPS = [
    ('Nom', '@Nom'),
    ('Créneau','@Creneau')
    ]

# Initialisation figure
s = figure(
           x_axis_type="mercator", y_axis_type="mercator",
           title = "Carte des centres de vaccinations autour de Rennes",
           tooltips=TOOLTIPS,
           tools=tools,
           plot_width=900,
           plot_height=600
           )

# Ajout du fond de carte 
s.add_tile(tile_provider)

#Ajout des points avec la couleur  adaptee

s.scatter(x='Longitude', y='Latitude', size=12, alpha=0.5, source=data_source,  color = 'Color'        )



texte =Div(text="""
<p> Visualisation PYmongo - Projet Goutard Amélie - Thivend Evane  </p>
<p> Voici la carte représentant les centres de Vaccination à 50km de Rennes</p>
<p> Les couleurs des points correspondent à la disponibilité des créneaux entre le 26 janvier 2022 et le 29 janvier 2022</p>
""")

layout = column(texte, c)

texte_1 =Div(text="""
<p> Visualisation PYmongo - Projet Goutard Amélie - Thivend Evane  </p>
<p> Voici la carte représentant les centres de Vaccination à 50km de Rennes</p>
<p> Les couleurs des points correspondent à la disponibilité des créneaux réservés à la première dose du vaccin entre le 1er janvier 2022 et le 1er juin 2022</p>
""")
layout_1 = column(texte_1, s)

tab1 = Panel(child=layout, title="Visualisation des créneaux du 26 au 29 janvier 2022")
tab2 = Panel(child=layout_1, title="Visualisation des créneaux réservé à la première dose du 1er janvier au 1er juin  2022")
tabs = Tabs(tabs = [tab1, tab2])


show(tabs)