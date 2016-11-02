#include <baseapi.h>
#include <allheaders.h>

#define R_NO_REMAP
#define STRICT_R_HEADERS

#include <Rcpp.h>
using namespace Rcpp;


// [[Rcpp::export]]
String ocr_file( std::string filename){
  tesseract::TessBaseAPI *api = new tesseract::TessBaseAPI();

  // Initialize tesseract-ocr with English, without specifying tessdata path
  if (api->Init(NULL, "eng"))
    throw std::runtime_error("Could not initialize tesseract.\n");

  // Open input image with leptonica library
  Pix *image = pixRead(filename.c_str());
  if(!image)
    throw std::runtime_error("Failed to read image");

  api->SetImage(image);

  // Get OCR result
  char *outText = api->GetUTF8Text();

  // Destroy used object and release memory
  api->End();
  String y(outText);
  y.set_encoding(CE_UTF8);
  delete [] outText;
  pixDestroy(&image);
  return y;
}

// [[Rcpp::export]]
String ocr_raw(RawVector input){
    tesseract::TessBaseAPI *api = new tesseract::TessBaseAPI();

    // Initialize tesseract-ocr with English, without specifying tessdata path
    if (api->Init(NULL, "eng"))
      throw std::runtime_error("Could not initialize tesseract.\n");

    // Open input image with leptonica library
    Pix *image =  pixReadMem(input.begin(), input.length());
    if(!image)
      throw std::runtime_error("Failed to read image");

    api->SetImage(image);

    // Get OCR result
    char *outText = api->GetUTF8Text();

    // Destroy used object and release memory
    api->End();
    String y(outText);
    y.set_encoding(CE_UTF8);
    delete [] outText;
    pixDestroy(&image);
    return y;
}
