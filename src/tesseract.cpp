#include "tesseract_types.h"
#include <genericvector.h>
#include <params.h>

// [[Rcpp::export]]
Rcpp::List tesseract_config(){
  tesseract::TessBaseAPI api;
  api.InitForAnalysePage();
  return Rcpp::List::create(
    Rcpp::_["version"] = tesseract::TessBaseAPI::Version(),
    Rcpp::_["path"] = api.GetDatapath()
  );
}

// [[Rcpp::export]]
TessPtr tesseract_engine_internal(Rcpp::CharacterVector datapath, Rcpp::CharacterVector language, Rcpp::CharacterVector confpath,
                                  Rcpp::CharacterVector opt_names, Rcpp::CharacterVector opt_values){
  GenericVector<STRING> params, values;
  const char * path = NULL;
  const char * lang = NULL;
  char * config = NULL;
  if(datapath.length())
    path = datapath.at(0);
  if(language.length())
    lang = language.at(0);
  if(confpath.length())
    config = confpath.at(0);
  for(size_t i = 0; i < opt_names.length(); i++){
    params.push_back(std::string(opt_names.at(i)).c_str());
    values.push_back(std::string(opt_values.at(i)).c_str());
  }
  tesseract::TessBaseAPI *api = new tesseract::TessBaseAPI();
  if (api->Init(path, lang, tesseract::OEM_DEFAULT, &config, !!config, &params, &values, false))
    throw std::runtime_error(std::string("Unable to find training data for: ") + (lang ? lang : "eng") + ". Please consult manual for: ?tesseract_download");
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
TessPtr tesseract_engine_set_variable(TessPtr ptr, const char * name, const char * value){
  tesseract::TessBaseAPI * api = get_engine(ptr);
  if(!api->SetVariable(name, value))
    throw std::runtime_error(std::string("Failed to set variable ") + name);
  return ptr;
}

// [[Rcpp::export]]
Rcpp::LogicalVector validate_params(Rcpp::CharacterVector params){
  STRING str;
  tesseract::TessBaseAPI api;
  api.InitForAnalysePage();
  Rcpp::LogicalVector out(params.length());
  for(int i = 0; i < params.length(); i++)
    out[i] = api.GetVariableAsString(params.at(i), &str);
  return out;
}

// [[Rcpp::export]]
void validate_paramfile(const char * path){
  tesseract::ParamsVectors p;
  tesseract::ParamUtils::ReadParamsFile(path, tesseract::SET_PARAM_CONSTRAINT_NONE, &p);
}

// [[Rcpp::export]]
Rcpp::List engine_info_internal(TessPtr ptr){
  tesseract::TessBaseAPI * api = get_engine(ptr);
  GenericVector<STRING> langs;
  api->GetAvailableLanguagesAsVector(&langs);
  Rcpp::CharacterVector available = Rcpp::CharacterVector::create();
  for(int i = 0; i < langs.length(); i++)
    available.push_back(langs.get(i).c_str());
  langs.clear();
  api->GetLoadedLanguagesAsVector(&langs);
  Rcpp::CharacterVector loaded = Rcpp::CharacterVector::create();
  for(int i = 0; i < langs.length(); i++)
    loaded.push_back(langs.get(i).c_str());
  return Rcpp::List::create(
    Rcpp::_["datapath"] = api->GetDatapath(),
    Rcpp::_["loaded"] = loaded,
    Rcpp::_["available"] = available
  );
}

// [[Rcpp::export]]
Rcpp::String print_params(std::string filename){
  tesseract::TessBaseAPI api;
  api.InitForAnalysePage();
  FILE * fp = fopen(filename.c_str(), "w");
  api.PrintVariables(fp);
  fclose(fp);
  return filename;
}

// [[Rcpp::export]]
Rcpp::CharacterVector get_param_values(TessPtr ptr, Rcpp::CharacterVector params){
  STRING str;
  tesseract::TessBaseAPI * api = get_engine(ptr);
  Rcpp::CharacterVector out(params.length());
  for(int i = 0; i < params.length(); i++)
    out[i] = api->GetVariableAsString(params.at(i), &str) ? Rcpp::String(str.c_str()) : NA_STRING;
  return out;
}

Rcpp::String ocr_pix(tesseract::TessBaseAPI * api, Pix * image, bool HOCR){
  // Get OCR result
  api->ClearAdaptiveClassifier();
  api->SetImage(image);

  // Workaround for annoying warning, see https://github.com/tesseract-ocr/tesseract/issues/756
  if(api->GetSourceYResolution() < 70)
    api->SetSourceResolution(300);
  char *outText = HOCR ? api->GetHOCRText(0) : api->GetUTF8Text();

  //cleanup
  pixDestroy(&image);
  api->Clear();

  // Destroy used object and release memory
  Rcpp::String y(outText);
  y.set_encoding(CE_UTF8);
  delete [] outText;
  return y;
}

// [[Rcpp::export]]
Rcpp::String ocr_raw(Rcpp::RawVector input, TessPtr ptr, bool HOCR = false){
    tesseract::TessBaseAPI *api = get_engine(ptr);
    Pix *image =  pixReadMem(input.begin(), input.length());
    if(!image)
      throw std::runtime_error("Failed to read image");
    return ocr_pix(api, image, HOCR);
}

// [[Rcpp::export]]
Rcpp::String ocr_file(std::string file, TessPtr ptr, bool HOCR = false){
  tesseract::TessBaseAPI *api = get_engine(ptr);
  Pix *image =  pixRead(file.c_str());
  if(!image)
    throw std::runtime_error("Failed to read image");
  return ocr_pix(api, image, HOCR);
}
