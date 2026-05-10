import pandas as pd
import numpy as np
import os

# ~ output_directory = '/scratch-shared/bisik/Data/preprocess/'
# ~ output_file = 'station_pixel_mapping_grdc.csv'

output_directory = '/scratch-shared/edwin/Data/preprocess_rseg/'
output_file = 'station_pixel_mapping_rseg.csv'

output_path = os.path.join(output_directory, output_file)

# Ensure the directory exists
os.makedirs(output_directory, exist_ok=True)

def near(array, value):
    """
    Find the index of the value closest to the given value in an array.
    """
    idx = (np.abs(array - value)).argmin()
    return idx

def assign_station_to_pixel(grdc_csv, pixel_latlon_csv, output_csv):
    # Load GRDC data, which contains grdc_no and geographical coordinates

    # ~ grdc_data = pd.read_csv(grdc_csv)
    grdc_data = pd.read_csv(grdc_csv, delimiter = ";")
    print("GRDC Columns:", grdc_data.columns)  # Debug: Print column names

    # Load pixel data, which contains cell_no_land, lat, and lon
    pixels = pd.read_csv(pixel_latlon_csv)
    print("Pixel Columns:", pixels.columns)  # Debug: Print column names

    # Prepare a list to store the nearest pixel information for each GRDC station
    results = []

    for index, grdc in grdc_data.iterrows():
        grdc_lat = grdc['Lat']
        grdc_lon = grdc['Lon']
        grdc_no = grdc['GRDC_Num']

        # Find the nearest pixel
        distances = np.sqrt((pixels['lat'] - grdc_lat) ** 2 + (pixels['lon'] - grdc_lon) ** 2)
        nearest_pixel_index = distances.idxmin()
        nearest_pixel = pixels.iloc[nearest_pixel_index]

        # Store the result
        result = {
            'grdc_no': grdc_no,
            #'grdc_latitude': grdc_lat,
            #'grdc_longitude': grdc_lon,
            'cell_no_land': nearest_pixel['cell_no_land'],
            'lat': nearest_pixel['lat'],
            'lon': nearest_pixel['lon']
        }
        results.append(result)

    # Convert results to DataFrame
    results_df = pd.DataFrame(results)

    # Save results to CSV
    results_df.to_csv(output_csv, index=False)

# ~ # Example usage
# ~ assign_station_to_pixel(
    # ~ grdc_csv='/scratch-shared/bisik/Data/preprocess/stationLatLon_grdc.csv',
    # ~ pixel_latlon_csv='/scratch-shared/bisik/Data/preprocess/stationLatLon_PCR.csv',
    # ~ output_csv=output_path
# ~ )

# Usage for RSEG
assign_station_to_pixel(
    grdc_csv='/projects/0/dfguu/users/edwin/data/rseg_grdc/rseg_station_table.csv',
    pixel_latlon_csv='/projects/0/dfguu/users/edwin/data/glorif1/original/version_1.0/preprocess/preprocess_grdc/stationLatLon_PCR.csv',
    output_csv=output_path
)
