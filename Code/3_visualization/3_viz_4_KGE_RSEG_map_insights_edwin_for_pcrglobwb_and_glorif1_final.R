####-------------------------------####
source('/home/bisik/Practical/R/fun_0_loadLibrary.R')
####-------------------------------####
library('ggh4x')
library('ggplot2')
library('patchwork')
library('dplyr')
library('maps')  # Ensure the maps package is loaded

# Define color palettes
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")  # with grey
cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7") # with black

# Create output directory
#~ outputDir <- '/home/bisik/Practical/viz/'
#~ outputDir <- '/scratch-shared/edwin/glorif1_paper_finalizing/Practical/viz/'
outputDir <- '/scratch-shared/edwin/_finalizing_glorif1/maps_performance/rseg/'
dir.create(outputDir, showWarnings = F, recursive = T)

# Load table 
table_performance = read.csv("/scratch-shared/edwin/__updating_glorif1/research-glorif1/version_1.1/output/performance_table_rseg_map_final_v20260422.csv", header = TRUE, sep = ";")
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


#~ # fixing a station coordinate for plotting
> min(table_performance$obs_lon)
[1] -178.9
#~ table_performance$obs_lon[which(table_performance$obs_lon==-178.9)] = 180 + (180-178.9)

# sorting based on KGE
table_performance <- table_performance[order(table_performance$kge_glorif1),]



#### Plot KGE Map ####
wg <- map_data("world")

#~ breaks <- c(-Inf, -0.41, 0.6,1)
breaks <- c(-5e4, -0.41, 0.6,1)
labels <- c('KGE <= -0.41','-0.41 < KGE <= 0.6', '0.6 < KGE < 0.1')
            
#~ breaks <- c(-Inf, -0.41, 0, 0.2, 0.4, 0.6, 0.8, 0.9, 1)
#~ breaks <- c(-1e5, -0.41, 0, 0.2, 0.4, 0.6, 0.8, 0.9, 1)
#~ labels <- c('KGE < -0.41','-0.41 < KGE < 0', '0 < KGE < 0.2','0.2 < KGE < 0.4',
#~             '0.4 < KGE < 0.6','0.6 < KGE < 0.8','0.8 < KGE < 0.9','0.9 < KGE < 1')
  

# PCR-GLOBWB KGE
KGE_map_uncalibrated <- ggplot() +
  geom_map(data = wg, map = wg, aes(long, lat, map_id = region), color = "white", fill = "grey") +
  coord_fixed(1.3) +  # Maintain aspect ratio
  xlim(-180, 180) +
#~   xlim(-182, 182) +
  ylim(-55, 75) +
  geom_point(data = table_performance, mapping = aes(x = obs_lon, y = obs_lat,
                                                        fill = cut(kge_pcrglobwb, breaks = breaks, labels = labels)),
             color = 'black', pch = 21, size = 2.5) +
  scale_fill_brewer(palette = 'RdYlBu', guide = guide_legend(reverse = TRUE), name = '') +
  labs(title = 'PCR-GLOBWB (original)\n', x = 'longitude', y = 'latitude') +
  theme(plot.title = element_text(hjust = 0.5, size = 20),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank())

# Save plot with adjusted dimensions
ggsave(paste0(outputDir, 'rseg_map_kge_pcrglobwb.pdf'), KGE_map_uncalibrated, height = 8, width = 16, units = 'in', dpi = 1200)


# GLORIF1
KGE_map_glorif1 <- ggplot() +
  geom_map(data = wg, map = wg, aes(long, lat, map_id = region), color = "white", fill = "grey") +
  coord_fixed(1.3) +  # Maintain aspect ratio
  xlim(-180, 180) +
#~   xlim(-182, 182) +
  ylim(-55, 75) +
  geom_point(data = table_performance, mapping = aes(x = obs_lon, y = obs_lat,
                                                        fill = cut(kge_glorif1, breaks = breaks, labels = labels)),
             color = 'black', pch = 21, size = 2.5) +
  scale_fill_brewer(palette = 'RdYlBu', guide = guide_legend(reverse = TRUE), name = '') +
  labs(title = 'GLORIF1 \n', x = 'longitude', y = 'latitude') +
  theme(plot.title = element_text(hjust = 0.5, size = 20),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank())

# Save plot with adjusted dimensions
ggsave(paste0(outputDir, 'rseg_map_kge_glorif1.pdf'), KGE_map_glorif1, height = 8, width = 16, units = 'in', dpi = 1200)


# Summary of the data
summary(merged_table$mean_test_KGE_uncalibrated)
summary(merged_table$KGE_glorif1)

summary(plotData_uncalibrated$miss)

# End of the script
