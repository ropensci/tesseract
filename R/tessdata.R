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
#' @param lang three letter code for language, see [tessdata](https://github.com/tesseract-ocr/tessdata) repository.
#' @param dir destination directory where to download store the file
#' @param progress show progress while downloading
#' @examples \dontrun{
#' tessdata_download("fra")
#' french <- tesseract("fra")
#' text <- ocr("http://ocrapiservice.com/static/images/examples/french_text.png", engine = french)
#' cat(text)
#' }
tessdata_download <- function(lang, dir = tessdata_info()$dir, progress = TRUE){
  stopifnot(is.character(lang))
  stopifnot(is.character(dir))
  dir <- normalizePath(dir, mustWork = TRUE)
  url <- sprintf('https://github.com/tesseract-ocr/tessdata/raw/master/%s.traineddata', lang)
  req <- curl::curl_fetch_memory(url, curl::new_handle(
    noprogress = !isTRUE(progress),
    progressfunction = progress_fun
  ))
  cat("\n")
  if(req$status_code != 200)
    stop("Download failed: HTTP ", req$status_code, call. = FALSE)
  destfile <- file.path(dir, basename(url))
  writeBin(req$content, destfile)
  return(destfile)
}

#' @export
#' @rdname tessdata
tessdata_info <- function(){
  info <- engine_info_internal(tesseract())
  list(dir = info$datapath, lang = info$available)
}

progress_fun <- function(down, up) {
  total <- down[[1]]
  now <- down[[2]]
  if(now > 10000)
    cat("\r Downloaded:", sprintf("%.2f", now / 2^20), "MB")
  TRUE
}
