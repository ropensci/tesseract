#include <leptonica/allheaders.h>
#include <tesseract/baseapi.h>

#define R_NO_REMAP
#define STRICT_R_HEADERS

#include <cpp11.hpp>
#include <cpp11/external_pointer.hpp>

inline void tess_finalizer(tesseract::TessBaseAPI* engine) {
  engine->End();
  delete engine;
}

typedef cpp11::external_pointer<tesseract::TessBaseAPI> TessPtr;

inline TessPtr make_tess_ptr(tesseract::TessBaseAPI* engine) {
  return TessPtr(engine, tess_finalizer);
}