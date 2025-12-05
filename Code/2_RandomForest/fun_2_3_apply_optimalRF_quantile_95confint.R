# function to apply a trained RF to unseen data
# it writes complete tables and stores KGE

# key = qstatevars, allpredictors
apply_optimalRF <- function(i, key){
    
    station_no <- stationInfo$cell_no_land[i]
    print(station_no)
    
#~     pcr_discharge <- read.csv(paste0('/scratch-shared/bisik/Data/predictors/pcr_flowdepth/pcr_discharge_',
#~                                      station_no, '.csv')) %>% mutate(datetime=as.Date(datetime))
    
#~     pcr_discharge <- read.csv(paste0('/projects/0/dfguu/users/edwin/data/glorif1/original/version_1.0/predictors/predictors/pcr_discharge/pcr_discharge_',
#~                                      station_no, '.csv')) %>% mutate(datetime=as.Date(datetime))

    pcr_discharge <- read.csv(paste0('/projects/0/dfguu/users/edwin/data/glorif1/original/version_1.0/predictors/predictors/pcr_flowdepth/pcr_discharge_',
                                     station_no, '.csv')) %>% mutate(datetime=as.Date(datetime))

    if(sum(pcr_discharge$pcr==0)){
      
      pcr_reanalysis <- pcr_discharge %>% rename(pcr_corrected=pcr) %>%
                            mutate(datetime=as.Date(datetime))
      write.csv(pcr_reanalysis, paste0(outputDirReanalysis, 'pcr_rf_reanalysis_monthly_30arcmin_0p025_',
                                       station_no, '.csv'), row.names=F)
      
      write.csv(pcr_reanalysis, paste0(outputDirReanalysis, 'pcr_rf_reanalysis_monthly_30arcmin_0p500_',
                                       station_no, '.csv'), row.names=F)

      write.csv(pcr_reanalysis, paste0(outputDirReanalysis, 'pcr_rf_reanalysis_monthly_30arcmin_0p975_',
                                       station_no, '.csv'), row.names=F)

    }
    else{
      
#~       test_data <- read.csv(paste0('/scratch-shared/bisik/pcr_allpredictors/pcr_allpredictors_',
#~                                    station_no, '.csv')) #%>% select (datetime,pcr,precipitation,temperature,referencePotET)
                               
      test_data <- read.csv(paste0('/projects/0/dfguu/users/edwin/data/glorif1/original/version_1.0/predictors/predictors/pcr_allpredictors/pcr_allpredictors_',
                                   station_no, '.csv')) #%>% select (datetime,pcr,precipitation,temperature,referencePotET)
                                     

        # predict discharge with trained RF
        

      pcr_corrected_quantiles = predict(optimal_ranger, test_data, num.threads=NULL, type = "quantiles", quantiles = c(0.025, 0.5, 0.975))
        
#~       print(pcr_corrected_quantiles)
#~       print(pcr_corrected_quantiles$predictions)
#~       print(pcr_corrected_quantiles$predictions[, "quantile= 0.05"])
      
      # percentile 0.025
      pcr_reanalysis <- test_data %>% 

        mutate(pcr_corrected = pcr_corrected_quantiles$predictions[, "quantile= 0.025"] ) %>%

        # if pcr_corrected < 0 -> pcr_corrected=0
        mutate(pcr_corrected = replace(pcr_corrected, pcr_corrected<0,0)) %>% 

        # select datetime, pcr_corrected (pcr uncalib can be found in scratch/6574882/pcr_discharge)
        select(., c('datetime', 'pcr_corrected')) %>% 
        # format
        mutate(datetime=as.Date(datetime))
      colnames(pcr_reanalysis) <- c('datetime','pcr_corrected')
      
      write.csv(pcr_reanalysis, paste0(outputDirReanalysis, 'pcr_rf_reanalysis_monthly_30arcmin_0p025_',
                                       station_no, '.csv'), row.names=F)
      
      # percentile 0.50
      rm(pcr_reanalysis)
      pcr_reanalysis <- test_data %>% 

        mutate(pcr_corrected = pcr_corrected_quantiles$predictions[, "quantile= 0.5"] ) %>%

        # if pcr_corrected < 0 -> pcr_corrected=0
        mutate(pcr_corrected = replace(pcr_corrected, pcr_corrected<0,0)) %>% 

        # select datetime, pcr_corrected (pcr uncalib can be found in scratch/6574882/pcr_discharge)
        select(., c('datetime', 'pcr_corrected')) %>% 
        # format
        mutate(datetime=as.Date(datetime))
      colnames(pcr_reanalysis) <- c('datetime','pcr_corrected')
      
      write.csv(pcr_reanalysis, paste0(outputDirReanalysis, 'pcr_rf_reanalysis_monthly_30arcmin_0p500_',
                                       station_no, '.csv'), row.names=F)

      # percentile 0.975
      rm(pcr_reanalysis)
      pcr_reanalysis <- test_data %>% 

        mutate(pcr_corrected = pcr_corrected_quantiles$predictions[, "quantile= 0.975"] ) %>%

        # if pcr_corrected < 0 -> pcr_corrected=0
        mutate(pcr_corrected = replace(pcr_corrected, pcr_corrected<0,0)) %>% 

        # select datetime, pcr_corrected (pcr uncalib can be found in scratch/6574882/pcr_discharge)
        select(., c('datetime', 'pcr_corrected')) %>% 

        # format
        mutate(datetime=as.Date(datetime))
      colnames(pcr_reanalysis) <- c('datetime','pcr_corrected')
      
      write.csv(pcr_reanalysis, paste0(outputDirReanalysis, 'pcr_rf_reanalysis_monthly_30arcmin_0p975_',
                                       station_no, '.csv'), row.names=F)

    }
}

#~                                  type = "quantiles",
#~                                  quantiles = c(0.05, 0.5, 0.95)) # get quantiles

#~     t.quant <- cbind( 
#~         res05=pred.distribution$predictions[, "quantile= 0.05"],
#~         res95=pred.distribution$predictions[, "quantile= 0.95"],
#~         res50=pred.distribution$predictions[, "quantile= 0.5"])
#~     rf.result <- all_df %>% 
#~         cbind(t.quant) %>% 
#~         mutate(pcr_corrected05=pcr+res05,
#~                pcr_corrected50=pcr+res50,
#~                pcr_corrected95=pcr+res95)
    
