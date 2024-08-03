#' Tesseract Training Data
#'
#' Helper function to download training data from the official
#' [tessdata](https://tesseract-ocr.github.io/tessdoc/Data-Files) repository. On Linux, the fast training data can be installed directly with
#' [yum](https://src.fedoraproject.org/rpms/tesseract) or
#' [apt-get](https://packages.debian.org/search?suite=stable&section=all&arch=any&searchon=names&keywords=tesseract-ocr-).
#'
#' Tesseract uses training data to perform OCR. Most systems default to English
#' training data. To improve OCR performance for other languages you can to install the
#' training data from your distribution. For example to install the spanish training data:
#'
#'  - [tesseract-ocr-spa](https://packages.debian.org/testing/tesseract-ocr-spa) (Debian, Ubuntu)
#'  - `tesseract-langpack-spa` (Fedora, EPEL)
#'
#' On Windows and MacOS you can install languages using the [tesseract_download] function
#' which downloads training data directly from [github](https://github.com/tesseract-ocr/tessdata)
#' and stores it in a the path on disk given by the `TESSDATA_PREFIX` variable.
#'
#' @export
#' @aliases tessdata
#' @rdname tessdata
#' @family tesseract
#' @param lang three letter code for language, see [tessdata](https://github.com/tesseract-ocr/tessdata) repository.
#' @param datapath destination directory where to download store the file
#' @param model either `fast` or `best` is currently supported. The latter downloads
#' more accurate (but slower) trained models for Tesseract 4.0 or higher
#' @param progress print progress while downloading
#' @references [tesseract wiki: training data](https://tesseract-ocr.github.io/tessdoc/Data-Files)
#' @examples \dontrun{
#' if(is.na(match("fra", tesseract_info()$available)))
#'   tesseract_download("fra", model = 'best')
#' french <- tesseract("fra")
#' text <- ocr("https://jeroen.github.io/images/french_text.png", engine = french)
#' cat(text)
#' }
tesseract_download <- function(lang, datapath = NULL, model = c("fast", "best"), progress = interactive()) {
  stopifnot(is.character(lang))
  model <- match.arg(model)
  if(!length(datapath)){
    warn_on_linux()
    datapath <- tesseract_info()$datapath
  }
  datapath <- normalizePath(datapath, mustWork = TRUE)
  version <- tesseract_version_major()

  if(version < 4){
    repo <- "tessdata"
    release <- "3.04.00"
  } else {
    repo <- paste0("tessdata_", model)
    release <- "4.1.0"
  }

  url <- sprintf("https://github.com/tesseract-ocr/%s/raw/%s/%s.traineddata", repo, release, lang)

  destfile <- file.path(datapath, basename(url))

  if (file.exists(destfile)) {
    message(paste("Training data already exists. Overwriting", destfile))
  }

  req <- curl::curl_fetch_memory(url, curl::new_handle(
    progressfunction = progress_fun,
    noprogress = !isTRUE(progress)
  ))
  if(progress)
    cat("\n")
  if(req$status_code != 200)
    stop("Download failed: HTTP ", req$status_code, call. = FALSE)

  writeBin(req$content, destfile)
  return(destfile)
}

progress_fun <- function(down, up) {
  total <- down[[1]]
  now <- down[[2]]
  pct <- if(length(total) && total > 0){
    paste0("(", round(now/total * 100), "%)")
  } else {
    ""
  }
  if(now > 10000)
    cat("\r Downloaded:", sprintf("%.2f", now / 2^20), "MB ", pct)
  TRUE
}

warn_on_linux <- function(){
  if(identical(.Platform$OS.type, "unix") && !identical(Sys.info()[["sysname"]], "Darwin")){
    warning("On Linux you should install training data via yum/apt. Please check the manual page.", call. = FALSE)
  }
}
