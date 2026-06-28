# 01 - Chargement et preparation des donnees
# NB : il faut avoir lance ce script depuis la racine du projet
#      (sinon les dossiers de sortie ne sont pas crees au bon endroit)

source("00_config.R")
source("utilitaires.R")

# liste des DAS a transformer en indicatrices (0/1)
codes_das <- read.csv(chemin_liste_diags)$das3

# on construit a la main les bouts de requete pour chaque diagnostic
# (un indicateur par DAS retenu) -- le pivot est fait par DuckDB, beaucoup
# plus rapide que de bricoler ca dans R
lignes_agg <- paste0(
  "    max(CASE WHEN das3 = '", codes_das, "' THEN 1 ELSE 0 END) AS das_", codes_das,
  collapse = ",\n")
lignes_sel <- paste0(
  "  coalesce(a.das_", codes_das, ", 0) AS das_", codes_das,
  collapse = ",\n")

con <- dbConnect(duckdb::duckdb())

requete <- paste0("
WITH das AS (
  SELECT d.ident, upper(left(d.diag, 3)) AS das3
  FROM read_parquet('", chemin_data, "/diag.parquet') d
  WHERE d.typ_diag IN ('3','4','5')
    AND left(d.diag, 1) NOT IN ('V','W','X','Y','Z')
),
agg AS (
  SELECT ident,
    count(*) AS nb_das,
", lignes_agg, "
  FROM das
  GROUP BY ident
)
SELECT
  f.duree,
  f.age,
  f.sexe,
  f.modeentree,
  left(f.ghm2, 5) AS racine,
  f.nbacte,
  coalesce(a.nb_das, 0) AS nb_das,
", lignes_sel, "
FROM read_parquet('", chemin_data, "/fixe.parquet') f
LEFT JOIN agg a ON a.ident = f.ident
", clause_limite)

df <- dbGetQuery(con, requete)
dbDisconnect(con, shutdown = TRUE)

cat("donnees chargees :", nrow(df), "lignes,", ncol(df), "colonnes\n")

# sauvegarde intermediaire (relue par les scripts suivants)
saveRDS(df, file.path(dossier_sorties, "df_brut.rds"))
