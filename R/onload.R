.onLoad <- function(lib, pkg){
  tessdata <- file.path(lib, pkg, "tessdata")
  if(is.na(Sys.getenv("TESSDATA_PREFIX", NA)) && file.exists(tessdata)){
    Sys.setenv(TESSDATA_PREFIX = tessdata)
  }
  tryCatch(tesseract(), error = function(e){
    stop("Unable to find English training data, please install: apt-get install tesseract-ocr-eng", call. = FALSE)
  })
}
