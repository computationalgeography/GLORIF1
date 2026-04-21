#~ ####-------------------------------####
source('../fun_0_loadLibrary.R')
#~ ####-------------------------------####
#~ source('fun_2_2_trainRF.R')

library('ggh4x')
library('ggplot2')
library('patchwork')
library('dplyr')
library('maps')  # Ensure the maps package is loaded


# get all GRDC stations based on the training data 
train_data <- vroom(paste0('/projects/0/dfguu/users/edwin/data/glorif1/original/version_1.0/random_forest/train/bigTable_allpredictors_filtered_95.csv'),
                     show_col_types = F)
grdc_train_station_id <- unique(train_data$grdc_no)

# get their location from one of the following alternatives:
# - from actual coordinates
grdc_location <- read.csv("/projects/0/dfguu/users/edwin/data/glorif1/original/version_1.0/random_forest/train/stationLatLon_filtered_95.csv", header = TRUE)
#~ # - from pcrglobwb coordinates
#~ grdc_location <- read.csv("/projects/0/dfguu/users/edwin/data/glorif1/original/version_1.0/preprocess/preprocess_grdc/station_pixel_mapping_grdc.csv", header = TRUE)


# make sure those stations were used in the training table
grdc_selected <- grdc_location[which(is.element(grdc_location$grdc_no, grdc_train_station_id)),]
grdc_train_station <- grdc_selected


# gsim stations
gsim_location <- read.csv("/scratch-shared/edwin/_finalizing_glorif1/gsim_evaluation/_gsim_evaluation.txt", header = TRUE, sep = ";")

#~ > names(gsim_location)
#~  [1] "stat_code"           "river"               "station"
#~  [4] "country"             "obs_lat"             "obs_lon"
#~  [7] "mod_lat"             "mod_lon"             "obs_area_meta_km2"
#~ [10] "obs_area_est_km2"    "mod_area_km2"        "length_of_obs_used"
#~ [13] "obs_avg_m3ps"        "pcrglobwb_avg_m3ps"  "glorif1_avg_m3ps"
#~ [16] "kge_pcrglobwb"       "nse_pcrglobwb"       "kge_glorif1"
#~ [19] "nse_glorif1"         "obs_altitude_meta_m" "obs_altitude_est_m"

print(dim(gsim_location))

# using only stations with at least 12 months 
gsim_location <- gsim_location[which((gsim_location$length_of_obs_used >= 12)), ]

gsim_valid_station <- gsim_location
print(dim(gsim_valid_station))

print(dim(gsim_valid_station))

# plot the stations
wg <- map_data("world")

station_map <- ggplot() +
  geom_map(data = wg, map = wg, mapping = aes(long, lat, map_id = region), color = "white", fill = "grey") +
#~   geom_map(data = wg, mapping = aes(long, lat, map_id = region), color = "white", fill = "grey") +
#~   coord_fixed(1.3) +  # Maintain aspect ratio
  xlim(-180, 180) +
  ylim(-55, 75) +
#~   geom_point(data = gsim_valid_station, mapping = aes(x = mod_lon, y = mod_lat), color = 'blue', fill = "blue", size = 1.3, alpha = 5/10, shape = 21) +
#~   geom_point(data = grdc_train_station, mapping = aes(x = lon, y = lat), color = 'red' , fill = "red",  size = 1.3, alpha = 5/10, shape = 21) +
  geom_point(data = gsim_valid_station, mapping = aes(x = obs_lon, y = obs_lat), color = 'blue', size = 2.3, shape = 20, alpha = 6.5/10) +
  geom_point(data = grdc_train_station, mapping = aes(x = lon, y = lat), color = 'red' , size = 2.3, shape = 20, alpha = 5.0/10) +
#~   geom_point(data = gsim_valid_station, mapping = aes(x = obs_lon, y = obs_lat), color = 'blue', size = 2.3, shape = 20, alpha = 6/10) +
#~   geom_point(data = grdc_train_station, mapping = aes(x = lon, y = lat), color = 'red' , size = 2.3, shape = 20, alpha = 3/10) +
#~   geom_point(alpha = 8/10) +
  scale_fill_brewer(palette = 'RdYlBu', guide = guide_legend(reverse = TRUE), name = '') +
  labs(title = 'GRDC (red, training) and GSIM (blue, validation) stations used\n', x = 'longitude', y = 'latitude') +
  theme(plot.title = element_text(hjust = 0.5, size = 20),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank())

outputDir = "/scratch-shared/edwin/_finalizing_glorif1/maps_stations_final/"
map_filename = paste(outputDir, "grdc_gsim_map_final_v20260421.pdf", sep = "")

ggsave(map_filename, station_map, height = 8, width = 16, units = 'in', dpi = 1200)



# finalizing the performance table by adding KGE components and other things
#
# - pcrglobwb
kge_components_filename = '/projects/0/dfguu/users/edwin/data/glorif1/original/version_1.0/output/kge_pcrglobwb_gsim.csv'
kge_components = read.csv(kge_components_filename, header = TRUE)
kge_components = kge_components %>% select(gsim.no, KGE_r, KGE_alpha, KGE_beta, RMSE, MAE, nRMSE, nMAE)
names(kge_components) <- paste0(names(kge_components), "_pcrglobwb")
#
names(kge_components)
#~ [1] "grdc_no_pcrglobwb"   "kge_r_pcrglobwb"     "kge_alpha_pcrglobwb"
#~ [4] "kge_beta_pcrglobwb"  "rmse_pcrglobwb"      "mae_pcrglobwb"
#~ [7] "nrmse_pcrglobwb"     "nmae_pcrg
#
names(kge_components)[1] <- "stat_code"
#
gsim_performance_table = merge(gsim_valid_station, kge_components, by = "stat_code")
#
# - glorif1
kge_components_filename = '/projects/0/dfguu/users/edwin/data/glorif1/original/version_1.0/output/kge_glorif1_gsim.csv'
kge_components = read.csv(kge_components_filename, header = TRUE)
kge_components = kge_components %>% select(gsim.no, KGE_r, KGE_alpha, KGE_beta, RMSE, MAE, nRMSE, nMAE)
names(kge_components) <- paste0(names(kge_components), "_glorif1")
#
names(kge_components)[1] <- "stat_code"
#
gsim_performance_table = merge(gsim_performance_table, kge_components, by = "stat_code")

table_filename = paste(outputDir, "/performance_table_gsim_map_final_v20260421.csv", sep = "")
write.table(gsim_performance_table, file = table_filename, row.names = FALSE, col.names = TRUE, sep = ";")
