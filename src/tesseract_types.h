#include <tesseract/baseapi.h>
#include <allheaders.h>

#define R_NO_REMAP
#define STRICT_R_HEADERS

#include <Rcpp.h>

inline void tess_finalizer(tesseract::TessBaseAPI *engine) {
  engine->End();
  delete engine;
}

typedef Rcpp::XPtr<tesseract::TessBaseAPI, Rcpp::PreserveStorage, tess_finalizer, true> TessPtr;
