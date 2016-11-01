.onLoad <- function(lib, pkg){
  tessdata <- file.path(lib, pkg, "tessdata")
  if(file.exists(tessdata)){
    Sys.setenv(TESSDATA_PREFIX = tessdata)
  }
}
