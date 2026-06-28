# 03 - Modelisation
# On explique la duree de sejour (hospit complete) par la racine de GHM
# (= le GHM sans le niveau de severite), le nombre de comorbidites (DAS),
# la presence de chaque comorbidite retenue, et quelques variables admin.
# NB : 01_prep.R doit avoir tourne avant.

source("00_config.R")
source("utilitaires.R")
df <- readRDS(file.path(dossier_sorties, "df_brut.rds"))

# ===== Modele 1 : regression lineaire =====
don_lm <- preparer_donnees_modele(df)
modele_lm <- lm(duree ~ ., data = don_lm)
pred_lm <- predict(modele_lm, don_lm)
rmse_lm <- rmse(don_lm$duree, pred_lm)
r2_lm <- summary(modele_lm)$r.squared
cat("LM -> RMSE =", round(rmse_lm, 3), " R2 =", round(r2_lm, 3), "\n")
saveRDS(modele_lm, file.path(dossier_sorties, "modele_lm.rds"))

# ===== Modele 2 : random forest =====
don_rf <- preparer_donnees_modele(df)
modele_rf <- ranger(duree ~ ., data = don_rf, num.trees = 200,
                    importance = "impurity")
pred_rf <- modele_rf$predictions          # predictions OOB
rmse_rf <- rmse(don_rf$duree, pred_rf)
r2_rf <- modele_rf$r.squared
cat("RF -> RMSE =", round(rmse_rf, 3), " R2 =", round(r2_rf, 3), "\n")
saveRDS(modele_rf, file.path(dossier_sorties, "modele_rf.rds"))
