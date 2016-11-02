#' Tesseract OCR
#'
#' Extract text from an image file. Works best if the image has high contrast
#' and horizontal text.
#'
#' @export
#' @useDynLib tesseract
#' @param image file path or raw vector to image
#' @param engine a tesseract engine created with `tesseract()`
#' @rdname tesseract
#' @aliases tesseract ocr
#' @importFrom Rcpp sourceCpp
#' @examples # Some packages
#' library(pdftools)
#' library(tesseract)
#' library(png)
#' library(jpeg)
#' library(tiff)
#'
#' # Render pdf to png
#' setwd(tempdir())
#' news <- file.path(Sys.getenv("R_DOC_DIR"), "NEWS.pdf")
#' bitmap <- pdf_render_page(news, dpi = 300)
#' png::writePNG(bitmap, "page.png")
#' jpeg::writeJPEG(bitmap, "page.jpg")
#' tiff::writeTIFF(bitmap, "page.tiff")
#'
#' # Extract text from images
#' txt <- ocr(c("page.png", "page.png", "page.tiff"))
#' cat(txt)
ocr <- function(image, engine = tesseract()) {
  stopifnot(inherits(engine, "tesseract"))
  if(is.character(image)){
    data <- lapply(image, loadfile)
    vapply(data, ocr_raw, character(1), ptr = engine)
  } else if(is.raw(image)){
    ocr_raw(image, engine)
  } else {
    stop("Argument 'image' must be file-path, url or raw vector")
  }
}

#' @export
#' @rdname tesseract
#' @param language string with language for training data
#' @param datapath path with the training data for this language. Default uses
#' the system default library.
#' @param cache use a cached version of this training data if available
tesseract <- local({
  store <- new.env()
  function(language = "eng", datapath = NULL, cache = TRUE){
    datapath <- as.character(datapath)
    if(isTRUE(cache)){
      key <- digest::digest(list(language, datapath))
      if(is.null(store[[key]])){
        ptr <- tesseract_engine_internal(datapath, language)
        assign(key, ptr, store);
      }
      store[[key]]
    } else {
      tesseract_engine_internal(datapath, language)
    }
  }
})

loadfile <- function(path){
  path <- path[1]
  stopifnot(is.character(path))
  if(grepl("^https?://", path)){
    req <- curl::curl_fetch_memory(path)
    if(req$status != 200) stop("Failed to download file: ", path)
    return(req$content)
  } else {
    path <- normalizePath(path)
    stopifnot(file.exists(path))
    readBin(path, raw(), file.info(path)$size)
  }
}


#' @export
"print.tesseract" <- function(x, ...){
  info <- engine_info_internal(x)
  cat("<tesseract engine>\n")
  cat(" language:", info$language, "\n")
  cat(" datapath:", info$datapath, "\n")
}
