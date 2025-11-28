# Load necessary libraries
library(dplyr)
library(ggplot2)

# Define the paths to the CSV files
pcr_file_path <- '/scratch-shared/bisik/Practical_NEW/reanalysis_NEW_95_filtered/validation/KGE_results_PCR_GSIM_validation.csv'
rf_file_path <- '/scratch-shared/bisik/Practical_NEW/reanalysis_NEW_95_filtered/validation/KGE_results_RF_GSIM_validation.csv'

#~ sutan101@velocity.geo.uu.nl:/scratch/sutan101/glorif1_work/rseg_validation$ ls -lah
#~ total 1.4M
#~ drwxr-xr-x 2 sutan101 users 4.0K Nov 26 11:33 .
#~ drwxr-xr-x 3 sutan101 users 4.0K Nov 25 18:51 ..
#~ -rw-r--r-- 1 sutan101 users 697K Nov 26 11:31 kge_results_glorif1_rseg_validation.csv
#~ -rw-r--r-- 1 sutan101 users 696K Nov 26 11:25 kge_results_pgb_rseg_validation.csv

pcr_file_path <- '/scratch/sutan101/glorif1_work/rseg_validation/kge_results_pgb_rseg_validation.csv'
rf_file_path  <- '/scratch/sutan101/glorif1_work/rseg_validation/kge_results_glorif1_rseg_validation.csv'

# Load the CSV files
kge_results_pcr <- read.csv(pcr_file_path)
kge_results_rf <- read.csv(rf_file_path)

#~ # Filter the KGE values to be within the expected range
#~ kge_results_pcr <- kge_results_pcr %>%
#~   filter(KGE >= -1 & KGE <= 1)
#~ kge_results_rf <- kge_results_rf %>%
#~   filter(KGE >= -1 & KGE <= 1)

# Function to classify KGE scores
classify_kge <- function(kge) {
  if (kge >= 0.6) {
    return("High/Good")
  } else if (kge >= -0.4) {
    return("Moderate")
  } else {
    return("Poor")
  }
}

# Add classification to the datasets
kge_results_pcr <- kge_results_pcr %>%
  mutate(KGE_Class = sapply(KGE, classify_kge))

kge_results_rf <- kge_results_rf %>%
  mutate(KGE_Class = sapply(KGE, classify_kge))

# Calculate proportions
pcr_proportions <- kge_results_pcr %>%
  count(KGE_Class) %>%
  mutate(Proportion = n / sum(n) * 100)

rf_proportions <- kge_results_rf %>%
  count(KGE_Class) %>%
  mutate(Proportion = n / sum(n) * 100)

# Plotting the proportions
g1 <- ggplot(pcr_proportions, aes(x = KGE_Class, y = Proportion)) +
  geom_bar(stat = "identity", fill = "steelblue", alpha = 0.7) +
  labs(title = "Proportion of KGE Scores - PCR Dataset", x = "KGE Classification", y = "Proportion (%)") +
  theme_minimal()

g2 <- ggplot(rf_proportions, aes(x = KGE_Class, y = Proportion)) +
  geom_bar(stat = "identity", fill = "seagreen", alpha = 0.7) +
  labs(title = "Proportion of KGE Scores - RF Dataset", x = "KGE Classification", y = "Proportion (%)") +
  theme_minimal()

#~ # Save the plots
#~ ggsave('/scratch-shared/bisik/Practical_NEW/reanalysis_NEW_95_filtered/validation/kge_classification_pcr.pdf', plot = g1)
#~ ggsave('/scratch-shared/bisik/Practical_NEW/reanalysis_NEW_95_filtered/validation/kge_classification_rf.pdf', plot = g2)

# Display the plots
print(g1)
print(g2)
