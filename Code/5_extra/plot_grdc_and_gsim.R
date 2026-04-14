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
#~ # - from actual coordinates
#~ grdc_location <- read.csv("/projects/0/dfguu/users/edwin/data/glorif1/original/version_1.0/random_forest/train/stationLatLon_filtered_95.csv", header = TRUE)
# - from pcrglobwb coordinates
grdc_location <- read.csv("/projects/0/dfguu/users/edwin/data/glorif1/original/version_1.0/preprocess/preprocess_grdc/station_pixel_mapping_grdc.csv", header = TRUE)


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

# using only stations with at least 12 months and upstream area > 10,000 km2 (~4 pixels of PCR-GLOBWB)
gsim_location <- gsim_location[which((gsim_location$obs_area_meta_km2 > 10000) | (gsim_location$obs_area_est_km2 > 10000)), ]
gsim_location <- gsim_location[which((gsim_location$mod_area_km2 > 10000)), ]
gsim_location <- gsim_location[which((gsim_location$length_of_obs_used >= 12)), ]

gsim_valid_station <- gsim_location
print(dim(gsim_valid_station))

#~ > print(dim(gsim_valid_station))
#~ [1] 1969   21

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
  geom_point(data = gsim_valid_station, mapping = aes(x = obs_lon, y = obs_lat), color = 'blue', size = 2.3, shape = 20, alpha = 6/10) +
  geom_point(data = grdc_train_station, mapping = aes(x = lon, y = lat), color = 'red' , size = 2.3, shape = 20, alpha = 6/10) +
#~   geom_point(alpha = 8/10) +
  scale_fill_brewer(palette = 'RdYlBu', guide = guide_legend(reverse = TRUE), name = '') +
  labs(title = 'GRDC (red, training) and GSIM (blue, validation) stations used\n', x = 'longitude', y = 'latitude') +
  theme(plot.title = element_text(hjust = 0.5, size = 20),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank())

outputDir = "/scratch-shared/edwin/_finalizing_glorif1/maps_stations/"
map_filename = paste(outputDir, "grdc_gsim_map.pdf", sep = "")

ggsave(map_filename, station_map, height = 8, width = 16, units = 'in', dpi = 1200)

#~ station_map

#~ station_map_grdc <- ggplot() +
#~   geom_map(data = wg, map = wg, aes(long, lat, map_id = region), color = "white", fill = "grey") +
#~   coord_fixed(1.3) +  # Maintain aspect ratio
#~   xlim(-180, 180) +
#~   ylim(-55, 75) +
#~   geom_point(data = grdc_train_station, mapping = aes(x = lon, y = lat), color = 'red' , pch = 21, size = 0.5) +
#~   scale_fill_brewer(palette = 'RdYlBu', guide = guide_legend(reverse = TRUE), name = '') +
#~   labs(title = 'GRDC and GSIM stations used\n', x = 'longitude', y = 'latitude') +
#~   theme(plot.title = element_text(hjust = 0.5, size = 20),
#~         axis.title.x = element_blank(),
#~         axis.title.y = element_blank(),
#~         axis.ticks = element_blank(),
#~         panel.grid = element_blank())

#~ station_map_gsim <- ggplot() +
#~   geom_map(data = wg, map = wg, aes(long, lat, map_id = region), color = "white", fill = "grey") +
#~   coord_fixed(1.3) +  # Maintain aspect ratio
#~   xlim(-180, 180) +
#~   ylim(-55, 75) +
#~   geom_point(data = gsim_valid_station, mapping = aes(x = lon, y = lat), color = 'blue', pch = 21, size = 0.5) +
#~   scale_fill_brewer(palette = 'RdYlBu', guide = guide_legend(reverse = TRUE), name = '') +
#~   labs(title = 'GRDC and GSIM stations used\n', x = 'longitude', y = 'latitude') +
#~   theme(plot.title = element_text(hjust = 0.5, size = 20),
#~         axis.title.x = element_blank(),
#~         axis.title.y = element_blank(),
#~         axis.ticks = element_blank(),
#~         panel.grid = element_blank())


#~ ggsave("test_map.pdf", station_map, height = 8, width = 16, units = 'in', dpi = 1200)

#~ # Save plot with adjusted dimensions
#~ ggsave(paste0(outputDir, 'map_grdc_and_gsim_stations.pdf'), KGE_map_uncalibrated, height = 8, width = 16, units = 'in', dpi = 1200)
