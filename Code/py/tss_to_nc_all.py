#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function

#
# PCR-GLOBWB (PCRaster Global Water Balance) Global Hydrological Model
#
# Copyright (C) 2016, Edwin H. Sutanudjaja, Rens van Beek, Niko Wanders, Yoshihide Wada, 
# Joyce H. C. Bosmans, Niels Drost, Ruud J. van der Ent, Inge E. M. de Graaf, Jannis M. Hoch, 
# Kor de Jong, Derek Karssenberg, Patricia López López, Stefanie Peßenteiner, Oliver Schmitz, 
# Menno W. Straatsma, Ekkamol Vannametee, Dominik Wisser, and Marc F. P. Bierkens
# Faculty of Geosciences, Utrecht University, Utrecht, The Netherlands
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import os
import sys
import datetime
import time
import re
import glob
import subprocess
import netCDF4 as nc
import numpy as np


def create_nc(list_of_stations, input_csv_files_folder, input_file_pattern, output_nc_file):
    
    longitude = np.arange(-180.0 + 0.5/2., 180.0,  0.5)
    latitude  = np.arange(  90.0 - 0.5/2., -90.0, -0.5)
    
    nc_format = 'NETCDF3_CLASSIC'
    nc_zlib   = False
    
    attributeDictionary = {}
    attributeDictionary['institution'] = "Utrecht Univ."
    attributeDictionary['title'      ] = "PCR-GLOBWB-ML monthly discharge output"
    attributeDictionary['description'] = " "


    # creating nc file
    rootgrp = nc.Dataset(output_nc_file, 'w', format = nc_format)

    #-create dimensions - time is unlimited, others are fixed
    rootgrp.createDimension('time', None)
    rootgrp.createDimension('lat', len(latitude))
    rootgrp.createDimension('lon', len(longitude))

    date_time = rootgrp.createVariable('time', 'f4', ('time',))
    date_time.standard_name = 'time'
    date_time.long_name = 'Days since 1901-01-01'

    date_time.units    = 'days since 1901-01-01'
    date_time.calendar = 'standard'

    lat= rootgrp.createVariable('lat', 'f4', ('lat',))
    lat.long_name = 'latitude'
    lat.units = 'degrees_north'
    lat.standard_name = 'latitude'

    lon= rootgrp.createVariable('lon', 'f4', ('lon',))
    lon.standard_name = 'longitude'
    lon.long_name = 'longitude'
    lon.units = 'degrees_east'

    lat[:] = latitude
    lon[:] = longitude

    # variable name
    varName = "discharge"
    shortVarName = varName
    longVarName  = varName
    standardVarName = varName

    # variable unit
    varUnits = "m3/s"
    
    # missing values
    MV = 1e-20
    
    var = rootgrp.createVariable(shortVarName, 'f4', ('time','lat','lon',), fill_value = MV, zlib = nc_zlib)
    var.standard_name = standardVarName
    var.long_name = longVarName
    var.units = varUnits

    for k, v in list(attributeDictionary.items()): setattr(rootgrp,k,v)

    rootgrp.sync()
    rootgrp.close()


    # get the list of stations and their coordinates
    with open(list_of_stations) as file_name:
        array = np.loadtxt(file_name, delimiter=",", skiprows = 1)
    
    # ~ check
    station_nums = array[:,0].astype(int)
    station_lons = array[:,1].astype(float)
    station_lats = array[:,2].astype(float) 
    
    # use a csv file to get time series of dates (time stamps)
    
    with open(input_csv_files_folder + "/" + str(input_file_pattern) + str("130.csv"), "r") as file_name:
        array = np.loadtxt(file_name, delimiter=",", skiprows = 1, dtype = "str")
    date_string = array[:,0]


    # create an empty netcdf file
    print('initializing datetime vector...')
    for i in range(0, len(date_string)):

        timeStamp_string = date_string[i].split('-')
        timeStamp_date = datetime.date(int(timeStamp_string[0]), int(timeStamp_string[1]), int(timeStamp_string[2]))

        # time stamp for reporting
        timeStamp = datetime.datetime(timeStamp_date.year,\
                                      timeStamp_date.month,\
                                      timeStamp_date.day,\
                                      0)
        
        rootgrp = nc.Dataset(output_nc_file, 'a')

        date_time = rootgrp.variables['time']
        posCnt = len(date_time)
        date_time[posCnt] = nc.date2num(timeStamp, date_time.units,date_time.calendar)

        rootgrp.variables[shortVarName][posCnt,:,:] = np.zeros(shape=(len(latitude), len(longitude))) + MV

        rootgrp.sync()
        rootgrp.close()


    # ~ csv_files = glob.glob("*.csv")
    fileList = os.listdir(input_csv_files_folder)
    # loop through csv files and write values to netcdf files
    for i in range(0, len(station_nums)):
        
        rootgrp = nc.Dataset(output_nc_file, 'a')

        csv_file = input_csv_files_folder + "/" + str(input_file_pattern) + str(int(station_nums[i])) + ".csv"

        try:
            with open(csv_file, "r") as file_name:
                array = np.loadtxt(file_name, delimiter=",", skiprows = 1, dtype = "str")
            values = array[:,1].astype(float)
        except:
            values = [0] * len(date_string)

        lat_ind = int(np.where(latitude  == station_lats[i])[0][0])
        lon_ind = int(np.where(longitude == station_lons[i])[0][0])
        
        rootgrp.variables[shortVarName][:,lat_ind,lon_ind] = values
        rootgrp.sync()
        rootgrp.close()
        
        print(csv_file)


    
def main():

    # ~ create_nc(list_of_stations = "/scratch/6574882/reanalysis/stationLatLon.csv", input_csv_files_folder = "/scratch/6574882/reanalysis/reanalysis_discharge/", output_nc_file = "reanalysis_discharge_30arcmin.nc")

    list_of_stations       = "/projects/0/dfguu/users/edwin/data/glorif1/original/version_1.0/preprocess/preprocess_grdc/stationLatLon_PCR.csv"
    input_csv_files_folder = "/scratch-shared/edwin/Data/output/reanalysis_flowdepth_quantile_95confint/"
    input_file_pattern     = "pcr_rf_reanalysis_monthly_30arcmin_0p025_"
    output_nc_file         = "/scratch-shared/edwin/Data/output/netcdf/glorif1_discharge_0p025_30min_monthly.nc" 
    
# ~ edwin@tcn586.local.snellius.surf.nl:/scratch-shared/edwin/Data/output$ ls -lah */*_9.csv
# ~ -r--r--r--. 1 edwin edwin 6.3K Dec  5 18:43 reanalysis_flowdepth_quantile_95confint/pcr_rf_reanalysis_monthly_30arcmin_0p025_9.csv
# ~ -r--r--r--. 1 edwin edwin 6.3K Dec  5 18:43 reanalysis_flowdepth_quantile_95confint/pcr_rf_reanalysis_monthly_30arcmin_0p500_9.csv
# ~ -r--r--r--. 1 edwin edwin 6.3K Dec  5 18:43 reanalysis_flowdepth_quantile_95confint/pcr_rf_reanalysis_monthly_30arcmin_0p975_9.csv


# ~ sutan101@velocity.geo.uu.nl:/scratch/sutan101/glorif1_work/glorif1_from_snellius/Data/output$ ls -lah reanalysis_flowdepth_quantile/*_9.csv
# ~ -rw-r--r-- 1 1111 cgred 6.3K Nov 23 19:52 reanalysis_flowdepth_quantile/pcr_rf_reanalysis_monthly_30arcmin_0p05_9.csv
# ~ -rw-r--r-- 1 1111 cgred 6.3K Nov 23 19:53 reanalysis_flowdepth_quantile/pcr_rf_reanalysis_monthly_30arcmin_0p50_9.csv
# ~ -rw-r--r-- 1 1111 cgred 6.3K Nov 23 19:54 reanalysis_flowdepth_quantile/pcr_rf_reanalysis_monthly_30arcmin_0p95_9.csv

    create_nc(
        list_of_stations = list_of_stations, 
        input_csv_files_folder = input_csv_files_folder, 
        input_file_pattern = input_file_pattern,
        output_nc_file = output_nc_file
    )

        
if __name__ == '__main__':
    sys.exit(main())

