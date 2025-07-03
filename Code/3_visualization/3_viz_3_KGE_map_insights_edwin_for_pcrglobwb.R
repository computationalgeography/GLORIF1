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
outputDir <- '/scratch-shared/edwin/glorif1_paper_finalizing/Practical/viz/'
dir.create(outputDir, showWarnings = F, recursive = T)

# Load station information
#~ stationInfoArea <- read.csv('/home/bisik/Practical/gsim_preprocess/gsim_area_excluded_5_12months.csv') %>% 
#~   select(gsim.no, area.meta, miss)
stationInfoArea <- read.csv('/scratch-shared/edwin/glorif1/original/version_1.0/preprocess/preprocess_gsim/gsim_12months_missing_excluded.csv') %>% 
  select(gsim.no, area.meta, miss)
#~ stationInfo <- read.csv('/home/bisik/Practical/gsim_preprocess/station_to_pixel_mapping_gsim_areagrdcfiltered_12monhts.csv') %>% 
#~   select(gsim.no, lon, lat) %>% inner_join(., stationInfoArea, by = 'gsim.no')
stationInfo <- read.csv('/scratch-shared/edwin/glorif1/original/version_1.0/preprocess/preprocess_gsim/station_pixel_mapping_gsim.csv') %>% 
  select(gsim.no, lon, lat) %>% inner_join(., stationInfoArea, by = 'gsim.no')

# Load KGE data for uncalibrated setup
#~ rf.eval.uncalibrated <- read.csv('/scratch-shared/bisik/Practical_NEW/reanalysis_NEW_95_filtered/validation/KGE_results_PCR_GSIM_validation.csv') %>%
#~   select(gsim.no, KGE) %>%
#~   mutate(setup = 'uncalibrated')
rf.eval.uncalibrated <- read.csv('/scratch-shared/edwin/glorif1/original/version_1.0/output/kge_pcrglobwb_gsim.csv') %>%
  select(gsim.no, KGE) %>%
  mutate(setup = 'uncalibrated')

#~ edwin@tcn1106.local.snellius.surf.nl:/scratch-shared/edwin/glorif1/original/version_1.0/output$ ls -lah
#~ total 657M
#~ drwxr-x---+ 2 edwin edwin  4.0K Jul  3 15:37 .
#~ drwxr-x---+ 7 edwin edwin  4.0K Jul  3 15:38 ..
#~ -rw-r-----. 1 edwin edwin 1013K Jul  3 15:37 glorif1_discharge_30min_average.map
#~ -rw-r-----. 1 edwin edwin 1019K Jul  3 15:37 glorif1_discharge_30min_average.nc
#~ -rw-r-----. 1 edwin edwin  487M Jul  3 15:37 glorif1_discharge_30min_monthly.nc
#~ -rw-r-----. 1 edwin edwin  346K Jul  3 15:37 kge_glorif1_gsim.csv
#~ -rw-r-----. 1 edwin edwin  345K Jul  3 15:37 kge_pcrglobwb_gsim.csv
#~ -rw-r-----. 1 edwin edwin  168M Jul  3 15:37 reanalysis_discharge.zip


# Merge KGE data with station info
plotData_uncalibrated <- rf.eval.uncalibrated %>%
  inner_join(stationInfo, by = 'gsim.no') %>%
  group_by(gsim.no) %>%
  summarise(mean_test_KGE_uncalibrated = mean(KGE),
            lon = first(lon),
            lat = first(lat),
            miss = first(miss),
            area.meta = first(area.meta)) %>%
  mutate(setup = 'uncalibrated')

# sorting based on KGE
plotData_uncalibrated <- plotData_uncalibrated[order(plotData_uncalibrated$mean_test_KGE_uncalibrated),]

#### Plot KGE Map ####
wg <- map_data("world")

breaks <- c(-Inf, -0.41, 0.6,1)
labels <- c('KGE < -0.41','-0.41 < KGE < 0.6', '0.6 < KGE < 0.1')
            
#breaks <- c(-Inf, -0.41, 0, 0.2, 0.4, 0.6, 0.8, 0.9, 1)
#labels <- c('KGE < -0.41','-0.41 < KGE < 0', '0 < KGE < 0.2','0.2 < KGE < 0.4',
#            '0.4 < KGE < 0.6','0.6 < KGE < 0.8','0.8 < KGE < 0.9','0.9 < KGE < 1')
  

KGE_map_uncalibrated <- ggplot() +
  geom_map(data = wg, map = wg, aes(long, lat, map_id = region), color = "white", fill = "grey") +
  coord_fixed(1.3) +  # Maintain aspect ratio
  xlim(-180, 180) +
  ylim(-55, 75) +
  geom_point(data = plotData_uncalibrated, mapping = aes(x = lon, y = lat,
                                                        fill = cut(mean_test_KGE_uncalibrated, breaks = breaks, labels = labels)),
             color = 'black', pch = 21, size = 2.5) +
  scale_fill_brewer(palette = 'RdYlBu', guide = guide_legend(reverse = TRUE), name = '') +
  labs(title = 'Uncalibrated PCR−GLOBWB\n', x = 'longitude', y = 'latitude') +
  theme(plot.title = element_text(hjust = 0.5, size = 20),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank())
        

# Save plot with adjusted dimensions
ggsave(paste0(outputDir, 'map_KGE_results_PCR_GSIM_validation_3Classes.pdf'), KGE_map_uncalibrated, height = 8, width = 16, units = 'in', dpi = 1200)

# Summary of the data
summary(plotData_uncalibrated$mean_test_KGE_uncalibrated)
summary(plotData_uncalibrated$miss)

# End of the script
