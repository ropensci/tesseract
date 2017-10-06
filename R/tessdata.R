#' Tesseract Training Data
#'
#' Helper function to download training data from the official
#' [tessdata](https://github.com/tesseract-ocr/tessdata) repository. Only use this function on
#' Windows and OS-X. On Linux, training data can be installed directly with
#' [yum](https://apps.fedoraproject.org/packages/tesseract) or
#' [apt-get](https://packages.debian.org/search?suite=stable&section=all&arch=any&searchon=names&keywords=tesseract-ocr-).
#'
#' @export
#' @aliases tessdata
#' @rdname tessdata
#' @family tesseract
#' @param lang three letter code for language, see [tessdata](https://github.com/tesseract-ocr/tessdata) repository.
#' @param datapath destination directory where to download store the file
#' @param progress print progress while downloading
#' @examples \dontrun{
#' tesseract_download("fra")
#' french <- tesseract("fra")
#' text <- ocr("https://jeroen.github.io/images/french_text.png", engine = french)
#' cat(text)
#' }
tesseract_download <- function(lang, datapath = NULL, progress = TRUE){
  if(!length(datapath)){
    warn_on_linux()
    datapath <- tesseract_info()$datapath
  }
  stopifnot(is.character(lang))
  stopifnot(is.character(datapath))
  version <- as.numeric(substring(tesseract_config()$version, 1, 4))
  branch <- ifelse(version < 4, "3.04.00", "4.00")
  url <- sprintf('https://github.com/tesseract-ocr/tessdata/raw/%s/%s.traineddata', branch, lang)
  req <- curl::curl_fetch_memory(url, curl::new_handle(
    noprogress = !isTRUE(progress),
    progressfunction = progress_fun
  ))
  if(progress)
    cat("\n")
  if(req$status_code != 200)
    stop("Download failed: HTTP ", req$status_code, call. = FALSE)
  destfile <- normalizePath(file.path(datapath, basename(url)), mustWork = FALSE)
  writeBin(req$content, destfile)
  return(destfile)
}

#' @export
#' @rdname tessdata
tesseract_info <- function(){
  info <- engine_info_internal(tesseract())
  config <- tesseract_config()
  list(datapath = info$datapath, available = info$available, version = config$version)
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
