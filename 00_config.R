# ===============================================================
# Config globale de l'analyse PMSI MCO
# A SOURCER EN PREMIER (sinon les autres scripts plantent)
# ===============================================================

library(DBI)
library(duckdb)
library(dplyr)
library(ggplot2)
library(ranger)

# chemin des donnees parquet (a adapter selon la machine)
chemin_data <- "/home/raph/dev-repos/projet-demo-stat-r/kata-ai-refactoring/raw-data/an1"

# liste des diagnostics associes a retenir (produite par selection_diags_etude_2023.R)
chemin_liste_diags <- "diags_a_garder.csv"

# dossiers de sortie (crees au besoin)
dossier_sorties <- "sorties"
dossier_figures <- "figures"
dir.create(dossier_sorties, showWarnings = FALSE)
dir.create(dossier_figures, showWarnings = FALSE)

# parametres de l'analyse
seuil_duree <- 0          # on garde les sejours avec duree > seuil_duree (= hospit complete)
duree_max_plot <- 60      # pour zoomer les graphiques sur la duree
graine <- 42
set.seed(graine)

# astuce perso : pour tester vite sur un echantillon, mettre "LIMIT 50000"
clause_limite <- ""
