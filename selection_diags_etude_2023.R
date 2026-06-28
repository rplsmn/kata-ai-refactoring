# Selection des diagnostics associes (DAS) a retenir pour la modelisation
# --- Etude duree de sejour 2023 ---
# Produit le fichier diags_a_garder.csv (liste des DAS3 les plus frequents).
# Ce script n'a pas besoin d'etre relance a chaque analyse : la liste est figee.

library(DBI)
library(duckdb)

chemin_data <- "/home/raph/dev-repos/projet-demo-stat-r/kata-ai-refactoring/raw-data/an1"
nb_diags <- 100

con <- dbConnect(duckdb::duckdb())

# DAS = typ_diag 3, 4, 5 ; on prend les 3 premiers caracteres (categorie CIM-10)
# on exclut les chapitres V, W, X, Y (causes externes) et Z (facteurs/recours)
# on classe par nombre de sejours (hospit complete) ou la categorie apparait
liste <- dbGetQuery(con, paste0("
WITH das AS (
  SELECT DISTINCT d.ident, upper(left(d.diag, 3)) AS das3
  FROM read_parquet('", chemin_data, "/diag.parquet') d
  JOIN read_parquet('", chemin_data, "/fixe.parquet') f USING(ident)
  WHERE d.typ_diag IN ('3','4','5')
    AND f.duree > 0
    AND left(d.diag, 1) NOT IN ('V','W','X','Y','Z')
)
SELECT das3, count(*) AS nb_sejours
FROM das
GROUP BY das3
ORDER BY nb_sejours DESC
LIMIT ", nb_diags))

dbDisconnect(con, shutdown = TRUE)

write.csv(liste, "diags_a_garder.csv", row.names = FALSE)
cat("liste ecrite :", nrow(liste), "diagnostics\n")
