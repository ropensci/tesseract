.onLoad <- function(lib, pkg){
  tessdata <- file.path(lib, pkg, "tessdata")
  if(is.na(Sys.getenv("TESSDATA_PREFIX", NA)) && file.exists(tessdata)){
    Sys.setenv(TESSDATA_PREFIX = tessdata)
  }
}
