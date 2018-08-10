#' Tesseract Training Data
#'
#' Helper function to download training data from the official
#' [tessdata](https://github.com/tesseract-ocr/tesseract/wiki/Data-Files) repository. Only use this function on
#' Windows and OS-X. On Linux, training data can be installed directly with
#' [yum](https://apps.fedoraproject.org/packages/tesseract) or
#' [apt-get](https://packages.debian.org/search?suite=stable&section=all&arch=any&searchon=names&keywords=tesseract-ocr-).
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
#' @aliases tessdata
#' @rdname tessdata
#' @family tesseract
#' @param lang three letter code for language, see [tessdata](https://github.com/tesseract-ocr/tessdata) repository.
#' @param datapath destination directory where to download store the file
#' @param progress print progress while downloading
#' @references [tesseract wiki: training data](https://github.com/tesseract-ocr/tesseract/wiki/Data-Files)
#' @examples \donttest{
#' if(is.na(match("fra", tesseract_info()$available)))
#'   tesseract_download("fra")
#' french <- tesseract("fra")
#' text <- ocr("https://jeroen.github.io/images/french_text.png", engine = french)
#' cat(text)
#' }
tesseract_download <- function(lang, datapath = NULL, progress = interactive()){
  if(!length(datapath)){
    warn_on_linux()
    datapath <- tesseract_info()$datapath
  }
  stopifnot(is.character(lang))
  stopifnot(is.character(datapath))
  version <- tesseract_version_major()
  if(version < 4){
    repo <- "tessdata"
    release <- "3.04.00"
  } else {
    repo <- "tessdata_fast"
    release <- "4.0.0-beta.1"
  }
  url <- sprintf('https://github.com/tesseract-ocr/%s/raw/%s/%s.traineddata', repo, release, lang)
  req <- curl::curl_fetch_memory(url, curl::new_handle(
    progressfunction = progress_fun,
    noprogress = !isTRUE(progress)
  ))
  if(progress)
    cat("\n")
  if(req$status_code != 200)
    stop("Download failed: HTTP ", req$status_code, call. = FALSE)
  destfile <- normalizePath(file.path(datapath, basename(url)), mustWork = FALSE)
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
