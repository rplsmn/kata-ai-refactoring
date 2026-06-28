# 04 - Rapport / synthese
# NB : 01_prep.R et 03_modelisation.R doivent avoir tourne avant.

source("00_config.R")
source("utilitaires.R")
modele_lm <- readRDS(file.path(dossier_sorties, "modele_lm.rds"))
modele_rf <- readRDS(file.path(dossier_sorties, "modele_rf.rds"))

# on recharge et on re-prepare les donnees pour recalculer les metriques
df <- readRDS(file.path(dossier_sorties, "df_brut.rds"))
don <- preparer_donnees_modele(df)
pred_lm <- predict(modele_lm, don)
pred_rf <- modele_rf$predictions

comparaison <- data.frame(
  modele = c("Regression lineaire", "Random forest"),
  rmse = c(rmse(don$duree, pred_lm), rmse(don$duree, pred_rf)),
  r2 = c(summary(modele_lm)$r.squared, modele_rf$r.squared)
)
print(comparaison)
write.csv(comparaison, file.path(dossier_sorties, "comparaison_modeles.csv"),
          row.names = FALSE)

# importance des variables (Random Forest) - top 15
imp <- sort(modele_rf$variable.importance, decreasing = TRUE)
print(head(imp, 15))

df_imp <- data.frame(variable = names(imp), importance = as.numeric(imp))
df_imp <- head(df_imp, 15)
p <- ggplot(df_imp, aes(x = reorder(variable, importance), y = importance)) +
  geom_col() +
  coord_flip() +
  labs(title = "Importance des variables (Random Forest) - top 15", x = NULL)
ggsave(file.path(dossier_figures, "importance_rf.png"), p, width = 8, height = 5)

# effet des comorbidites en regression lineaire (top 15 coefficients DAS)
coefs <- coef(modele_lm)
coefs_das <- coefs[grepl("^das_", names(coefs))]
coefs_das <- sort(coefs_das, decreasing = TRUE)
cat("\nComorbidites qui allongent le plus la duree (LM, nuits) :\n")
print(head(coefs_das, 15))
