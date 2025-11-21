####-------------------------------####
#~ source('/home/bisik/Practical/R/fun_0_loadLibrary.R')
source('/home/bisik/Practical/R/fun_0_loadLibrary.R')
####-------------------------------####
#~ source('/home/bisik/Practical/R/fun_2_2_trainRF.R')
source('fun_2_2_trainRF_quantile.R')

#~ outputDir <- '/scratch-shared/bisik/Data/RF/train/'
outputDir <- '/scratch-shared/edwin/Data/RF/train_quantile/'
dir.create(outputDir, showWarnings = F, recursive = T)

#-------train RF with tuned parameters on all available observations----------
#### all predictors ####
print('training: all predictors...')

#~ train_data <- vroom(paste0('/home/bisik/Practical/rf_input/bigTable_allpredictors_filtered_95.csv'),
#~                      show_col_types = F)

train_data <- vroom(paste0('/projects/0/dfguu/users/edwin/data/glorif1/original/version_1.0/random_forest/train/bigTable_allpredictors_filtered_95.csv'),
                     show_col_types = F)

rf_input <- train_data %>% select(., -grdc_no, -cell_no_land, -datetime)
optimal_ranger <- trainRF(rf_input, num.trees=500, mtry=31, num.threads=48)

print('saving...')
saveRDS(optimal_ranger, paste0(outputDir,'trainedRF_quantiles.rds'))                    
vi_df <- data.frame(names=names(optimal_ranger$variable.importance)) %>%
  mutate(importance=optimal_ranger$variable.importance)                     
write.csv(vi_df, paste0(outputDir,'varImportance_quantiles.csv'), row.names=F)
