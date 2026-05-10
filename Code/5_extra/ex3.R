# Load required libraries
library(raster)
library(ggplot2)
library(RColorBrewer)
library(tidyr)

# Load raster data with GDAL
# Replace 'your_raster_file.tif' with your actual raster file path
#~ raster_file <- "your_raster_file.tif"
raster_file <- "/scratch-shared/edwin/_finalizing_glorif1/discharge_map_plot/discharge_waterbodies2010_glorif1_discharge_30min_average.map"
raster_data <- raster(raster_file)

#~ (pcrglobwb_python3_v20250207) edwin@tcn1187.local.snellius.surf.nl:/scratch-shared/edwin/_finalizing_glorif1/discharge_map_plot$ ls -lah
#~ total 16M
#~ drwxr-xr-x+  3 edwin edwin  4.0K May  3 08:55 .
#~ drwxr-xr-x+ 21 edwin edwin  4.0K May  3 00:53 ..
#~ -rw-r--r--.  1 edwin edwin 1013K May  3 08:54 areatotal_number_of_cells_ids_lakes_and_reservoirs.map
#~ -rw-r--r--.  1 edwin edwin 1013K May  3 01:45 average_pcrglobwb_30min_original.map
#~ -rw-r--r--.  1 edwin edwin 1013K May  3 05:34 diff_avg_glorif1_minus_pcrglowb
#~ -rw-r--r--.  1 edwin edwin 1013K May  3 08:55 discharge_diff_avera_glorif1_minus_pcrglowb.map
#~ -rw-r--r--.  1 edwin edwin 1013K May  3 08:55 discharge_waterbodies2010_average_pcrglobwb_30min_original.map
#~ -rw-r--r--.  1 edwin edwin 1013K May  3 08:55 discharge_waterbodies2010_glorif1_discharge_30min_average.map
#~ -rw-r--r--.  1 edwin edwin 1013K May  3 01:45 glorif1_discharge_30min_average.map
#~ -rw-r--r--.  1 edwin edwin 1013K May  3 01:45 ids_lakes_and_reservoirs.map
#~ -rw-r--r--.  1 edwin edwin  254K May  3 01:45 lakes_and_reservoirs.map
#~ -rw-r--r--.  1 edwin edwin  254K May  3 07:11 lakes_and_reservoirs.tmp
#~ -rw-r--r--.  1 edwin edwin  254K May  3 08:54 large_lakes_and_reservoirs.map
#~ drwxr-xr-x+  3 edwin edwin  4.0K May  3 05:41 version1
#~ lrwxrwxrwx.  1 edwin edwin   167 May  3 01:05 waterBodies30min.nc -> /projects/0/dfguu/data/hydroworld/pcrglobwb2_input_release/version_2019_11_beta_extended/pcrglobwb2_input/global_30min/routing/surface_water_bodies/waterBodies30min.nc
#~ -rw-r--r--.  1 edwin edwin  5.0M May  3 01:07 waterBodies30min_2010.nc
#~ -rw-r--r--.  1 edwin edwin  1.1M May  3 01:14 waterBodyIds_waterBodies30min_2010.nc
#~ -rw-r--r--.  1 edwin edwin  1.1M May  3 01:14 waterBodyTyp_waterBodies30min_2010.nc

# Convert raster to data frame for ggplot
raster_df <- as.data.frame(raster_data, xy = TRUE)
names(raster_df) <- c("x", "y", "value")

# Remove NA values if desired (optional)
raster_df <- na.omit(raster_df)

# Get ColorBrewer palette: YlGnBu with 9 colors
color_palette <- brewer.pal(9, "YlGnBu")

#~ wg <- map_data("world")

# Create the ggplot

# adjust the max values
raster_df_original = raster_df
max_value = 10000
raster_df$value[raster_df$value >= max_value] = max_value

a <- ggplot() +
#~   geom_map(data = wg, map = wg, mapping = aes(long, lat, map_id = region), color = "white") +
  geom_raster(data = raster_df, mapping = aes(x = x, y = y, fill = value)) +
  xlim(-180, 180) +
  ylim(-55, 75) +
  scale_fill_gradientn(
    colors = color_palette,
#~     name = "Value",  # Change legend title as needed
    name = expression("discharge (m"^3*"/s)"),
#~     limits = c(min(raster_df$value), max(raster_df$value))
    limits = c(0, max(raster_df$value))
#~     limits = c(0, 10000.)
  ) +
#~   coord_fixed() +
  theme_minimal() +
  labs(
#~     title = "Global Raster Map",
    title = expression("discharge (m"^3*"/s)"),
#~     x = "Longitude",
#~     y = "Latitude"
  ) +
#~   theme(
#~     plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
#~     legend.position = "right"
#~   )
  theme(
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank(),
    legend.position = "right"
        )

ggsave("test_discharge.pdf", a, height = 8, width = 16, units = 'in', dpi = 1200)
