# Load necessary libraries
library(dplyr)
library(ggplot2)

# rseg table
table_performance = read.csv("/scratch-shared/edwin/__updating_glorif1/research-glorif1/version_1.1/output/performance_table_gsim_map_final_v20260422.csv", header = TRUE, sep = ";")

#~ > names(table_performance)
#~  [1] "stat_code"           "river"               "station"
#~  [4] "country"             "obs_lat"             "obs_lon"
#~  [7] "mod_lat"             "mod_lon"             "obs_area_meta_km2"
#~ [10] "obs_area_est_km2"    "mod_area_km2"        "length_of_obs_used"
#~ [13] "obs_avg_m3ps"        "pcrglobwb_avg_m3ps"  "glorif1_avg_m3ps"
#~ [16] "kge_pcrglobwb"       "nse_pcrglobwb"       "kge_glorif1"
#~ [19] "nse_glorif1"         "obs_altitude_meta_m" "obs_altitude_est_m"
#~ [22] "KGE_r_pcrglobwb"     "KGE_alpha_pcrglobwb" "KGE_beta_pcrglobwb"
#~ [25] "RMSE_pcrglobwb"      "MAE_pcrglobwb"       "nRMSE_pcrglobwb"
#~ [28] "nMAE_pcrglobwb"      "KGE_r_glorif1"       "KGE_alpha_glorif1"
#~ [31] "KGE_beta_glorif1"    "RMSE_glorif1"        "MAE_glorif1"
#~ [34] "nRMSE_glorif1"       "nMAE_glorif1"

# Boxplot comparison
g4 <- ggplot(table_performance, aes(x = factor("PCR"), y = nse_pcrglobwb)) +
  geom_boxplot(fill = "blue") +
  geom_boxplot(data = table_performance, aes(x = factor("GLORIF1"), y = nse_glorif1), fill = "green") +
  labs(x = "", y = "NSE") +
  ylim(-1, 1) +
  theme_minimal(base_size = 14) + # Increase base font size
  theme(
    axis.text = element_text(size = 14),
    axis.title = element_text(size = 16),
    plot.title = element_text(size = 16)
  )

# Histogram comparison
g5 <- ggplot() +
  geom_histogram(data = table_performance, aes(x = nse_pcrglobwb), fill = "blue", bins = 30, alpha = 0.5) +
  geom_histogram(data = table_performance, aes(x = nse_glorif1) , fill = "green", bins = 30, alpha = 0.5) +
  labs(x = "NSE", y = "Frequency") +
  xlim(-1, 1) +
  theme_minimal(base_size = 14) + # Increase base font size
  theme(
    axis.text = element_text(size = 14),
    axis.title = element_text(size = 16),
    plot.title = element_text(size = 16)
  )

#~ # Save the visual comparison plots
#~ ggsave('test.pdf', plot = g5)

# Save the visual comparison plots
ggsave('nse_gsim_boxplot.pdf', plot = g4)
ggsave('nse_gsim_histogram.pdf', plot = g5)

