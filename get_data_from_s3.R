# ===============================================================
# Recuperation des donnees parquet depuis le bucket S3
# ===============================================================

library(DBI)
library(duckdb)

champ <- "mco"
an <- "an1"
fixe_path_s3 <- glue::glue("{champ}/{an}/fixe.parquet")
diag_path_s3 <- glue::glue("{champ}/{an}/diag.parquet")
fixe_out <- "fixe.parquet"
diag_out <- "diag.parquet"

dir.create(file.path("raw-data", an), recursive = TRUE, showWarnings = FALSE)

con <- dbConnect(duckdb::duckdb(), dbdir = ":memory:")
dbExecute(con, "INSTALL httpfs")
dbExecute(con, "LOAD httpfs")

sql_secret <- sprintf(
  "CREATE OR REPLACE SECRET secret_s3 (
       TYPE s3,
       KEY_ID '%s',
       SECRET '%s',
       REGION '%s',
       ENDPOINT '%s',
       URL_STYLE 'path',
       USE_SSL '0'
     )",
  Sys.getenv("S3_ACCESS_KEY"),
  Sys.getenv("S3_SECRET_KEY"),
  Sys.getenv("AWS_DEFAULT_REGION"),
  Sys.getenv("S3_ENDPOINT")
)

dbExecute(con, sql_secret)

bucket <- Sys.getenv("S3_BUCKET")

sql_copy_to_parquet_from_s3 <- function(s3_path, out_path) {
  sql_copy <- glue::glue(
    "COPY (SELECT * FROM read_parquet('s3://{bucket}/{s3_path}'))
       TO '{out_path}' (FORMAT parquet)"
  )

  dbExecute(con, sql_copy)

  return(out_path)
}

# Fixe
sql_copy_to_parquet_from_s3(
  fixe_path_s3,
  glue::glue("raw-data/{an}/{fixe_out}")
)

# Diag
sql_copy_to_parquet_from_s3(
  diag_path_s3,
  glue::glue("raw-data/{an}/{diag_out}")
)
