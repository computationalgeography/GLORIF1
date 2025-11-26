library(dplyr)
library(hydroGOF)

# Function to process each mapping entry
process_mapping <- function(mapping_entry, rseg_discharge_selected, rseg_grdc_no, predictions_dir) {
  cell_no_land <- gsub("\\.0$", "", as.character(mapping_entry$cell_no_land))
  grdc_no <- mapping_entry$grdc_no

  #prediction_file <- paste0('/scratch-shared/bisik/predictors/pcr_discharge/pcr_discharge_', cell_no_land, '.csv')
  #prediction_file <- paste0('/scratch-shared/bisik/Data/output/reanalysis_discharge/pcr_rf_reanalysis_monthly_30arcmin_', cell_no_land, '.csv')
   
#~ prediction_file <- paste0('/scratch/sutan101/glorif1_txt/reanalysis_discharge/pcr_rf_reanalysis_monthly_30arcmin_', cell_no_land, '.csv')
   prediction_file <- paste0(predictions_dir, cell_no_land, '.csv')
  
  #validation_file <- paste0('/scratch-shared/bisik/Data/validation_data/gsim_discharge/gsim_', gsim.no, '.csv')
  
  print(grdc_no)

  if (file.exists(prediction_file)) {
    
    print(paste("Processing cell_no_land:", cell_no_land, "grdc_no:", grdc_no))
    prediction_data <- read.csv(prediction_file)

# set the name of prediction value
names(prediction_data)[2] <- "simulation"

#~ print(names(prediction_data))
#~ piet

    # read validation data
    # validation_data <- read.csv(validation_file)

# get the GRDC idx
grdc_idx = which(rseg_grdc_no == grdc_no)

# Extract the data for the specific coordinate and time range
validation_data = data.frame(prediction_data$datetime, rseg_discharge_selected[, grdc_idx])    
names(validation_data)[1] <- "datetime"
names(validation_data)[2] <- "obs"

    kge_result <- calculate_kge(prediction_data, validation_data, grdc_no, cell_no_land)

    return(kge_result)
  } else {
    print(paste("Files not found for cell_no_land:", cell_no_land, "or grdc_no:", grdc_no))
    return(NULL)
  }
}

# Function to calculate KGE
calculate_kge <- function(prediction_data, validation_data, grdc_no, cell_no_land) {

  # Ensure datetime columns are in the same format
  prediction_data$datetime <- as.Date(prediction_data$datetime)
  validation_data$datetime <- as.Date(validation_data$datetime)

print(prediction_data)
print(validation_data)

# Count non-NA and non-NaN values in validation data
valid_length <- sum(!is.na(validation_data$obs) & !is.nan(validation_data$obs))
# Print the result
print(valid_length)

check_cor = cor(validation_data$obs, prediction_data$simulation, use="pairwise.complete.obs")
print(check_cor)

if (is.na(check_cor) | is.na(check_cor)) {

KGE = NA 
KGE_r = NA
KGE_alpha = NA
KGE_beta = NA
NSE = NA
RMSE = NA
MAE = NA
nRMSE = NA
nMAE = NA
mean_obs = NA
mean_sim = NA

} else {

simulation = prediction_data$simulation
obs = validation_data$obs
res = obs - simulation

      KGE = KGE(sim = simulation, obs = obs, s = c(1, 1, 1), na.rm = T, method = "2009")
      KGE_r = cor(obs, simulation, method = 'pearson', use = 'complete.obs')
      KGE_alpha = sd(simulation, na.rm = T) / sd(obs, na.rm = T)
      KGE_beta = mean(simulation, na.rm = T) / mean(obs, na.rm = T)
      NSE = NSE(sim = simulation, obs = obs, na.rm = T)
      RMSE = sqrt(mean(res^2, na.rm = T))
      MAE = mean(abs(res), na.rm = T)
      nRMSE = sqrt(mean(res^2, na.rm = T)) / mean(obs, na.rm = T)
      nMAE = mean(abs(res), na.rm = T) / mean(obs, na.rm = T)
      mean_obs = mean(obs, na.rm = T)
      mean_sim = mean(simulation, na.rm = T)

}

return(data.frame(cell_no_land,grdc_no,KGE,KGE_r,KGE_alpha,KGE_beta,NSE,RMSE,MAE,nRMSE,nMAE,valid_length,mean_obs,mean_sim))

}

