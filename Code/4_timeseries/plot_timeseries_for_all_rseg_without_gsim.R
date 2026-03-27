
# additional library to read directly from a netcdf file
library(ggplot2)
library(ncdf4)

# output directory
outputDir = "/scratch-shared/edwin/_finalizing_glorif1/rseg_timeseries_plots/"

#~ edwin@tcn679.local.snellius.surf.nl:/scratch-shared/edwin/_finalizing_glorif1/rseg_validation$ ls -lah
#~ total 1.4M
#~ drwxr-xr-x+ 2 edwin edwin 4.0K Mar 23 11:39 .
#~ drwxr-xr-x+ 5 edwin edwin 4.0K Mar 23 20:25 ..
#~ -rw-r--r--. 1 edwin edwin 697K Nov 26 11:31 kge_results_glorif1_rseg_validation.csv
#~ -rw-r--r--. 1 edwin edwin 696K Nov 26 11:25 kge_results_pgb_rseg_validation.csv
#~ -rw-r--r--. 1 edwin edwin   48 Mar 23 11:39 source.txt

# loop through all gstations 
#
# - table containing rseg codes
rseg_table_filename = "/scratch-shared/edwin/_finalizing_glorif1/rseg_validation/kge_results_pgb_rseg_validation.csv"
rseg_table_filename = "/scratch-shared/edwin/_finalizing_glorif1/rseg_validation/kge_results_glorif1_rseg_validation.csv"
rseg_table = read.csv(rseg_table_filename, header = TRUE)
rseg_table = rseg_table[which(rseg_table$KGE < 2),]
#~ > names(rseg_table)
#~  [1] "cell_no_land" "rseg.no"      "KGE"          "KGE_r"        "KGE_alpha"
#~  [6] "KGE_beta"     "NSE"          "RMSE"         "MAE"          "nRMSE"
#~ [11] "nMAE"

# - Using only the ones with valid performance
rseg_codes = rseg_table$rseg.no[which(rseg_table$KGE < 2)] 

# - rseg nc file
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


# - now looping
for (rseg_code in rseg_codes) {

# rseg time series
# get the GRDC idx
grdc_idx = which(rseg_grdc_no == rseg_code)

# Extract the time series and add it to the table
rseg_time_series = rseg_discharge_selected[, grdc_idx]    


rseg_folder = "/scratch-shared/edwin/_finalizing_glorif1/datasets_for_plots/rseg/rseg_discharge/"
rseg_stat_filename = paste(rseg_folder, "/rseg_", rseg_code, ".csv", sep = "")
rseg_time_series = read.csv(rseg_stat_filename, header = TRUE)

# only process if RSEG time series contain values
if (length(rseg_time_series[which(rseg_time_series > 0.0)]) > 0) {

# adopt the rseg time series to a new table/data frame
date <- seq(as.Date("1979-01-01"), as.Date("2019-01-01"),by = "1 month")
merged_table = data.frame(date, rseg_time_series)
names(merged_table)[1] <- "date"
names(merged_table)[2] <- "RSEG"
merged_table$date <- as.Date(merged_table$date)

# Code, river, station, country, lat/lon_original (RSEG/GRDC)
rseg_metadata_table_filename = "/scratch-shared/edwin/_finalizing_glorif1/datasets_for_plots/rseg/rseg_grdc/grdc_catal_downloaded_on_20260326/grdc_stations.csv"
rseg_metadata_table = read.csv(rseg_metadata_table_filename, header = TRUE)
rseg_river_name   = rseg_metadata_table$river[which(rseg_metadata_table$grdc_no == rseg_code)]
rseg_station_name = rseg_metadata_table$station[which(rseg_metadata_table$grdc_no == rseg_code)]
rseg_country_name = rseg_metadata_table$country[which(rseg_metadata_table$grdc_no == rseg_code)]
rseg_latitude     = rseg_metadata_table$lat[which(rseg_metadata_table$grdc_no == rseg_code)]
rseg_longitude    = rseg_metadata_table$long[which(rseg_metadata_table$grdc_no == rseg_code)]

#~ > names(rseg_metadata_table)
#~  [1] "grdc_no"       "wmo_reg"       "sub_reg"       "river"
#~  [5] "station"       "country"       "lat"           "long"
#~  [9] "area"          "altitude"      "d_start"       "d_end"
#~ [13] "d_yrs"         "d_miss"        "m_start"       "m_end"
#~ [17] "m_yrs"         "m_miss"        "t_start"       "t_end"
#~ [21] "t_yrs"         "lta_discharge" "r_volume_yr"   "r_height_yr"

# get the coordinates (based on the PCR-GLOBWB)
rseg_station_table_filename = "/scratch-shared/edwin/_finalizing_glorif1/datasets_for_plots/rseg/preprocess_rseg/station_pixel_mapping_rseg.csv"
rseg_station_table = read.csv(rseg_station_table_filename, header = TRUE)
lat = rseg_station_table$lat[which(rseg_station_table$grdc_no == rseg_code)]
lon = rseg_station_table$lon[which(rseg_station_table$grdc_no == rseg_code)]


# KGE and NSE based on PCR-GLOBWB validation to RSEG
performance_pcrglobwb_rseg_table_filename = "/scratch-shared/edwin/_finalizing_glorif1/rseg_validation/kge_results_pgb_rseg_validation.csv"
performance_pcrglobwb_rseg_table = read.csv(performance_pcrglobwb_rseg_table_filename, header = TRUE)
kge_pcrglobwb_rseg = performance_pcrglobwb_rseg_table$KGE[which(performance_pcrglobwb_rseg_table$rseg.no == rseg_code)]
nse_pcrglobwb_rseg = performance_pcrglobwb_rseg_table$NSE[which(performance_pcrglobwb_rseg_table$rseg.no == rseg_code)]

# KGE and NSE based on GLORIF validation to and RSEG
performance_glorif1_rseg_table_filename = "/scratch-shared/edwin/_finalizing_glorif1/rseg_validation/kge_results_glorif1_rseg_validation.csv"
performance_glorif1_rseg_table = read.csv(performance_glorif1_rseg_table_filename, header = TRUE)
kge_glorif1_rseg = performance_glorif1_rseg_table$KGE[which(performance_glorif1_rseg_table$rseg.no == rseg_code)]
nse_glorif1_rseg = performance_glorif1_rseg_table$NSE[which(performance_glorif1_rseg_table$rseg.no == rseg_code)]


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
 geom_line(data = merged_table, mapping = aes(x = date, y = RSEG), color =  "yellow",   linewidth   = 0.8)  +  # measurement (rseg)
 geom_line(data = merged_table, mapping = aes(x = date, y = GLORIF1 ), color = "blue", linewidth    = 0.3)  +  # model results
 geom_line(data = merged_table, mapping = aes(x = date, y = PCRGLOBWB ), color = "black", linewidth = 0.15) +  # original pcrglobwb

 geom_text(aes(x = x_info_text, y = 0.90*y_max, label = paste("RSEG/GRDC code: "         , rseg_code                   , sep="")), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.85*y_max, label = paste("River: "                  , rseg_river_name             , sep="")), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.80*y_max, label = paste("Station: "                , rseg_station_name           , sep="")), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.75*y_max, label = paste("Country: "                , rseg_country_name           , sep="")), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.70*y_max, label = paste("GRDC latitude: "          , rseg_latitude               , sep="")), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.65*y_max, label = paste("GRDC longitude: "         , rseg_longitude              , sep="")), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.60*y_max, label = paste("Model latitude: "         , lat                         , sep="")), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.55*y_max, label = paste("Model longitude: "        , lon                         , sep="")), size = 2.5,hjust = 0) +

 geom_text(aes(x = x_info_text, y = 0.40*y_max, label = paste("KGE PCR-GLOBWB = ", round(kge_pcrglobwb_rseg, 2), sep="")), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.35*y_max, label = paste("NSE PCR-GLOBWB = ", round(nse_pcrglobwb_rseg, 2), sep="")), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.20*y_max, label = paste("KGE GLORIF1 = "   , round(kge_glorif1_rseg  , 2), sep="")), size = 2.5,hjust = 0) +
 geom_text(aes(x = x_info_text, y = 0.15*y_max, label = paste("NSE GLORIF1 = "   , round(nse_glorif1_rseg  , 2), sep="")), size = 2.5,hjust = 0) +

#~ #
#~  scale_y_continuous("discharge (m^3/s)",limits=c(y_min,y_max)) +
 scale_y_continuous(name = expression("discharge (m"^3*"/s)"),limits=c(y_min,y_max)) +
 scale_x_date('',limits=c(x_min,x_max)) +
 theme(legend.position = "none") 

#ggsave("screen.pdf", plot = outplott,width=30,height=8.25,units='cm')

#~outputFile = "test"
 
 # outputFile should contain country, river, station name
 outputFile <- paste(rseg_country_name, rseg_river_name, rseg_station_name, sep = "_")
 outputFile <- gsub('[^[:alnum:] ]', '-', outputFile)
 outputFile <- gsub(' ', '-', outputFile)
 
#~ your_string <- "Hello, World! @2026 #R"
#~ cleaned_string <- gsub('[^[:alnum:] ]', '', your_string)
#~ print(cleaned_string)
#~ [1] "Hello World 2026 R"
 
 outputFile = paste(outputDir, "rseg_validation_tss_", rseg_code, "_", outputFile, ".pdf",sep="")

 ggsave(outputFile, plot = outplott,width=27,height=7,units='cm')
#
rm(outplott)
print(outputFile)
}
}
