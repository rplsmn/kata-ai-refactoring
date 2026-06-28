# 01 - Chargement et preparation des donnees
# NB : il faut avoir lance ce script depuis la racine du projet
#      (sinon les dossiers de sortie ne sont pas crees au bon endroit)

source("00_config.R")
source("utilitaires.R")

# liste des DAS a transformer en indicatrices (0/1)
codes_das <- read.csv(chemin_liste_diags)$das3
liste_in <- paste0("'", codes_das, "'", collapse = ", ")

con <- dbConnect(duckdb::duckdb())

# DAS = comorbidites (typ_diag 3,4,5), 3 premiers caracteres CIM-10,
# hors chapitres V,W,X,Y,Z. On laisse DuckDB faire le pivot (rapide).
# On exclut aussi les racines de seance (90...) et de CM 28 (...),
# non pertinentes pour une duree de sejour en hospit complete.
requete <- paste0("
WITH das AS (
  SELECT d.ident, upper(left(d.diag, 3)) AS das3
  FROM read_parquet('", chemin_data, "/diag.parquet') d
  WHERE d.typ_diag IN ('3','4','5')
    AND left(d.diag, 1) NOT IN ('V','W','X','Y','Z')
),
burden AS (
  SELECT ident, count(*) AS nb_das FROM das GROUP BY ident
),
flags AS (
  PIVOT das ON das3 IN (", liste_in, ") USING max(1) GROUP BY ident
)
SELECT
  f.duree,
  f.age,
  f.sexe,
  f.modeentree,
  left(f.ghm2, 5) AS racine,
  f.nbacte,
  coalesce(b.nb_das, 0) AS nb_das,
  fl.* EXCLUDE (ident)
FROM read_parquet('", chemin_data, "/fixe.parquet') f
LEFT JOIN burden b ON b.ident = f.ident
LEFT JOIN flags fl ON fl.ident = f.ident
WHERE left(f.ghm2, 2) NOT IN ('90','28')
", clause_limite)

df <- dbGetQuery(con, requete)
dbDisconnect(con, shutdown = TRUE)

# les indicatrices DAS sortent du PIVOT avec des NA (sejours sans ce diag)
# et sont nommees par le code brut -> on remet a 0 et on prefixe en das_*
df[codes_das][is.na(df[codes_das])] <- 0
names(df)[names(df) %in% codes_das] <- paste0("das_", codes_das)

cat("donnees chargees :", nrow(df), "lignes,", ncol(df), "colonnes\n")

# sauvegarde intermediaire (relue par les scripts suivants)
saveRDS(df, file.path(dossier_sorties, "df_brut.rds"))
