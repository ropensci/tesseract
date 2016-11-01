#' Tesseract OCR
#'
#' Extract text from an image file. Works best if the image has high contrast
#' and horizontal text.
#'
#' @export
#' @useDynLib tesseract
#' @param image file path or raw vector to image
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
ocr <- function(image) {
  if(is.character(image)){
    data <- lapply(image, loadfile)
    vapply(data, ocr_raw, character(1))
  } else if(is.raw(image)){
    ocr_raw(image)
  } else {
    stop("Argument 'image' must be file-path, url or raw vector")
  }
}

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
