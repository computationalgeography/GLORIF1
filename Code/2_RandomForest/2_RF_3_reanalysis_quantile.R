####-------------------------------####
source('/home/bisik/Practical/R/fun_0_loadLibrary.R')
####-------------------------------####
source('fun_2_3_apply_optimalRF_quantile.R')

#~ stationInfo <- read.csv('/home/bisik/Practical/stationLatLon.csv')
stationInfo <- read.csv('/projects/0/dfguu/users/edwin/data/glorif1/original/version_1.0/preprocess/preprocess_grdc/stationLatLon_PCR.csv')

#~ outputDirReanalysis <- '/scratch-shared/bisik/Data/output/reanalysis_flowdepth/'
outputDirReanalysis <- '/scratch-shared/edwin/Data/output/reanalysis_flowdepth_quantile/'

dir.create(outputDirReanalysis, showWarnings = F, recursive = T)

# Define the date range
#start_date <- as.Date("1990-01-01")  # replace with the desired start date
#end_date <- as.Date("1995-01-01") 

#### reanalysis - predict residuals for test stations ####
#### all predictors
print('allpredictors: reading trained RF...')
#~ optimal_ranger <- readRDS('/scratch-shared/bisik/Data/RF/train/trainedRF.rds')
optimal_ranger <- readRDS('/scratch-shared/edwin/Data/RF/train_quantile/trainedRF_quantiles.rds')
print('calculation: initiated')

mclapply(1:nrow(stationInfo), key='allpredictors',apply_optimalRF, mc.cores=1)
