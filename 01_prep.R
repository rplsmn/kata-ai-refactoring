# 01 - Chargement et preparation des donnees
# NB : il faut avoir lance ce script depuis la racine du projet
#      (sinon les dossiers de sortie ne sont pas crees au bon endroit)

source("00_config.R")
source("utilitaires.R")

# connexion DuckDB en memoire
con <- dbConnect(duckdb::duckdb())

# on agrege les comorbidites (DAS = typ_diag 3, 4, 5) par sejour
# puis on les rattache a la table principale (fixe)
requete <- paste0("
WITH das AS (
  SELECT ident,
         count(*) FILTER (WHERE typ_diag IN ('3','4','5')) AS nb_das
  FROM read_parquet('", chemin_data, "/diag.parquet')
  GROUP BY ident
)
SELECT
  f.duree,
  f.age,
  f.sexe,
  f.modeentree,
  left(f.ghm2, 5) AS racine,
  f.nbacte,
  coalesce(d.nb_das, 0) AS nb_das
FROM read_parquet('", chemin_data, "/fixe.parquet') f
LEFT JOIN das d ON d.ident = f.ident
", clause_limite)

df <- dbGetQuery(con, requete)
dbDisconnect(con, shutdown = TRUE)

cat("donnees chargees :", nrow(df), "lignes\n")

# sauvegarde intermediaire (relue par les scripts suivants)
saveRDS(df, file.path(dossier_sorties, "df_brut.rds"))
