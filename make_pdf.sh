#!/bin/bash -

## TEXTES QUI POSENT PROBLÈME ##
# ./textes/ojtr/le_militantisme_stade_supreme_de_l_alienation.md

## NOTES ##
# Problème des chemins d'accès aux images:
# Les tags <img> des fichiers html sont relatifs au répertoire de index.html:
# 	/textes/dominique_karamazov/misere_du_feminisme/index.html
# 	/textes/dominique_karamazov/misere_du_feminisme/img1.jpg
# 	/textes/dominique_karamazov/misere_du_feminisme/img2.jpg
# 	etc.
# tandis que les balises images MD sont relatifs au répertoire du fichier MD:
# 	textes/dominique_karamazov/misere_du_feminisme.md
# 	textes/dominique_karamazov/img1.jpg
# 	textes/dominique_karamazov/img2.jpg
# 	etc.
# Solution: faire des liens symboliques entre './misere_du_feminisme/*jpg' et './*jpg'

./pdc_gen.sh textes/ -i md -o pdf:epub -a '--template=./template.pdf.pandoc' -j 1 -p

