#' Tesseract Engine
#'
#' Create an OCR engine for a given language and control parameters. This can be used by
#' the [ocr] and [ocr_data] functions to recognize text.
#'
#' Tesseract control parameters can be set either via a named list in the
#' `options` parameter, or in a `config` file text file which contains the parameter name
#' followed by a space and then the value, one per line. Use [tesseract_params()] to list
#' or find parameters. Note that that some parameters are only supported in certain versions
#' of libtesseract, and that invalid parameters can sometimes cause libtesseract to crash.
#'
#' @export
#' @rdname tesseract
#' @family tesseract
#' @param language string with language for training data. Usually defaults to `eng`
#' @param datapath path with the training data for this language. Default uses
#' the system library.
#' @param configs character vector with files, each containing one or more parameter
#' values. These config files can exist in the current directory or one of the standard
#' tesseract config files that live in the tessdata directory. See details.
#' @param options a named list with tesseract parameters. See details.
#' @param cache speed things up by caching engines
tesseract <- local({
  store <- new.env()
  function(language = "eng", datapath = NULL, configs = NULL, options = NULL, cache = TRUE){
    datapath <- normalizePath(as.character(datapath), mustWork = TRUE)
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

#' @export
#' @rdname tesseract
#' @param filter only list parameters containing a particular string
#' @examples tesseract_params('debug')
tesseract_params <- function(filter = ""){
  tmp <- print_params(tempfile())
  on.exit(unlink(tmp))
  df <- parse_params(tmp)
  subset <- grepl(filter, paste(df$param, df$desc), ignore.case = TRUE)
  df_as_tibble(df[subset,])
}

#' @export
#' @rdname tesseract
tesseract_info <- function(){
  info <- engine_info_internal(tesseract())
  config <- tesseract_config()
  list(datapath = info$datapath,
       available = info$available,
       version = config$version,
       configs = list.files(file.path(info$datapath, "configs")))
}

parse_params <- function(path){
  utils::read.delim(path, header = FALSE, quote = "",
                    col.names = c("param", "default", "desc"), stringsAsFactors = FALSE)
}

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
  files <- vapply(urls, function(path){
    if(grepl("^https?://", path)){
      tmp <- tempfile(fileext =  basename(path))
      curl::curl_download(path, tmp)
      path <- tmp
    }
    normalizePath(path, mustWork = TRUE)
  }, character(1))
  is_pdf <- grepl(".pdf$", files)
  out <- unlist(lapply(files[is_pdf], function(path){
    pdftools::pdf_convert(path, dpi = 600)
  }))
  c(files[!is_pdf], out)
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

df_as_tibble <- function(df){
  stopifnot(is.data.frame(df))
  class(df) <- c("tbl_df", "tbl", "data.frame")
  df
}
