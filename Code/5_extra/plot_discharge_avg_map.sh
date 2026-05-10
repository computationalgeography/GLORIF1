
#~ (pcrglobwb_python3_v20250207) edwin@tcn1187.local.snellius.surf.nl:/scratch-shared/edwin/_finalizing_glorif1/discharge_map_plot$ ls -lah
#~ total 11M
#~ drwxr-xr-x+  2 edwin edwin  4.0K May  3 01:39 .
#~ drwxr-xr-x+ 21 edwin edwin  4.0K May  3 00:53 ..
#~ -rw-r--r--.  1 edwin edwin 1013K May  3 01:45 average_pcrglobwb_30min_original.map
#~ -rw-r--r--.  1 edwin edwin 1013K May  3 01:45 glorif1_discharge_30min_average.map
#~ -rw-r--r--.  1 edwin edwin 1013K May  3 01:45 ids_lakes_and_reservoirs.map
#~ -rw-r--r--.  1 edwin edwin  254K May  3 01:45 lakes_and_reservoirs.map
#~ lrwxrwxrwx.  1 edwin edwin   167 May  3 01:05 waterBodies30min.nc -> /projects/0/dfguu/data/hydroworld/pcrglobwb2_input_release/version_2019_11_beta_extended/pcrglobwb2_input/global_30min/routing/surface_water_bodies/waterBodies30min.nc
#~ -rw-r--r--.  1 edwin edwin  5.0M May  3 01:07 waterBodies30min_2010.nc
#~ -rw-r--r--.  1 edwin edwin  1.1M May  3 01:14 waterBodyIds_waterBodies30min_2010.nc
#~ -rw-r--r--.  1 edwin edwin  1.1M May  3 01:14 waterBodyTyp_waterBodies30min_2010.nc


# alternative 1

#~ pcrcalc discharge_waterbodies2010_average_pcrglobwb_30min_original.map = "if( defined(ids_lakes_and_reservoirs.map), areamaximum(average_pcrglobwb_30min_original.map, ids_lakes_and_reservoirs.map) , average_pcrglobwb_30min_original.map)"

#~ pcrcalc discharge_waterbodies2010_glorif1_discharge_30min_average.map  = "if( defined(ids_lakes_and_reservoirs.map), areamaximum(glorif1_discharge_30min_average.map, ids_lakes_and_reservoirs.map) , glorif1_discharge_30min_average.map)"

#~ pcrcalc discharge_diff_avera_glorif1_minus_pcrglowb.map = "discharge_waterbodies2010_glorif1_discharge_30min_average.map - discharge_waterbodies2010_average_pcrglobwb_30min_original.map"


# alternative 2

pcrcalc areatotal_number_of_cells_ids_lakes_and_reservoirs.map = "areatotal( spatial(1.0), ids_lakes_and_reservoirs.map )"

pcrcalc large_lakes_and_reservoirs.map = "if(areatotal_number_of_cells_ids_lakes_and_reservoirs.map gt 4.0, boolean(1.0))"
pcrcalc large_lakes_and_reservoirs.map = "defined(large_lakes_and_reservoirs.map)"
 aguila large_lakes_and_reservoirs.map

pcrcalc discharge_waterbodies2010_average_pcrglobwb_30min_original.map = "if( scalar(large_lakes_and_reservoirs.map) eq 0, average_pcrglobwb_30min_original.map)"
pcrcalc discharge_waterbodies2010_glorif1_discharge_30min_average.map  = "if( scalar(large_lakes_and_reservoirs.map) eq 0, glorif1_discharge_30min_average.map )"

pcrcalc discharge_diff_avera_glorif1_minus_pcrglowb.map = "discharge_waterbodies2010_glorif1_discharge_30min_average.map - discharge_waterbodies2010_average_pcrglobwb_30min_original.map"
 aguila discharge_*.map


