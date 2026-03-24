
# additional library to read directly from a netcdf file
library(ggplot2)
library(ncdf4)

# gsim station code
# - chosen by Busra: AU_0000107, BR_0000611, RU_0000141, ZW_0000064, ZA_0000008, CN_0000001
gsim_code = "AU_0000107"

# get the coordinates
gsim_station_table_filename = "/scratch-shared/edwin/_finalizing_glorif1/datasets_for_plots/gsim/preprocess_gsim/station_pixel_mapping_gsim.csv"
gsim_station_table = read.csv(gsim_station_table_filename, header = TRUE)
lat = gsim_station_table$lat[which(gsim_station_table$gsim.no == gsim_code)]
lon = gsim_station_table$lon[which(gsim_station_table$gsim.no == gsim_code)]

# gsim time series
gsim_folder = "/scratch-shared/edwin/_finalizing_glorif1/datasets_for_plots/gsim/gsim_discharge/"
gsim_stat_filename = paste(gsim_folder, "/gsim_", gsim_code, ".csv", sep = "")
gsim_time_series = read.csv(gsim_stat_filename, header = TRUE)

# adopt the gsim time series to a new table/data frame
merged_table = gsim_time_series
names(merged_table)[1] <- "date"
names(merged_table)[2] <- "GSIM"

# rseg time series (if exist)
# - start with an empty table
merged_table <- cbind(merged_table, NA)
names(merged_table)[3] <-"RSEG"
# - rseg station table/catalogue
rseg_station_table_filename = "/scratch-shared/edwin/_finalizing_glorif1/datasets_for_plots/rseg/preprocess_rseg/station_pixel_mapping_rseg.csv"
rseg_station_table = read.csv(rseg_station_table_filename, header = TRUE)
# - rseg code (if corresponding with gsim)
rseg_code = rseg_station_table$grdc_no[which(rseg_station_table$lat == lat & rseg_station_table$lon == lon)]
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
names(merged_table)[5] <- "PCR-GLOBWB"

# load the percentile time series
# - 2.5%
percentile_02p5_nc_filename = "/scratch-shared/edwin/_finalizing_glorif1/datasets_for_plots/glorif1_discharge_0p025_30min_monthly.nc"
percentile_02p5_nc <- nc_open(percentile_02p5_nc_filename)
percentile_02p5_discharge <- ncvar_get(percentile_02p5_nc, "discharge") 
percentile_02p5_lat <- ncvar_get(percentile_02p5_nc, "lat")
percentile_02p5_lon <- ncvar_get(percentile_02p5_nc, "lon")
percentile_02p5_discharge_selected <- percentile_02p5_discharge[which(percentile_02p5_lon == lon), which(percentile_02p5_lat == lat), ]
merged_table = cbind(merged_table, percentile_02p5_discharge_selected)
names(merged_table)[5] <- "percentile_02p5"
# - 97.5%
percentile_97p5_nc_filename = "/scratch-shared/edwin/_finalizing_glorif1/datasets_for_plots/glorif1_discharge_0p975_30min_monthly.nc"
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
y_max = max(merged_table$percentile_97p5)
if (y_max > 100) {y_max = ceiling((y_max+75)/100)*100} else {y_max = 100}
#
#~ x_min = min(merged_table$date,na.rm=T) - 365*5
#~ x_max = max(merged_table$date,na.rm=T)
#~ #
#~ x_info_text = x_min + 365*0.5

#~ https://ggplot2.tidyverse.org/reference/geom_ribbon.html

outplott <- ggplot()
outplott <- outplott +
 geom_ribbon(data = merged_table, mapping = aes(x = date, ymin = percentile_97p5, ymax = percentile_97p5), fill = "grey70") +
 geom_line(data = merged_table, mapping = aes(x = date, y = GSIM), color =  "red",  size = 0.90)  +  # measurement (gsim)
 geom_line(data = merged_table, mapping = aes(x = date, y = RSEG), color = "green", size = 0.90)  +  # measurement (rseg)
 geom_line(data = merged_table, mapping = aes(x = date, y = PCR-GLOBWB ), color = "black", size = 0.25)  +  # original pcrglobwb
 geom_line(data = merged_table, mapping = aes(x = date, y = GLORIF1 ), color = "blue",  size = 0.35 ) +  # model results

#~  geom_line(data = merged_table, mapping = aes(x = date, y = observation), color =  "red") + # measurement
#~  geom_line(data = merged_table, mapping = aes(x = date, y = simulation ), color = "blue") + # model results
#
#~  geom_text(aes(x = x_info_text, y = 1.00*y_max, label = attributeStat[1]), size = 2.5,hjust = 0) +
#~  geom_text(aes(x = x_info_text, y = 0.95*y_max, label = attributeStat[2]), size = 2.5,hjust = 0) +
#~  geom_text(aes(x = x_info_text, y = 0.90*y_max, label = attributeStat[3]), size = 2.5,hjust = 0) +
#~  geom_text(aes(x = x_info_text, y = 0.85*y_max, label = attributeStat[4]), size = 2.5,hjust = 0) +
#~  geom_text(aes(x = x_info_text, y = 0.80*y_max, label = attributeStat[5]), size = 2.5,hjust = 0) +
#~  geom_text(aes(x = x_info_text, y = 0.75*y_max, label = attributeStat[6]), size = 2.5,hjust = 0) +
#~  geom_text(aes(x = x_info_text, y = 0.70*y_max, label = attributeStat[7]), size = 2.5,hjust = 0) +
#~  geom_text(aes(x = x_info_text, y = 0.65*y_max, label = attributeStat[8]), size = 2.5,hjust = 0) +
#~  geom_text(aes(x = x_info_text, y = 0.60*y_max, label = attributeStat[9]), size = 2.5,hjust = 0) +
#
#~  geom_text(aes(x = x_info_text, y = 0.55*y_max, label = paste(" nPairs = ",     round(nPairs     ,2),sep="")), size = 2.5,hjust = 0) +
#~  geom_text(aes(x = x_info_text, y = 0.50*y_max, label = paste(" avg obs/sim = ",round(avg_obs    ,2)," / ",round(avg_sim,2),sep="")), size = 2.5,hjust = 0) +
#
#~  geom_text(aes(x = x_info_text, y = 0.45*y_max, label = paste(" KGE_2009 = ",   round(KGE_2009   ,2),sep="")), size = 2.5,hjust = 0) +
#~  geom_text(aes(x = x_info_text, y = 0.40*y_max, label = paste(" KGE_2012 = ",   round(KGE_2012   ,2),sep="")), size = 2.5,hjust = 0) +
#
#~  geom_text(aes(x = x_info_text, y = 0.35*y_max, label = paste(" NSeff = ",      round(NSeff      ,2),sep="")), size = 2.5,hjust = 0) +
#~  geom_text(aes(x = x_info_text, y = 0.30*y_max, label = paste(" NSeff_log = ",  round(NSeff_log  ,2),sep="")), size = 2.5,hjust = 0) +
#~  geom_text(aes(x = x_info_text, y = 0.25*y_max, label = paste(" rmse = ",       round(rmse       ,2),sep="")), size = 2.5,hjust = 0) +
#~  geom_text(aes(x = x_info_text, y = 0.20*y_max, label = paste(" mae = ",        round(mae        ,2),sep="")), size = 2.5,hjust = 0) +
#~  geom_text(aes(x = x_info_text, y = 0.15*y_max, label = paste(" bias = ",       round(bias       ,2),sep="")), size = 2.5,hjust = 0) +
#~  geom_text(aes(x = x_info_text, y = 0.10*y_max, label = paste(" R2 / R2ad = ",  round(R2         ,2)," / ",round(R2ad   ,2),sep="")), size = 2.5,hjust = 0) +
#~  geom_text(aes(x = x_info_text, y = 0.05*y_max, label = paste(" sd obs/sim = ", round(sd_obs     ,2)," / ",round(sd_sim ,2),sep="")), size = 2.5,hjust = 0) +
#~  geom_text(aes(x = x_info_text, y = 0.00*y_max, label = paste(" correlation = ",round(correlation,2),sep="")), size = 2.5,hjust = 0) +
#~ #
 scale_y_continuous("discharge",limits=c(y_min,y_max)) +
#~  scale_x_date('',limits=c(x_min,x_max)) +
 theme(legend.position = "none") 
#ggsave("screen.pdf", plot = outplott,width=30,height=8.25,units='cm')
 outputFile = "test"
 ggsave(paste(outputFile,".pdf",sep=""), plot = outplott,width=27,height=7,units='cm')
#
rm(outplott)
