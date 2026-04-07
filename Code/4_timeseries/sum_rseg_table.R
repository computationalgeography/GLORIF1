
#~ edwin@tcn1177.local.snellius.surf.nl:/scratch-shared/edwin/_finalizing_glorif1/rseg_evaluation_with_parallelization_done/summary_table$ ls -lah ../*.txt
#~ -r--r--r--. 1 edwin edwin 77K Apr  4 21:31 ../_rseg_evaluation_0000001-0000500.txt
#~ -r--r--r--. 1 edwin edwin 75K Apr  4 21:31 ../_rseg_evaluation_0000501-0001000.txt
#~ -r--r--r--. 1 edwin edwin 80K Apr  4 21:31 ../_rseg_evaluation_0001001-0001500.txt
#~ -r--r--r--. 1 edwin edwin 85K Apr  4 21:31 ../_rseg_evaluation_0001501-0002000.txt
#~ -r--r--r--. 1 edwin edwin 84K Apr  4 21:31 ../_rseg_evaluation_0002001-0002500.txt
#~ -r--r--r--. 1 edwin edwin 78K Apr  4 21:31 ../_rseg_evaluation_0002501-0003000.txt
#~ -r--r--r--. 1 edwin edwin 56K Apr  4 21:31 ../_rseg_evaluation_0003001-0003367.txt

table = read.csv("/scratch-shared/edwin/_finalizing_glorif1/rseg_evaluation_with_parallelization_done/_rseg_evaluation_0000001-0000500.txt", header = TRUE, sep = ";")
full_table <- table
table = read.csv("/scratch-shared/edwin/_finalizing_glorif1/rseg_evaluation_with_parallelization_done/_rseg_evaluation_0000501-0001000.txt", header = TRUE, sep = ";")
full_table <- rbind(full_table, table)
table = read.csv("/scratch-shared/edwin/_finalizing_glorif1/rseg_evaluation_with_parallelization_done/_rseg_evaluation_0001001-0001500.txt", header = TRUE, sep = ";")
full_table <- rbind(full_table, table)
table = read.csv("/scratch-shared/edwin/_finalizing_glorif1/rseg_evaluation_with_parallelization_done/_rseg_evaluation_0001501-0002000.txt", header = TRUE, sep = ";")
full_table <- rbind(full_table, table)
table = read.csv("/scratch-shared/edwin/_finalizing_glorif1/rseg_evaluation_with_parallelization_done/_rseg_evaluation_0002001-0002500.txt", header = TRUE, sep = ";")
full_table <- rbind(full_table, table)
table = read.csv("/scratch-shared/edwin/_finalizing_glorif1/rseg_evaluation_with_parallelization_done/_rseg_evaluation_0002501-0003000.txt", header = TRUE, sep = ";")
full_table <- rbind(full_table, table)
table = read.csv("/scratch-shared/edwin/_finalizing_glorif1/rseg_evaluation_with_parallelization_done/_rseg_evaluation_0003001-0003367.txt", header = TRUE, sep = ";")
full_table <- rbind(full_table, table)


# using only stations with at least 12 months and upstream area > 10,000 km2 (~4 pixels of PCR-GLOBWB)
selected_table = full_table[which(full_table$length_of_obs_used >= 12 & full_table$obs_area_meta_km2 > 10000),]


write.table(selected_table, file = "selected_table_rseg.txt", row.names = FALSE, col.names = TRUE, sep = ";")
