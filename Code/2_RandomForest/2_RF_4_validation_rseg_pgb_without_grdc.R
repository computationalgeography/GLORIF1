####-------------------------------####
#source('../fun_0_loadLibrary.R')
####-------------------------------####
source('fun_2_2_trainRF.R')
source('fun_2_3_apply_optimalRF_validation_rseg.R')
source('fun_2_3_apply_optimalRF_validation_rseg_edwin.R')

# additional library to read directly from a netcdf file
library(ncdf4)

# Paths
#predictions_dir <- '/scratch-shared/bisik/Practical_NEW/reanalysis_NEW_95_filtered/reanalysis_discharge/' # for predictors
#predictions_dir <- '/scratch-shared/bisik/predictors/pcr_discharge/' # for pcr discharge
#predictions_dir <- '/scratch/sutan101/glorif1_txt/reanalysis_discharge/' # glorif1
#predictions_dir <- '/scratch/sutan101/glorif1_txt/reanalysis_discharge/pcr_rf_reanalysis_monthly_30arcmin_'
#predictions_dir <- '/eejit/depfg/sutan101/glorif1_from_snellius/glorif1/original/version_1.0/predictors/predictors/pcr_discharge/pcr_discharge_' # original pgb result
#
# - on snellius:
#predictions_dir <- '/projects/0/dfguu/users/edwin/data/glorif1/original/version_1.0/output/reanalysis_discharge/pcr_rf_reanalysis_monthly_30arcmin_' # glorif1
 predictions_dir <- '/projects/0/dfguu/users/edwin/data/glorif1/original/version_1.0/predictors/predictors/pcr_discharge/pcr_discharge_'              # original pgb result

#validation_dir  <- '/home/bisik/Practical/gsim_preprocess/gsim_discharge_areafiltered_2_timefiltered/' # for validation based on gsim discharge
#validation_file <- '/scratch-shared/bisik/predictors/grdc_discharge/' # for validation based on grdc discharge

#nc_rseg_file <- '/eejit/depfg/sutan101/glorif1_from_snellius/rseg_grdc/RSEG_V01.nc' # RSEG
 nc_rseg_file <- '/projects/0/dfguu/users/edwin/data/rseg_grdc/RSEG_V01.nc'

#mapping_file <- '/eejit/depfg/sutan101/glorif1_from_snellius/Data/preprocess_rseg/station_pixel_mapping_rseg.csv'
 mapping_file <- '/scratch-shared/edwin/_finalizing_glorif1/preprocess_rseg/station_pixel_mapping_rseg.csv'

# Load the mapping file
station_to_pixel_mapping <- read.csv(mapping_file)

# read the validation netcdf file
nc_rseg        <- nc_open(nc_rseg_file)
rseg_grdc_no   <- ncvar_get(nc_rseg, "GRDC_Num")
rseg_discharge <- ncvar_get(nc_rseg, "Disch")
rseg_flag      <- ncvar_get(nc_rseg, "Disch_Flag")

# Filter time range from 1979-01-01 to 2019-12-31
rseg_time  <- as.Date(ncvar_get(nc_rseg, "Time"), origin = "1806-01-01")
start_date <- as.Date("1979-01-01")
end_date   <- as.Date("2019-12-31")
time_idx   <- which(rseg_time >= start_date & rseg_time <= end_date)
# - Discharge 1979-2019 only and its flag
rseg_discharge_selected <- rseg_discharge[time_idx,]
# - Do not use GRDC data (flag must be > 0, as 0 is for GRDC actual data)
rseg_flag_selected <- rseg_flag[time_idx,]
rseg_discharge_selected[which(rseg_flag_selected < 0.5)] <- NaN
# - Set all negative to NaN
rseg_discharge_selected[which(rseg_discharge_selected < 0.0)] <- NaN
# - Set all NA to NaN
rseg_discharge_selected[which(is.na(rseg_discharge_selected))] <- NaN

# dataframe to store the results
column_names = c("cell_no_land","grdc_no","KGE","KGE_r","KGE_alpha","KGE_beta","NSE","RMSE","MAE","nRMSE","nMAE","valid_length", "mean_obs", "mean_sim")
results <- data.frame(matrix(ncol = length(column_names), nrow = 0))

# Process all mappings
for (i in 1:nrow(station_to_pixel_mapping)) {
  result_per_station = process_mapping(station_to_pixel_mapping[i, ], rseg_discharge_selected, rseg_grdc_no, predictions_dir)
  print(result_per_station)
  results = rbind(results, result_per_station)
}


# Save results
#~ outputDir  <- '/scratch/sutan101/glorif1_work/rseg_validation/'
outputDir     <- '/scratch-shared/edwin/glorif1_work/rseg_validation_without_grdc/'
dir.create(outputDir, showWarnings = F, recursive = T)
write.csv(results, paste0(outputDir, 'kge_results_pcrglobwb_rseg_validation_without_grdc.csv'), row.names = F)
