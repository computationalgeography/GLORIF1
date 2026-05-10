# Load required packages
library(rgdal)       # for GDAL-based raster reading (GDALBindings)
library(raster)      # raster handling
library(ggplot2)     # plotting
library(viridis)     # color scales (optional)
library(scales)      # for pretty breaks

# 1) Read raster via GDAL (use path to your file)
# Supported formats by GDAL (GeoTIFF, NetCDF, etc.)
r_path <- "path/to/your/global_raster.tif"
r <- raster(r_path)

# 2) If very large, optionally aggregate / resample for faster plotting:
# r <- aggregate(r, fact=4)   # reduce resolution by factor 4

# 3) Convert raster to data.frame for ggplot
# This creates columns: x (lon), y (lat), value
r_df <- as.data.frame(r, xy = TRUE, na.rm = TRUE)
colnames(r_df)[3] <- "value"

# 4) Choose color palette and breaks for legend
# Example: continuous viridis palette with manual breaks
n_colors <- 256
palette <- viridis(n_colors)

# Define pretty break points for the legend (adjust depending on data)
breaks <- pretty(range(r_df$value, na.rm = TRUE), n = 7)
labels <- format(breaks, digits = 3)

# 5) Plot with ggplot2
p <- ggplot(r_df, aes(x = x, y = y, fill = value)) +
  geom_raster(interpolate = TRUE) +
  coord_quickmap(expand = FALSE) +                     # preserves aspect for lat/lon
  scale_fill_gradientn(
    colours = palette,
    limits = range(r_df$value, na.rm = TRUE),
    breaks = breaks,
    labels = labels,
    name = "Value"                                     # legend title
  ) +
  labs(x = "Longitude", y = "Latitude", title = "Global Raster Map") +
  theme_minimal() +
  theme(
    legend.position = "right",
    plot.title = element_text(hjust = 0.5)
  )

# Print plot
print(p)
