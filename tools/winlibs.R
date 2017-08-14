# Build against tesseract static library
VERSION <- commandArgs(TRUE)
if(!file.exists(sprintf("../windows/tesseract-%s/include/tesseract/baseapi.h", VERSION))){
  if(getRversion() < "3.3.0") setInternet2()
  download.file(sprintf("https://github.com/rwinlib/tesseract/archive/v%s.zip", VERSION), "lib.zip", quiet = TRUE)
  dir.create("../windows", showWarnings = FALSE)
  unzip("lib.zip", exdir = "../windows")
  unlink("lib.zip")
}

# Also download the english training data
dir.create("../windows/tessdata", showWarnings = FALSE)
if(!file.exists("../windows/tessdata/eng.traineddata")){
  message("Downloading eng.traineddata...")
  download.file("https://github.com/tesseract-ocr/tessdata/raw/3.04.00/eng.traineddata",
                "../windows/tessdata/eng.traineddata", mode = "wb", quiet = TRUE)
}

# This is diasabled now because CRAN wants to reduce the size of the binary
#if(!file.exists("../windows/tessdata/osd.traineddata")){
#  message("Downloading osd.traineddata...")
#  download.file("https://github.com/tesseract-ocr/tessdata/raw/3.04.00/osd.traineddata",
#                "../windows/tessdata/osd.traineddata", mode = "wb", quiet = TRUE)
#}
