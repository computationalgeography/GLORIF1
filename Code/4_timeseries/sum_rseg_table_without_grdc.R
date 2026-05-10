
#~ edwin@tcn558.local.snellius.surf.nl:/scratch-shared/edwin/_finalizing_glorif1/rseg_evaluation_without_grdc_parallelization_final_double_check_final_double_check$ ls -lah *.txt
#~ -rw-r--r--. 1 edwin edwin 76K Apr 21 17:05 _rseg_evaluation_excluding_grdc_0000001-0000500.txt
#~ -rw-r--r--. 1 edwin edwin 75K Apr 21 17:07 _rseg_evaluation_excluding_grdc_0000501-0001000.txt
#~ -rw-r--r--. 1 edwin edwin 82K Apr 21 17:07 _rseg_evaluation_excluding_grdc_0001001-0001500.txt
#~ -rw-r--r--. 1 edwin edwin 84K Apr 21 17:06 _rseg_evaluation_excluding_grdc_0001501-0002000.txt
#~ -rw-r--r--. 1 edwin edwin 77K Apr 21 17:05 _rseg_evaluation_excluding_grdc_0002001-0002500.txt
#~ -rw-r--r--. 1 edwin edwin 17K Apr 21 16:47 _rseg_evaluation_excluding_grdc_0002501-0002612.txt

table = read.csv("/scratch-shared/edwin/_finalizing_glorif1/rseg_evaluation_without_grdc_parallelization_final_double_check/_rseg_evaluation_excluding_grdc_0000001-0000500.txt", header = TRUE, sep = ";")
full_table <- table
table = read.csv("/scratch-shared/edwin/_finalizing_glorif1/rseg_evaluation_without_grdc_parallelization_final_double_check/_rseg_evaluation_excluding_grdc_0000501-0001000.txt", header = TRUE, sep = ";")
full_table <- rbind(full_table, table)
table = read.csv("/scratch-shared/edwin/_finalizing_glorif1/rseg_evaluation_without_grdc_parallelization_final_double_check/_rseg_evaluation_excluding_grdc_0001001-0001500.txt", header = TRUE, sep = ";")
full_table <- rbind(full_table, table)
table = read.csv("/scratch-shared/edwin/_finalizing_glorif1/rseg_evaluation_without_grdc_parallelization_final_double_check/_rseg_evaluation_excluding_grdc_0001501-0002000.txt", header = TRUE, sep = ";")
full_table <- rbind(full_table, table)
table = read.csv("/scratch-shared/edwin/_finalizing_glorif1/rseg_evaluation_without_grdc_parallelization_final_double_check/_rseg_evaluation_excluding_grdc_0002001-0002500.txt", header = TRUE, sep = ";")
full_table <- rbind(full_table, table)
table = read.csv("/scratch-shared/edwin/_finalizing_glorif1/rseg_evaluation_without_grdc_parallelization_final_double_check/_rseg_evaluation_excluding_grdc_0002501-0002612.txt", header = TRUE, sep = ";")
full_table <- rbind(full_table, table)

selected_table = full_table

#~ # using only stations with at least 12 months
#~ selected_table = full_table
#~ selected_table = selected_table[which(selected_table$length_of_obs_used >= 12, ]

#~ # and upstream area > 10,000 km2
#~ selected_table = selected_table[which(selected_table$mod_area_km2 > 10000), ]
#~ selected_table = selected_table[which(selected_table$obs_area_meta_km2 > 10000), )

write.table(selected_table, file = "/scratch-shared/edwin/_finalizing_glorif1/rseg_evaluation_without_grdc_parallelization_final_double_check/_selected_table_rseg_without_grdc_final.txt", row.names = FALSE, col.names = TRUE, sep = ";")

dim(selected_table)

