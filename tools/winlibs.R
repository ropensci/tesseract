if(!file.exists('tesseract.o') && !file.exists("../.deps/tesseract/include/tesseract/baseapi.h")){
  unlink("../.deps", recursive = TRUE)
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
  dir.create("../.deps", showWarnings = FALSE)
  untar(basename(url), exdir = "../.deps", tar = 'internal')
  unlink(basename(url))
  setwd("../.deps")
  file.rename(list.files(), 'tesseract')

  # Copy training data
  file.copy('tesseract/share/tessdata', '../inst/', recursive = TRUE)
  download.file("https://github.com/tesseract-ocr/tessdata_fast/raw/4.1.0/eng.traineddata",
                "../inst/tessdata/eng.traineddata", mode = "wb", quiet = TRUE)
  download.file("https://github.com/tesseract-ocr/tessdata_fast/raw/4.1.0/osd.traineddata",
                "../inst/tessdata/osd.traineddata", mode = "wb", quiet = TRUE)
  invisible()
}
