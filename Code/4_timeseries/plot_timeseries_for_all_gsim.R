
# additional library to read directly from a netcdf file
library(ggplot2)
library(ncdf4)

# gsim station code
# - chosen by Busra: AU_0000107, BR_0000611, RU_0000141, ZW_0000064, ZA_0000008, CN_0000001
#~ gsim_code = "AU_0000107"
#~ gsim_code = "CN_0000001"
#~ gsim_code = "ZA_0000008"
#~ gsim_code = "ZW_0000064"
gsim_code = "RU_0000141"

# Info to be added: Code, river, station, country, lat/lon_original, lat/lon_pgb, KGE and NSE

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

# TODO: Double check (based on the Mike's "cell_no_land") that GSIM station used are not in the training data
grdc_train_table = "/projects/0/dfguu/users/edwin/data/glorif1/original/version_1.0/random_forest/train/bigTable_allpredictors_filtered_95.csv"

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

# gsim time series
gsim_folder = "/scratch-shared/edwin/_finalizing_glorif1/datasets_for_plots/gsim/gsim_discharge/"
gsim_stat_filename = paste(gsim_folder, "/gsim_", gsim_code, ".csv", sep = "")
gsim_time_series = read.csv(gsim_stat_filename, header = TRUE)

# adopt the gsim time series to a new table/data frame
merged_table = gsim_time_series
names(merged_table)[1] <- "date"
names(merged_table)[2] <- "GSIM"
merged_table$date <- as.Date(merged_table$date)

# rseg time series (if exist)
# - start with an empty table
merged_table <- cbind(merged_table, NA)
names(merged_table)[3] <-"RSEG"
# - rseg station table/catalogue with the lat/lon based on PCR-GLOBWB
rseg_station_table_filename = "/scratch-shared/edwin/_finalizing_glorif1/datasets_for_plots/rseg/preprocess_rseg/station_pixel_mapping_rseg.csv"
rseg_station_table = read.csv(rseg_station_table_filename, header = TRUE)
# - rseg code (if corresponding with gsim)
rseg_code = rseg_station_table$grdc_no[which(rseg_station_table$lat == lat & rseg_station_table$lon == lon)]
#
if (length(rseg_code) > 0) {
rseg_nc_filename = "/scratch-shared/edwin/_finalizing_glorif1/datasets_for_plots/rseg/rseg_grdc/RSEG_V01.nc"
rseg_nc <- nc_open(rseg_nc_filename)
rseg_grdc_no   <- ncvar_get(rseg_nc, "GRDC_Num")
rseg_discharge <- ncvar_get(rseg_nc, "Disch")

# Filter time range from 1979-01-01 to 2019-12-31
rseg_time  <- as.Date(ncvar_get(rseg_nc, "Time"), origin = "1806-01-01")
start_date <- as.Date("1979-01-01")
end_date   <- as.Date("2019-12-31")
time_idx   <- which(rseg_time >= start_date & rseg_time <= end_date)
# - Discharge 1979-2019 only
rseg_discharge_selected <- rseg_discharge[time_idx,]
# - Set all negative to NaN
rseg_discharge_selected[which(rseg_discharge_selected < 0.0)] <- NA

# get the GRDC idx
grdc_idx = which(rseg_grdc_no == rseg_code)

# Extract the time series and add it to the table
rseg_time_series = rseg_discharge_selected[, grdc_idx]    
merged_table$RSEG = rseg_time_series

# lat and lon based on RSEG
rseg_lats = ncvar_get(rseg_nc, "Lat")
rseg_lons = ncvar_get(rseg_nc, "Lon")
rseg_lat = rseg_lats[grdc_idx]
rseg_lon = rseg_lons[grdc_idx]


# get the performances based on the following tables

#~ edwin@tcn679.local.snellius.surf.nl:/scratch-shared/edwin/_finalizing_glorif1/rseg_validation$ ls -lah
#~ total 1.4M
#~ drwxr-xr-x+ 2 edwin edwin 4.0K Mar 23 11:39 .
#~ drwxr-xr-x+ 5 edwin edwin 4.0K Mar 23 20:25 ..
#~ -rw-r--r--. 1 edwin edwin 697K Nov 26 11:31 kge_results_glorif1_rseg_validation.csv
#~ -rw-r--r--. 1 edwin edwin 696K Nov 26 11:25 kge_results_pgb_rseg_validation.csv
#~ -rw-r--r--. 1 edwin edwin   48 Mar 23 11:39 source.txt

# KGE and NSE based on PCR-GLOBWB validation to RSEG
performance_pcrglobwb_rseg_table_filename = "/scratch-shared/edwin/_finalizing_glorif1/rseg_validation/kge_results_pgb_rseg_validation.csv"
performance_pcrglobwb_rseg_table = read.csv(performance_pcrglobwb_rseg_table_filename, header = TRUE)
kge_pcrglobwb_rseg = performance_pcrglobwb_rseg_table$KGE[which(performance_pcrglobwb_rseg_table$grdc_no == rseg_code)]
nse_pcrglobwb_rseg = performance_pcrglobwb_rseg_table$NSE[which(performance_pcrglobwb_rseg_table$grdc_no == rseg_code)]

# KGE and NSE based on GLORIF validation to and RSEG
performance_glorif1_rseg_table_filename = "/scratch-shared/edwin/_finalizing_glorif1/rseg_validation/kge_results_glorif1_rseg_validation.csv"
performance_glorif1_rseg_table = read.csv(performance_glorif1_rseg_table_filename, header = TRUE)
kge_glorif1_rseg = performance_glorif1_rseg_table$KGE[which(performance_glorif1_rseg_table$grdc_no == rseg_code)]
nse_glorif1_rseg = performance_glorif1_rseg_table$NSE[which(performance_glorif1_rseg_table$grdc_no == rseg_code)]


} else {
# - empty infos if no rseg_code found
rseg_code = NA
rseg_lat  = NA
rseg_lon  = NA
kge_pcrglobwb_rseg = NA
nse_pcrglobwb_rseg = NA
kge_glorif1_rseg = NA
nse_glorif1_rseg = NA
    
}
# load the GLORIF1 time series
glorif1_nc_filename = "/scratch-shared/edwin/_finalizing_glorif1/datasets_for_plots/glorif1_discharge_30min_monthly.nc"
glorif1_nc <- nc_open(glorif1_nc_filename)
glorif1_discharge <- ncvar_get(glorif1_nc, "discharge") 
glorif1_lat <- ncvar_get(glorif1_nc, "lat")
glorif1_lon <- ncvar_get(glorif1_nc, "lon")
glorif1_discharge_selected <- glorif1_discharge[which(glorif1_lon == lon), which(glorif1_lat == lat), ]
merged_table = cbind(merged_table, glorif1_discharge_selected)
names(merged_table)[4] <- "GLORIF1"

# load the pcrglobwb time series
pcrglobwb_nc_filename = "/scratch-shared/edwin/_finalizing_glorif1/datasets_for_plots/pcrglobwb_discharge_original_30min_monthly.nc"
pcrglobwb_nc <- nc_open(pcrglobwb_nc_filename)
pcrglobwb_discharge <- ncvar_get(pcrglobwb_nc, "discharge") 
pcrglobwb_lat <- ncvar_get(pcrglobwb_nc, "lat")
pcrglobwb_lon <- ncvar_get(pcrglobwb_nc, "lon")
pcrglobwb_discharge_selected <- pcrglobwb_discharge[which(pcrglobwb_lon == lon), which(pcrglobwb_lat == lat), ]
merged_table = cbind(merged_table, pcrglobwb_discharge_selected)
names(merged_table)[5] <- "PCRGLOBWB"


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
names(merged_table)[6] <- "percentile_02p5"
# - 97.5%
percentile_97p5_nc_filename = "/scratch-shared/edwin/_finalizing_glorif1/datasets_for_plots/percentile_0p975_glorif1_discharge_30min_monthly.nc"
percentile_97p5_nc <- nc_open(percentile_97p5_nc_filename)
percentile_97p5_discharge <- ncvar_get(percentile_97p5_nc, "discharge") 
percentile_97p5_lat <- ncvar_get(percentile_97p5_nc, "lat")
percentile_97p5_lon <- ncvar_get(percentile_97p5_nc, "lon")
percentile_97p5_discharge_selected <- percentile_97p5_discharge[which(percentile_97p5_lon == lon), which(percentile_97p5_lat == lat), ]
merged_table = cbind(merged_table, percentile_97p5_discharge_selected)
names(merged_table)[7] <- "percentile_97p5"


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
x_min = min(merged_table$date,na.rm=T) - 365*5
x_max = max(merged_table$date,na.rm=T)
#
x_info_text = x_min + 365*0.5

#~ # about geom_ribbon
#~ https://ggplot2.tidyverse.org/reference/geom_ribbon.html
#~ https://stackoverflow.com/questions/38777337/ggplot-ribbon-cut-off-at-y-limits

# for plotting purpose, limit percentile_97p5 to ymax
merged_table$percentile_97p5[which(merged_table$percentile_97p5 > y_max-1)] = y_max-1

outplott <- ggplot()
outplott <- outplott +
#~  geom_ribbon(data = merged_table, mapping = aes(x = date, ymin = percentile_97p5, ymax = ), fill = "grey70") +
#~  geom_line(data = merged_table, mapping = aes(x = date, y = GSIM), color =  "red",  size = 0.90)  +  # measurement (gsim)
#~  geom_line(data = merged_table, mapping = aes(x = date, y = RSEG), color = "green", size = 0.90)  +  # measurement (rseg)
#~  geom_line(data = merged_table, mapping = aes(x = date, y = PCR-GLOBWB ), color = "black", size = 0.25)  +  # original pcrglobwb
#~  geom_line(data = merged_table, mapping = aes(x = date, y = GLORIF1 ), color = "blue",  size = 0.35 ) +  # model results

 geom_ribbon(data = merged_table, mapping = aes(x = date, ymin = percentile_02p5, ymax = percentile_97p5), fill = "grey70") +
 geom_line(data = merged_table, mapping = aes(x = date, y = GSIM), color =  "yellow",   linewidth = 1.2)  +  # measurement (gsim)
 geom_line(data = merged_table, mapping = aes(x = date, y = RSEG), color = "red", linewidth = 0.5, alpha = 0.8)  +  # measurement (rseg)
 geom_line(data = merged_table, mapping = aes(x = date, y = PCRGLOBWB ), color = "black", linewidth = 0.2)  +  # original pcrglobwb
 geom_line(data = merged_table, mapping = aes(x = date, y = GLORIF1 ), color = "blue", linewidth = 0.3) +  # model results

 geom_text(aes(x = x_info_text, y = 1.00*y_max, label = paste("GSIM code: "       , gsim_code        , sep=""), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.95*y_max, label = paste("River: "           , gsim_river_name  , sep=""), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.90*y_max, label = paste("Station: "         , gsim_station_name, sep=""), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.85*y_max, label = paste("Country: "         , gsim_country_name, sep=""), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.80*y_max, label = paste("GSIM latitude: "   , gsim_latitude    , sep=""), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.75*y_max, label = paste("GSIM longitude: "  , gsim_longitude   , sep=""), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.70*y_max, label = paste("RSEG (GRDC) code: ", rseg_code        , sep=""), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.65*y_max, label = paste("RSEG latitude: "   , rseg_lat         , sep=""), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.60*y_max, label = paste("RSEG longitude: "  , rseg_lon         , sep=""), size = 2.5,hjust = 0) +

 geom_text(aes(x = x_info_text, y = 0.45*y_max, label = paste(" KGE_PCR-GLOBWB (GSIM) = ", round(kge_pcrglobwb_gsim, 2),sep="")), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.40*y_max, label = paste(" KGE_GLORIF1    (GSIM) = ", round(kge_glorif1_gsim  , 2),sep="")), size = 2.5,hjust = 0) +

 geom_text(aes(x = x_info_text, y = 0.35*y_max, label = paste(" KGE_PCR-GLOBWB (RSEG) = ", round(kge_pcrglobwb_rseg, 2),sep="")), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.30*y_max, label = paste(" KGE_GLORIF1    (RSEG) = ", round(kge_glorif1_rseg  , 2),sep="")), size = 2.5,hjust = 0) +

 geom_text(aes(x = x_info_text, y = 0.25*y_max, label = paste(" NSE_PCR-GLOBWB (GSIM) = ", round(nse_pcrglobwb_gsim, 2),sep="")), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.20*y_max, label = paste(" NSE_GLORIF1    (GSIM) = ", round(nse_glorif1_gsim  , 2),sep="")), size = 2.5,hjust = 0) +

 geom_text(aes(x = x_info_text, y = 0.15*y_max, label = paste(" NSE_PCR-GLOBWB (RSEG) = ", round(nse_pcrglobwb_rseg, 2),sep="")), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.10*y_max, label = paste(" NSE_GLORIF1    (RSEG) = ", round(nse_glorif1_rseg  , 2),sep="")), size = 2.5,hjust = 0) +

#~ #
#~  scale_y_continuous("discharge (m^3/s)",limits=c(y_min,y_max)) +
 scale_y_continuous(name = expression("discharge (m"^3*"/s)"),limits=c(y_min,y_max)) +
 scale_x_date('',limits=c(x_min,x_max)) +
 theme(legend.position = "none") 
#ggsave("screen.pdf", plot = outplott,width=30,height=8.25,units='cm')
 outputFile = "test"
 ggsave(paste(outputFile,".pdf",sep=""), plot = outplott,width=27,height=7,units='cm')
#
#rm(outplott)
