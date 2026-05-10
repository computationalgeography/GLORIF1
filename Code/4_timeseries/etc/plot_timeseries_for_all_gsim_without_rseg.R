
# additional library to read directly from a netcdf file
library(ggplot2)
library(ncdf4)

# gsim station code
# - chosen by Busra: AU_0000107, BR_0000611, RU_0000141, ZW_0000064, ZA_0000008, CN_0000001
#~ gsim_code = "AU_0000107"
#~ gsim_code = "CN_0000001"
#~ gsim_code = "ZA_0000008"
#~ gsim_code = "ZW_0000064"
#~ gsim_code = "RU_0000141"

# output directory
outputDir = "/scratch-shared/edwin/_finalizing_glorif1/gsim_timeseries_plots/"

# loop through all gstation 
#
# - table containing gsim codes
gsim_table_filename = "/projects/0/dfguu/users/edwin/data/glorif1/original/version_1.0/output/kge_glorif1_gsim.csv"
gsim_table_filename = "/projects/0/dfguu/users/edwin/data/glorif1/original/version_1.0/output/kge_pcrglobwb_gsim.csv"
gsim_table = read.csv(gsim_table_filename, header = TRUE)
gsim_table = gsim_table[which(gsim_table$KGE < 2),]
#~ > names(gsim_table)
#~  [1] "cell_no_land" "gsim.no"      "KGE"          "KGE_r"        "KGE_alpha"
#~  [6] "KGE_beta"     "NSE"          "RMSE"         "MAE"          "nRMSE"
#~ [11] "nMAE"
#
# - Double check (based on the Mike's "cell_no_land") that GSIM station used are not in the training data
grdc_train_table_filename = "/projects/0/dfguu/users/edwin/data/glorif1/original/version_1.0/random_forest/train/bigTable_allpredictors_filtered_95.csv"
grdc_train_table = read.csv(grdc_train_table_filename, header = TRUE)
grdc_train_cell_no_land = unique(grdc_train_table$cell_no_land)
rm(grdc_train_table)
gsim_table = gsim_table[which(!is.element(gsim_table$cell_no_land, grdc_train_cell_no_land)),]

# - Using only the ones with valid performance
gsim_codes = gsim_table$gsim.no[which(gsim_table$KGE < 2)] 

# - now looping
for (gsim_code in gsim_codes) {


# gsim time series
gsim_folder = "/scratch-shared/edwin/_finalizing_glorif1/datasets_for_plots/gsim/gsim_discharge/"
gsim_stat_filename = paste(gsim_folder, "/gsim_", gsim_code, ".csv", sep = "")
gsim_time_series = read.csv(gsim_stat_filename, header = TRUE)

# only process if GSIM time series contain values
if (length(gsim_time_series$obs[which(gsim_time_series$obs > 0.0)]) > 0) {

# adopt the gsim time series to a new table/data frame
merged_table = gsim_time_series
names(merged_table)[1] <- "date"
names(merged_table)[2] <- "GSIM"
merged_table$date <- as.Date(merged_table$date)

# Code, river, station, country, lat/lon_original (GSIM)
gsim_metadata_table_filename = "/projects/0/dfguu/users/edwin/data/glorif1/original/version_1.0/validation_data/validation_data/GSIM_metadata/GSIM_catalog/GSIM_metadata.csv"
gsim_metadata_table = read.csv(gsim_metadata_table_filename, header = TRUE)
gsim_river_name   = gsim_metadata_table$river[which(gsim_metadata_table$gsim.no == gsim_code)]
gsim_station_name = gsim_metadata_table$station[which(gsim_metadata_table$gsim.no == gsim_code)]
gsim_country_name = gsim_metadata_table$country[which(gsim_metadata_table$gsim.no == gsim_code)]
gsim_latitude     = gsim_metadata_table$latitude[which(gsim_metadata_table$gsim.no == gsim_code)]
gsim_longitude    = gsim_metadata_table$longitude[which(gsim_metadata_table$gsim.no == gsim_code)]

#~ > names(gsim_metadata_table)
#~  [1] "gsim.no"               "reference.db"          "reference.no"
#~  [4] "grdb.merge"            "grdb.no"               "paired.db"
#~  [7] "paired.db.no"          "river"                 "station"
#~ [10] "country"               "latitude"              "longitude"
#~ [13] "altitude"              "area"                  "unit"
#~ [16] "river.dist"            "station.dist"          "latlon.dist"
#~ [19] "bin.latlon.dist"       "mean.dist"             "number.overlap"
#~ [22] "number.available.days" "number.missing.days"   "frac.missing.days"
#~ [25] "year.start"            "year.end"              "year.no"

# get the coordinates (based on the PCR-GLOBWB)
gsim_station_table_filename = "/scratch-shared/edwin/_finalizing_glorif1/datasets_for_plots/gsim/preprocess_gsim/station_pixel_mapping_gsim.csv"
gsim_station_table = read.csv(gsim_station_table_filename, header = TRUE)
lat = gsim_station_table$lat[which(gsim_station_table$gsim.no == gsim_code)]
lon = gsim_station_table$lon[which(gsim_station_table$gsim.no == gsim_code)]


# KGE and NSE based on PCR-GLOBWB validation to GSIM
performance_pcrglobwb_gsim_table_filename = "/projects/0/dfguu/users/edwin/data/glorif1/original/version_1.0/output/kge_pcrglobwb_gsim.csv"
performance_pcrglobwb_gsim_table = read.csv(performance_pcrglobwb_gsim_table_filename, header = TRUE)
kge_pcrglobwb_gsim = performance_pcrglobwb_gsim_table$KGE[which(performance_pcrglobwb_gsim_table$gsim.no == gsim_code)]
nse_pcrglobwb_gsim = performance_pcrglobwb_gsim_table$NSE[which(performance_pcrglobwb_gsim_table$gsim.no == gsim_code)]

# KGE and NSE based on GLORIF validation to and GSIM
performance_glorif1_gsim_table_filename = "/projects/0/dfguu/users/edwin/data/glorif1/original/version_1.0/output/kge_glorif1_gsim.csv"
performance_glorif1_gsim_table = read.csv(performance_glorif1_gsim_table_filename, header = TRUE)
kge_glorif1_gsim = performance_glorif1_gsim_table$KGE[which(performance_glorif1_gsim_table$gsim.no == gsim_code)]
nse_glorif1_gsim = performance_glorif1_gsim_table$NSE[which(performance_glorif1_gsim_table$gsim.no == gsim_code)]


# load the GLORIF1 time series
glorif1_nc_filename = "/scratch-shared/edwin/_finalizing_glorif1/datasets_for_plots/glorif1_discharge_30min_monthly.nc"
glorif1_nc <- nc_open(glorif1_nc_filename)
glorif1_discharge <- ncvar_get(glorif1_nc, "discharge") 
glorif1_lat <- ncvar_get(glorif1_nc, "lat")
glorif1_lon <- ncvar_get(glorif1_nc, "lon")
glorif1_discharge_selected <- glorif1_discharge[which(glorif1_lon == lon), which(glorif1_lat == lat), ]
merged_table = cbind(merged_table, glorif1_discharge_selected)
names(merged_table)[3] <- "GLORIF1"

# load the pcrglobwb time series
pcrglobwb_nc_filename = "/scratch-shared/edwin/_finalizing_glorif1/datasets_for_plots/pcrglobwb_discharge_original_30min_monthly.nc"
pcrglobwb_nc <- nc_open(pcrglobwb_nc_filename)
pcrglobwb_discharge <- ncvar_get(pcrglobwb_nc, "discharge") 
pcrglobwb_lat <- ncvar_get(pcrglobwb_nc, "lat")
pcrglobwb_lon <- ncvar_get(pcrglobwb_nc, "lon")
pcrglobwb_discharge_selected <- pcrglobwb_discharge[which(pcrglobwb_lon == lon), which(pcrglobwb_lat == lat), ]
merged_table = cbind(merged_table, pcrglobwb_discharge_selected)
names(merged_table)[4] <- "PCRGLOBWB"


#~ -rw-r--r--. 1 edwin edwin 487M Mar 25 09:26 percentile_0p025_glorif1_discharge_30min_monthly.nc
#~ -rw-r--r--. 1 edwin edwin 487M Mar 25 09:27 percentile_0p500_glorif1_discharge_30min_monthly.nc
#~ -rw-r--r--. 1 edwin edwin 487M Mar 25 09:27 percentile_0p975_glorif1_discharge_30min_monthly.nc


# load the percentile time series
# - 2.5%
percentile_02p5_nc_filename = "/scratch-shared/edwin/_finalizing_glorif1/datasets_for_plots/percentile_0p025_glorif1_discharge_30min_monthly.nc"
percentile_02p5_nc <- nc_open(percentile_02p5_nc_filename)
percentile_02p5_discharge <- ncvar_get(percentile_02p5_nc, "discharge") 
percentile_02p5_lat <- ncvar_get(percentile_02p5_nc, "lat")
percentile_02p5_lon <- ncvar_get(percentile_02p5_nc, "lon")
percentile_02p5_discharge_selected <- percentile_02p5_discharge[which(percentile_02p5_lon == lon), which(percentile_02p5_lat == lat), ]
merged_table = cbind(merged_table, percentile_02p5_discharge_selected)
names(merged_table)[5] <- "percentile_02p5"
# - 97.5%
percentile_97p5_nc_filename = "/scratch-shared/edwin/_finalizing_glorif1/datasets_for_plots/percentile_0p975_glorif1_discharge_30min_monthly.nc"
percentile_97p5_nc <- nc_open(percentile_97p5_nc_filename)
percentile_97p5_discharge <- ncvar_get(percentile_97p5_nc, "discharge") 
percentile_97p5_lat <- ncvar_get(percentile_97p5_nc, "lat")
percentile_97p5_lon <- ncvar_get(percentile_97p5_nc, "lon")
percentile_97p5_discharge_selected <- percentile_97p5_discharge[which(percentile_97p5_lon == lon), which(percentile_97p5_lat == lat), ]
merged_table = cbind(merged_table, percentile_97p5_discharge_selected)
names(merged_table)[6] <- "percentile_97p5"


# Plotting the monthly chart !
####################################################################################################################################
#
# x and y- axis scales:
y_min = 0
y_max = max(merged_table[,2:5], na.rm=TRUE)
#~ y_max = max(merged_table$GLORIF1)
#~ y_max_alt = max(merged_table$percentile_97p5)
y_max_alt = quantile(merged_table$percentile_97p5,  probs = c(0.1, 97.5)/100)[2]
y_max = max(y_max, y_max_alt)

if (y_max > 100) {y_max = ceiling((y_max+75)/100)*100} else {y_max = 100}
#
x_min = min(merged_table$date,na.rm=T) - 365*7
x_max = max(merged_table$date,na.rm=T)
#
#~ x_info_text = x_min + 365*0.5
x_info_text = x_min

#~ # about geom_ribbon
#~ https://ggplot2.tidyverse.org/reference/geom_ribbon.html
#~ https://stackoverflow.com/questions/38777337/ggplot-ribbon-cut-off-at-y-limits

# for plotting purpose, limit percentile_97p5 to ymax
merged_table$percentile_97p5[which(merged_table$percentile_97p5 > y_max-1)] = y_max-1

outplott <- ggplot()
outplott <- outplott +

 geom_ribbon(data = merged_table, mapping = aes(x = date, ymin = percentile_02p5, ymax = percentile_97p5), fill = "grey70") +
 geom_line(data = merged_table, mapping = aes(x = date, y = GSIM), color =  "yellow",   linewidth   = 0.8)  +  # measurement (gsim)
 geom_line(data = merged_table, mapping = aes(x = date, y = GLORIF1 ), color = "blue", linewidth    = 0.3)  +  # model results
 geom_line(data = merged_table, mapping = aes(x = date, y = PCRGLOBWB ), color = "black", linewidth = 0.15) +  # original pcrglobwb

 geom_text(aes(x = x_info_text, y = 0.90*y_max, label = paste("GSIM code: "              , gsim_code                   , sep="")), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.85*y_max, label = paste("River: "                  , gsim_river_name             , sep="")), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.80*y_max, label = paste("Station: "                , gsim_station_name           , sep="")), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.75*y_max, label = paste("Country: "                , gsim_country_name           , sep="")), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.70*y_max, label = paste("GSIM latitude: "          , gsim_latitude               , sep="")), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.65*y_max, label = paste("GSIM longitude: "         , gsim_longitude              , sep="")), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.60*y_max, label = paste("Model latitude: "         , lat                         , sep="")), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.55*y_max, label = paste("Model longitude: "        , lon                         , sep="")), size = 2.5,hjust = 0) +

 geom_text(aes(x = x_info_text, y = 0.40*y_max, label = paste("KGE PCR-GLOBWB = ", round(kge_pcrglobwb_gsim, 2), sep="")), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.35*y_max, label = paste("NSE PCR-GLOBWB = ", round(nse_pcrglobwb_gsim, 2), sep="")), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.20*y_max, label = paste("KGE GLORIF1 = "   , round(kge_glorif1_gsim  , 2), sep="")), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.15*y_max, label = paste("NSE GLORIF1 = "   , round(nse_glorif1_gsim  , 2), sep="")), size = 2.5,hjust = 0) +

#~ #
#~  scale_y_continuous("discharge (m^3/s)",limits=c(y_min,y_max)) +
 scale_y_continuous(name = expression("discharge (m"^3*"/s)"),limits=c(y_min,y_max)) +
 scale_x_date('',limits=c(x_min,x_max)) +
 theme(legend.position = "none") 

#ggsave("screen.pdf", plot = outplott,width=30,height=8.25,units='cm')

#~outputFile = "test"
 
 # outputFile should contain country, river, station name
 outputFile <- paste(gsim_country_name, gsim_river_name, gsim_station_name, sep = "_")
 outputFile <- gsub('[^[:alnum:] ]', '-', outputFile)
 outputFile <- gsub(' ', '-', outputFile)
 
#~ your_string <- "Hello, World! @2026 #R"
#~ cleaned_string <- gsub('[^[:alnum:] ]', '', your_string)
#~ print(cleaned_string)
#~ [1] "Hello World 2026 R"
 
 outputFile = paste(outputDir, "gsim_validation_tss_", gsim_code, "_", outputFile, ".pdf",sep="")

 ggsave(outputFile, plot = outplott,width=27,height=7,units='cm')
#
rm(outplott)
print(outputFile)
}
}
