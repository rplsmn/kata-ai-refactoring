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

# variables gardees pour la modelisation
# (utilisees DANS preparer_donnees_modele -> variable globale)
vars_modele <- c("duree", "racine", "nb_das", "age", "sexe", "modeentree", "nbacte")

# astuce perso : pour tester vite sur un echantillon, mettre "LIMIT 50000"
clause_limite <- ""
