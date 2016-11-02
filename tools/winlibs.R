# Download libtesserat for Windows
if(!file.exists("../windows/tesseract-3.04.01/include/tesseract/baseapi.h")){
  if(getRversion() < "3.3.0") setInternet2()
  message("Downloading libtesseract...")
  download.file("https://github.com/rwinlib/tesseract/archive/v3.04.01.zip", "lib.zip", quiet = TRUE)
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
if(!file.exists("../windows/tessdata/osd.traineddata")){
  message("Downloading osd.traineddata...")
  download.file("https://github.com/tesseract-ocr/tessdata/raw/3.04.00/osd.traineddata",
                "../windows/tessdata/osd.traineddata", mode = "wb", quiet = TRUE)
}
