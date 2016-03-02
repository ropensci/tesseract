#' Tesseract OCR
#'
#' Extract text from an image file.
#'
#' @export
#' @param image file path or raw vector to image
#' @param format must be one of "png", "jpeg", "tiff", "gif"
#' @useDynLib tesseract
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
#' txt1 <- ocr("page.png")
#' txt2 <- ocr("page.jpg")
#' txt3 <- ocr("page.tiff")
#' cat(txt1)
ocr <- function(image, format) {
  if(missing(format) && is.character(image)){
    pieces <- strsplit(basename(image), ".", fixed = TRUE)[[1]]
    format <- tolower(pieces[length(pieces)])
    if(format == "jpg")
      format <- "jpeg"
  }
  format <- match.arg(format, c("png", "jpeg", "tiff", "gif"))
  image <- loadfile(image)
  R_ocr(image, format)
}

loadfile <- function(image){
  if(is.character(image)){
    if(grepl("^https?://", image[1])){
      image <- url(image)
    } else {
      path <- normalizePath(image, mustWork = TRUE)
      image <- readBin(path, raw(), file.info(path)$size)
    }
  }
  if(inherits(image, "connection")){
    con <- image
    image <- raw()
    if(!isOpen(con)){
      open(con, "rb")
      on.exit(close(con))
    }
    while(length(buf <- readBin(con, raw(), 1e6))){
      image <- c(image, buf)
    }
  }
  if(!is.raw(image))
    stop("Argument pdf must be a path or raw vector with PDF data")
  image
}
