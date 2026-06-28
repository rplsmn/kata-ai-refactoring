# 02 - Exploration des donnees (EDA)
# NB : 01_prep.R doit avoir tourne avant (besoin de df_brut.rds)

source("00_config.R")
source("utilitaires.R")
df <- readRDS(file.path(dossier_sorties, "df_brut.rds"))

# quelques stats descriptives
print(summary(df$duree))
cat("duree moyenne (tous sejours) :", mean(df$duree), "\n")
cat("duree moyenne (hospit complete) :", mean(df$duree[df$duree > 0]), "\n")
print(table(df$sexe))
cat("nb moyen de comorbidites (DAS) :", mean(df$nb_das), "\n")

# distribution de la duree (hospit complete, zoom)
df_hc <- df[df$duree > 0 & df$duree <= duree_max_plot, ]
p1 <- ggplot(df_hc, aes(x = duree)) +
  geom_histogram(bins = 60) +
  labs(title = "Distribution de la duree de sejour (hospit complete)",
       x = "duree (nuits)", y = "nb sejours")
ggsave(file.path(dossier_figures, "hist_duree.png"), p1, width = 8, height = 5)

# duree vs nb de comorbidites (nuage de points, non echantillonne)
p2 <- ggplot(df[df$duree > 0, ], aes(x = nb_das, y = duree)) +
  geom_point(alpha = 0.1) +
  labs(title = "Duree vs nombre de comorbidites (DAS)",
       x = "nb comorbidites (DAS)", y = "duree (nuits)")
ggsave(file.path(dossier_figures, "duree_vs_das.png"), p2, width = 8, height = 5)

# duree moyenne en presence / absence de quelques comorbidites frequentes
for (v in c("das_I10", "das_N18", "das_I50")) {
  m1 <- mean(df$duree[df$duree > 0 & df[[v]] == 1])
  m0 <- mean(df$duree[df$duree > 0 & df[[v]] == 0])
  cat(v, ": presence =", round(m1, 2), " absence =", round(m0, 2), "\n")
}
