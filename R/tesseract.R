#' Tesseract OCR
#'
#' Extract text from an image. Requires that you have training data for the language you
#' are reading. Works best for images with high contrast, little noise and horizontal text.
#'
#' Tesseract uses training data to perform OCR. Most systems default to English
#' training data. To improve OCR performance for other languages you can to install the
#' training data from your distribution. For example to install the spanish training data:
#'
#'  - [tesseract-ocr-spa](https://packages.debian.org/testing/tesseract-ocr-spa) (Debian, Ubuntu)
#'  - [tesseract-langpack-spa](https://apps.fedoraproject.org/packages/tesseract-langpack-spa) (Fedora, EPEL)
#'
#' On Windows and MacOS you can install languages using the [tesseract_download] function
#' which downloads training data directly from [github](https://github.com/tesseract-ocr/tessdata)
#' and stores it in a the path on disk given by the `TESSDATA_PREFIX` variable.
#'
#' @export
#' @useDynLib tesseract
#' @family tesseract
#' @param image file path, url, or raw vector to image (png, tiff, jpeg, etc)
#' @param engine a tesseract engine created with `tesseract()`
#' @param HOCR if `TRUE` return results as HOCR xml instead of plain text
#' @rdname tesseract
#' @references [Tesseract training data](https://github.com/tesseract-ocr/tessdata)
#' @aliases tesseract ocr
#' @importFrom Rcpp sourceCpp
#' @examples # Simple example
#' text <- ocr("https://jeroen.github.io/images/testocr.png")
#' cat(text)
#'
#' xml <- ocr("https://jeroen.github.io/images/testocr.png", HOCR = TRUE)
#' cat(xml)
#'
#' \dontrun{
#' # Full roundtrip test: render PDF to image and OCR it back to text
#' curl::curl_download("https://cran.r-project.org/doc/manuals/r-release/R-intro.pdf", "R-intro.pdf")
#' orig <- pdftools::pdf_text("R-intro.pdf")[1]
#'
#' # Render pdf to png image
#' img_file <- pdftools::pdf_convert("R-intro.pdf", format = 'tiff', pages = 1, dpi = 400)
#'
#' # Extract text from png image
#' text <- ocr(img_file)
#' unlink(img_file)
#' cat(text)
#' }
#'
#' engine <- tesseract(options = list(tessedit_char_whitelist = "0123456789"))
ocr <- function(image, engine = tesseract("eng"), HOCR = FALSE) {
  stopifnot(inherits(engine, "tesseract"))
  if(inherits(image, "magick-image")){
    vapply(image, function(x){
      tmp <- tempfile(fileext = ".png")
      on.exit(unlink(tmp))
      magick::image_write(x, tmp, format = 'PNG', density = "72x72")
      ocr(tmp, engine = engine)
    }, character(1))
  } else if(is.character(image)){
    image <- download_files(image)
    vapply(image, ocr_file, character(1), ptr = engine, HOCR = HOCR, USE.NAMES = FALSE)
  } else if(is.raw(image)){
    ocr_raw(image, engine, HOCR = HOCR)
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
