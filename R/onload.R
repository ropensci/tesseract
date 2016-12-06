.onLoad <- function(lib, pkg){
  tessdata <- file.path(lib, pkg, "tessdata")
  if(is.na(Sys.getenv("TESSDATA_PREFIX", NA)) && file.exists(tessdata)){
    Sys.setenv(TESSDATA_PREFIX = tessdata)
  }
}

.onAttach <- function(lib, pkg){
  check_training_data()
}

check_training_data <- function(){
  tryCatch(tesseract(), error = function(e){
    warning("Unable to find English training data", call. = FALSE)
    os <- utils::sessionInfo()[[4]]
    if(grepl("ubuntu|debian", os, TRUE)){
      stop("DEBIAN / UBUNTU: Please run: apt-get install tesseract-ocr-eng")
    }
  })
}
