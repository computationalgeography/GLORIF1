
# additional library to read directly from a netcdf file
library(ggplot2)
library(ncdf4)

source("gsub_alnum_edwin.R")

args <- commandArgs(trailingOnly = TRUE)
strt_idx <- as.integer(args[1])
last_idx <- as.integer(args[2])

print(strt_idx)
print(last_idx)

