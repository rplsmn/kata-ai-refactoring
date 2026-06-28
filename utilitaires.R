# Fonctions utilitaires
# A sourcer APRES 00_config.R (utilise des variables globales)

# prepare le data.frame pour la modelisation
# /!\ utilise la variable globale seuil_duree
preparer_donnees_modele <- function(donnees) {
  donnees <- donnees[donnees$duree > seuil_duree, ]
  donnees$racine <- as.factor(donnees$racine)
  donnees$sexe <- as.factor(donnees$sexe)
  donnees$modeentree <- as.factor(donnees$modeentree)
  donnees <- na.omit(donnees)
  cat("nb lignes apres preparation :", nrow(donnees), "\n")
  donnees
}

# petit raccourci pour le RMSE
rmse <- function(obs, pred) {
  sqrt(mean((obs - pred)^2))
}
