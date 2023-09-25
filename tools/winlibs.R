if(!file.exists("../windows/tesseract/include/tesseract/baseapi.h")){
  unlink("../windows", recursive = TRUE)
  url <- if(grepl("aarch", R.version$platform)){
    "https://github.com/r-windows/bundles/releases/download/tesseract-5.3.2/tesseract-ocr-5.3.2-clang-aarch64.tar.xz"
  } else if(grepl("clang", Sys.getenv('R_COMPILED_BY'))){
    "https://github.com/r-windows/bundles/releases/download/tesseract-5.3.2/tesseract-ocr-5.3.2-clang-x86_64.tar.xz"
  } else if(getRversion() >= "4.3") {
    "https://github.com/r-windows/bundles/releases/download/tesseract-5.3.2/tesseract-ocr-5.3.2-ucrt-x86_64.tar.xz"
  } else {
    "https://github.com/rwinlib/tesseract/archive/v5.3.2.tar.gz"
  }
  download.file(url, basename(url), quiet = TRUE)
  dir.create("../windows", showWarnings = FALSE)
  untar(basename(url), exdir = "../windows", tar = 'internal')
  unlink(basename(url))
  setwd("../windows")
  file.rename(list.files(), 'tesseract')
}

# Also download the english training data
dir.create("../windows/tessdata", showWarnings = FALSE)
if(!file.exists("../windows/tessdata/eng.traineddata")){
  message("Downloading eng.traineddata...")
  download.file("https://github.com/tesseract-ocr/tessdata_fast/raw/4.1.0/eng.traineddata",
                "../windows/tessdata/eng.traineddata", mode = "wb", quiet = TRUE)
}

# This is base training data for Orientation and Script Detection
if(!file.exists("../windows/tessdata/osd.traineddata")){
  message("Downloading osd.traineddata...")
  download.file("https://github.com/tesseract-ocr/tessdata_fast/raw/4.1.0/osd.traineddata",
                "../windows/tessdata/osd.traineddata", mode = "wb", quiet = TRUE)
}
