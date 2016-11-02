# Download libtesserat for Windows
if(!file.exists("../windows/tesseract-3.04.01/include/tesseract/baseapi.h")){
  if(getRversion() < "3.3.0") setInternet2()
  download.file("https://github.com/rwinlib/tesseract/archive/v3.04.01.zip", "lib.zip", quiet = TRUE)
  dir.create("../windows", showWarnings = FALSE)
  unzip("lib.zip", exdir = "../windows")
  unlink("lib.zip")
}
