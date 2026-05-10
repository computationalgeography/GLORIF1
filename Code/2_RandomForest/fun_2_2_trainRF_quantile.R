#### training function ####

trainRF <- function(input_table, num.trees, mtry, num.threads){
	
  ranger(
	  formula         = obs ~ ., 
	  data            = input_table,  # pay attention here to only use actual predictors, excluding datetime
	  num.trees       = num.trees, #manually choose parsimonious amount of trees
	  mtry            = mtry, #manually choose the proper mtry, 15 or 20 
	  min.node.size   = 5,
	  seed = 123,
	  importance = 'impurity', # 'permutation'
	  quantreg= TRUE, #package for quantile version
	  num.threads=num.threads
 )
}

