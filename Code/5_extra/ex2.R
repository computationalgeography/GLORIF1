library(raster)      # raster handling
library(rgdal)       # GDAL bindings (optional)
library(ggplot2)
library(scales)      # for pretty breaks

# 1) load raster (replace path)
r_path <- "path/to/your/global_raster.tif"
r <- raster(r_path)          # reads via GDAL-backed drivers

# 2) (optional) reproject to lon/lat if needed
if (!compareCRS(r, CRS("+proj=longlat +datum=WGS84"))) {
  r <- projectRaster(r, crs = CRS("+proj=longlat +datum=WGS84"))
}

# 3) reduce resolution for faster plotting if very large
# r <- aggregate(r, fact = 2)

# 4) convert to data.frame for ggplot
r_df <- as.data.frame(r, xy = TRUE, na.rm = TRUE)
names(r_df)[3] <- "value"

# 5) ColorBrewer YlGnBu (9-class) hex codes
ylgnbu9 <- c("#ffffd9","#edf8b1","#c7e9b4","#7fcdbb","#41b6c4",
             "#1d91c0","#225ea8","#253494","#081d58")

# 6) define breaks/limits
val_range <- range(r_df$value, na.rm = TRUE)
breaks <- pretty(val_range, n = 6)

# 7) plot
ggplot(r_df, aes(x = x, y = y, fill = value)) +
  geom_raster(interpolate = TRUE) +
  coord_quickmap(expand = FALSE) +
  scale_fill_gradientn(
    colours = ylgnbu9,
    limits = val_range,
    breaks = breaks,
    labels = comma_format()(breaks),
    name = "Value"
  ) +
  labs(x = "Longitude", y = "Latitude", title = "Global raster (YlGnBu)") +
  theme_minimal() +
  theme(legend.position = "right", plot.title = element_text(hjust = 0.5))
  
  
#~   pal_cont <- colorRampPalette(ylgnbu9)
#~ scale_fill_gradientn(colours = pal_cont(256), ...)
