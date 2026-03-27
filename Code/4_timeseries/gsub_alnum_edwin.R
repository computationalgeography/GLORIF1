gsub_alnum <- function(input_text) {
  tryCatch(
  {
    result <- gsub('[^[:alnum:] ]', '-', input_text)
    return(result)
  },
  error = function(e) {
    message("An Error Occurred, text will be replaced with 'none'")
    print(e)
    return("none")
 },
 warning = function(w) {
   message("A Warning Occurred")
   print(w)
   return(result)
  }
 )
}
