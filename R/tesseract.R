#' Tesseract OCR
#'
#' Extract text from an image. Requires that you have training data for the language you
#' are reading. Works best for images with high contrast, little noise and horizontal text.
#'
#' The `ocr()` function returns plain text by default, or hOCR output if hOCR is set to `TRUE`.
#' The `ocr_data()` function returns a data frame with a confidence rate and bounding box for
#' each word in the text.
#'
#' Tesseract [control parameters][tesseract_params] can be set either via a named list in the
#' `options` parameter, or in a `config` file text file which contains the parameter name
#' followed by a space and then the value, one per line. Use[tesseract_params()] to list
#' supported parameters. Note that invalid parameters can sometimes cause a crash.
#'
#' @export
#' @useDynLib tesseract
#' @family tesseract
#' @param image file path, url, or raw vector to image (png, tiff, jpeg, etc)
#' @param engine a tesseract engine created with `tesseract()`
#' @param HOCR if `TRUE` return results as HOCR xml instead of plain text
#' @rdname tesseract
#' @references [Tesseract training data](https://github.com/tesseract-ocr/tesseract/wiki/Data-Files)
#' @aliases tesseract ocr
#' @importFrom Rcpp sourceCpp
#' @examples # Simple example
#' text <- ocr("https://jeroen.github.io/images/testocr.png")
#' cat(text)
#'
#' xml <- ocr("https://jeroen.github.io/images/testocr.png", HOCR = TRUE)
#' cat(xml)
#'
#' df <- ocr_data("https://jeroen.github.io/images/testocr.png")
#' print(df)
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
      magick::image_write(x, tmp, format = 'PNG', density = '300x300')
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

#' @rdname tesseract
#' @export
ocr_data <- function(image, engine = tesseract("eng")) {
  stopifnot(inherits(engine, "tesseract"))
  df_list <- if(inherits(image, "magick-image")){
    lapply(image, function(x){
      tmp <- tempfile(fileext = ".png")
      on.exit(unlink(tmp))
      magick::image_write(x, tmp, format = 'PNG', density = "72x72")
      ocr_data(tmp, engine = engine)
    })
  } else if(is.character(image)){
    image <- download_files(image)
    lapply(image, function(im){
      ocr_file_data(im, ptr = engine)
    })
  } else if(is.raw(image)){
    list(ocr_raw_data(image, engine))
  } else {
    stop("Argument 'image' must be file-path, url or raw vector")
  }
  tibble::as.tibble(do.call(rbind.data.frame, unname(df_list)))
}

#' @export
#' @rdname tesseract
#' @param language string with language for training data. Usually defaults to `eng`
#' @param datapath path with the training data for this language. Default uses
#' the system library.
#' @param configs character vector with files, each containing one or more parameter
#' values. These config files can exist in the current directory or one of the standard
#' tesseract config files that live in the tessdata directory. See details.
#' @param options a named list with tesseract parameters. See [tesseract_params()]
#' for a list of supported options with description. See details.
#' @param cache use a cached version of engine if possible to speed up loading
tesseract <- local({
  store <- new.env()
  function(language = NULL, datapath = NULL, configs = NULL, options = NULL, cache = TRUE){
    datapath <- as.character(datapath)
    language <- as.character(language)
    configs <- as.character(configs)
    options <- as.list(options)
    if(isTRUE(cache)){
      key <- digest::digest(list(language, datapath, configs, options))
      if(is.null(store[[key]])){
        ptr <- tesseract_engine(datapath, language, configs, options)
        assign(key, ptr, store);
      }
      store[[key]]
    } else {
      tesseract_engine(datapath, language, configs, options)
    }
  }
})

tesseract_engine <- function(datapath, language, configs, options){

  # Tesseract::read_config_file first checks for local file, then in tessdata
  lapply(configs, function(confpath){
    if(file.exists(confpath)){
      params <- tryCatch(utils::read.table(confpath, quote = ""), error = function(e){
        bail("Failed to parse config file '%s': %s", confpath, e$message)
      })
      ok <- validate_params(params$V1)
      if(any(!ok))
        bail("Unsupported Tesseract parameter(s): [%s] in %s", paste(params$V1[!ok], collapse = ", "), confpath)
    }
  })

  opt_names <- as.character(names(options))
  opt_values <- as.character(options)
  ok <- validate_params(opt_names)
  if(any(!ok))
    bail("Unsupported Tesseract parameter(s): [%s]", paste(opt_names[!ok], collapse = ", "))

  tesseract_engine_internal(datapath, language, configs, opt_names, opt_values)
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

bail <- function(...){
  stop(sprintf(...), call. = FALSE)
}
