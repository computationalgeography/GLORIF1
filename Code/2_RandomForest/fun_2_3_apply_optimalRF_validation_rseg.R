library(dplyr)
library(hydroGOF)

# Function to process each mapping entry
process_mapping <- function(mapping_entry, rseg_discharge_selected, rseg_grdc_no) {
  cell_no_land <- gsub("\\.0$", "", as.character(mapping_entry$cell_no_land))
  grdc_no <- mapping_entry$grdc_no

  #prediction_file <- paste0('/scratch-shared/bisik/predictors/pcr_discharge/pcr_discharge_', cell_no_land, '.csv')
  #prediction_file <- paste0('/scratch-shared/bisik/Data/output/reanalysis_discharge/pcr_rf_reanalysis_monthly_30arcmin_', cell_no_land, '.csv')
   
   prediction_file <- paste0('/scratch/sutan101/glorif1_txt/reanalysis_discharge/pcr_rf_reanalysis_monthly_30arcmin_', cell_no_land, '.csv')
  
  #validation_file <- paste0('/scratch-shared/bisik/Data/validation_data/gsim_discharge/gsim_', gsim.no, '.csv')
  
  print(grdc_no)

  if (file.exists(prediction_file)) {
    
    print(paste("Processing cell_no_land:", cell_no_land, "grdc_no:", grdc_no))
    prediction_data <- read.csv(prediction_file)

    # read validation data
    # validation_data <- read.csv(validation_file)

# get the GRDC idx
grdc_idx = which(rseg_grdc_no = grdc_no)

# Extract the data for the specific coordinate and time range
validation_date = rseg_discharge_selected[, grdc_idx]    


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

  rf.result <- prediction_data %>%
    # Merge on datetime
    inner_join(validation_data, by = "datetime") %>%
    # pcr_corrected is already present in the prediction data
    mutate(pcr_corrected = replace(pcr_corrected, pcr_corrected < 0, 0)) %>%
    mutate(res = obs - pcr_corrected) %>%
    select(datetime, obs, pcr_corrected, res) %>%
    drop_na()  # Remove rows with NA values

  if (nrow(rf.result) == 0) {
    print(paste("No matching data for grdc_no:", grdc_no))
    return(NULL)
  }

  # Check for sufficient complete cases for correlation calculation
  complete_cases <- complete.cases(rf.result$obs, rf.result$pcr_corrected)
  if (sum(complete_cases) < 2) {
    print(paste("Not enough complete cases for correlation calculation for gsim.no:", gsim.no))
    return(NULL)
  }

  rf.eval <- rf.result %>%
    summarise(
      cell_no_land = cell_no_land,
      gsim.no = gsim.no,
      KGE = KGE(sim = pcr_corrected, obs = obs, s = c(1, 1, 1), na.rm = T, method = "2009"),
      KGE_r = cor(obs, pcr_corrected, method = 'pearson', use = 'complete.obs'),
      KGE_alpha = sd(pcr_corrected, na.rm = T) / sd(obs, na.rm = T),
      KGE_beta = mean(pcr_corrected, na.rm = T) / mean(obs, na.rm = T),
      NSE = NSE(sim = pcr_corrected, obs = obs, na.rm = T),
      RMSE = sqrt(mean(res^2, na.rm = T)),
      MAE = mean(abs(res), na.rm = T),
      nRMSE = sqrt(mean(res^2, na.rm = T)) / mean(obs),
      nMAE = mean(abs(res), na.rm = T) / mean(obs)
    )

  return(rf.eval)
}
