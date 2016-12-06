#' Tesseract OCR
#'
#' Extract text from an image. Requires that you have training data for the language you
#' are reading. Works best for images with high contrast, little noise and horizontal text.
#'
#' Tesseract uses training data to perform OCR. Most systems default to English
#' training data. To improve OCR performance for other langauges you can to install the
#' training data from your distribution. For example to install the spanish training data:
#'
#'  - [tesseract-ocr-spa](https://packages.debian.org/testing/tesseract-ocr-spa) (Debian, Ubuntu)
#'  - [tesseract-langpack-spa](https://apps.fedoraproject.org/packages/tesseract-langpack-spa) (Fedora, EPEL)
#'
#' On other platforms you can manually download training data from [github](https://github.com/tesseract-ocr/tessdata)
#' and store it in a path on disk that you pass in the `datapath` parameter. Alternatively
#' you can set a default path via the `TESSDATA_PREFIX` environment variable.
#'
#' @export
#' @useDynLib tesseract
#' @param image file path, url, or raw vector to image (png, tiff, jpeg, etc)
#' @param engine a tesseract engine created with `tesseract()`
#' @rdname tesseract
#' @references [Tesseract training data](https://github.com/tesseract-ocr/tessdata)
#' @aliases tesseract ocr
#' @importFrom Rcpp sourceCpp
#' @examples # Simple example
#' text <- ocr("http://jeroenooms.github.io/images/testocr.png")
#' cat(text)
#'
#' # Roundtrip test: render PDF to image and OCR it back to text
#' library(pdftools)
#' library(tiff)
#'
#' # A PDF file with some text
#' setwd(tempdir())
#' news <- file.path(Sys.getenv("R_DOC_DIR"), "NEWS.pdf")
#' orig <- pdf_text(news)[1]
#'
#' # Render pdf to jpeg/tiff image
#' bitmap <- pdf_render_page(news, dpi = 300, numeric = TRUE)
#' tiff::writeTIFF(bitmap, "page.tiff")
#'
#' # Extract text from images
#' out <- ocr("page.tiff")
#' cat(out)
#'
#' engine <- tesseract(options = list(tessedit_char_whitelist = "0123456789"))
ocr <- function(image, engine = tesseract("eng")) {
  stopifnot(inherits(engine, "tesseract"))
  if(inherits(image, "magick-image")){
    image <- lapply(image, function(x){
      tmp <- tempfile(fileext = ".tiff")
      magick::image_write(x, tmp, format = "tiff")
    })
    vapply(image, ocr_file, character(1), ptr = engine, USE.NAMES = FALSE)
  } else if(is.character(image)){
    image <- download_files(image)
    vapply(image, ocr_file, character(1), ptr = engine, USE.NAMES = FALSE)
  } else if(is.raw(image)){
    ocr_raw(image, engine)
  } else {
    stop("Argument 'image' must be file-path, url or raw vector")
  }
}

#' @export
#' @rdname tesseract
#' @param language string with language for training data. Usually defaults to `eng`
#' @param datapath path with the training data for this language. Default uses
#' the system library.
#' @param options a named list with tesseract
#' [engine options](http://www.sk-spell.sk.cx/tesseract-ocr-parameters-in-302-version)
#' @param cache use a cached version of this training data if available
tesseract <- local({
  store <- new.env()
  function(language = NULL, datapath = NULL, options = NULL, cache = TRUE){
    datapath <- as.character(datapath)
    language <- as.character(language)
    options <- as.list(options)
    if(isTRUE(cache)){
      key <- digest::digest(list(language, datapath, options))
      if(is.null(store[[key]])){
        ptr <- tesseract_engine(datapath, language, options)
        assign(key, ptr, store);
      }
      store[[key]]
    } else {
      tesseract_engine(datapath, language, options)
    }
  }
})

tesseract_engine <- function(datapath, language, options){
  engine <- tesseract_engine_internal(datapath, language)
  for(i in seq_along(options)){
    tesseract_engine_set_variable(engine, names(options[i]), options[[i]])
  }
  engine
}

download_files <- function(urls){
  vapply(urls, function(path){
    if(grepl("^https?://", path)){
      tmp <- tempfile(fileext =  basename(path))
      curl::curl_download(path, tmp)
      path <- tmp
    }
    normalizePath(path, mustWork = TRUE)
  }, character(1))
}

#' @export
"print.tesseract" <- function(x, ...){
  info <- engine_info_internal(x)
  cat("<tesseract engine>\n")
  cat(" loaded:", info$loaded, "\n")
  cat(" datapath:", info$datapath, "\n")
  cat(" available:", info$available, "\n")
}
