#include "tesseract_types.h"

// [[Rcpp::export]]
Rcpp::List tesseract_config(){
  return Rcpp::List::create(
    Rcpp::_["version"] = tesseract::TessBaseAPI::Version()
  );
}

// [[Rcpp::export]]
TessPtr tesseract_engine_internal(Rcpp::CharacterVector datapath, const char * language){
  const char * path = NULL;
  if(datapath.length())
    path = CHAR(STRING_ELT(datapath, 0));
  tesseract::TessBaseAPI *api = new tesseract::TessBaseAPI();
  if (api->Init(path, language))
    throw std::runtime_error("Could not initialize tesseract");
  TessPtr ptr(api);
  ptr.attr("class") = Rcpp::CharacterVector::create("tesseract");
  return ptr;
}

tesseract::TessBaseAPI * get_engine(TessPtr engine){
  tesseract::TessBaseAPI * api = engine.get();
  if(api == NULL)
    throw std::runtime_error("pointer is dead");
  return api;
}

// [[Rcpp::export]]
Rcpp::List engine_info_internal(TessPtr ptr){
  tesseract::TessBaseAPI *api = get_engine(ptr);
  return Rcpp::List::create(
    Rcpp::_["datapath"] = api->GetDatapath(),
    Rcpp::_["language"] = api->GetInitLanguagesAsString()
  );
}

// [[Rcpp::export]]
Rcpp::String ocr_raw(Rcpp::RawVector input, TessPtr ptr){
    tesseract::TessBaseAPI *api = get_engine(ptr);

    // Open input image with leptonica library
    Pix *image =  pixReadMem(input.begin(), input.length());
    if(!image)
      throw std::runtime_error("Failed to read image");

    api->SetImage(image);

    // Get OCR result
    char *outText = api->GetUTF8Text();

    // Destroy used object and release memory
    Rcpp::String y(outText);
    y.set_encoding(CE_UTF8);
    delete [] outText;
    pixDestroy(&image);
    return y;
}

// [[Rcpp::export]]
Rcpp::String ocr_file(std::string file, TessPtr ptr){
  tesseract::TessBaseAPI *api = get_engine(ptr);

  // Open input image with leptonica library
  Pix *image =  pixRead(file.c_str());
  if(!image)
    throw std::runtime_error("Failed to read image");

  api->SetImage(image);

  // Get OCR result
  char *outText = api->GetUTF8Text();

  // Destroy used object and release memory
  Rcpp::String y(outText);
  y.set_encoding(CE_UTF8);
  delete [] outText;
  pixDestroy(&image);
  return y;
}
