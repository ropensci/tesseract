#include "tesseract_types.h"

#include <list>
// #include <iostream>
#include <string>
#include <vector>

using namespace cpp11;

static tesseract::TessBaseAPI *make_analyze_api() {
  tesseract::TessBaseAPI *api = new tesseract::TessBaseAPI();
  api->InitForAnalysePage();
  return api;
}

[[cpp11::register]] list tesseract_config() {
  tesseract::TessBaseAPI *api = make_analyze_api();
  writable::list out;
  out.push_back({"version"_nm = tesseract::TessBaseAPI::Version()});
  out.push_back({"path"_nm = api->GetDatapath()});
  api->End();
  delete api;
  return out;
}

[[cpp11::register]] TessPtr tesseract_engine_internal(
    cpp11::strings datapath, cpp11::strings language, cpp11::strings confpaths,
    cpp11::strings opt_names, cpp11::strings opt_values) {
  std::vector<std::string> config_strings;
  std::vector<char *> configs;
  std::string path_str, lang_str;
  const char *path = NULL;
  const char *lang = NULL;

  if (datapath.size() > 0) {
    path_str = datapath[0];
    path = path_str.c_str();
  }
  if (language.size() > 0) {
    lang_str = language[0];
    lang = lang_str.c_str();
  }
  for (int i = 0; i < confpaths.size(); i++) {
    config_strings.push_back(std::string(confpaths[i]));
    configs.push_back(&config_strings.back()[0]);
  }

  std::vector<std::string> params;
  std::vector<std::string> values;
  for (int i = 0; i < opt_names.size(); i++) {
    params.push_back(std::string(opt_names[i]).c_str());
    values.push_back(std::string(opt_values[i]).c_str());
  }

  tesseract::TessBaseAPI *api = new tesseract::TessBaseAPI();
  int err = api->Init(path, lang, tesseract::OEM_DEFAULT, configs.data(),
                      configs.size(), &params, &values, false);
  if (err) {
    delete api;
    throw std::runtime_error(
        std::string("Unable to find training data for: ") +
        (lang ? lang : "eng") +
        ". Please consult manual for: ?tesseract_download");
  }
  TessPtr ptr(api);
  // cpp11 does not provide an attr method for external_pointers
  // ptr.attr("class") = writable::strings({"tesseract"});
  return ptr;
}

tesseract::TessBaseAPI *get_engine(TessPtr engine) {
  tesseract::TessBaseAPI *api = engine.get();
  if (api == NULL) throw std::runtime_error("pointer is dead");
  return api;
}

[[cpp11::register]] TessPtr tesseract_engine_set_variable(TessPtr ptr,
                                                          const char *name,
                                                          const char *value) {
  tesseract::TessBaseAPI *api = get_engine(ptr);
  if (!api->SetVariable(name, value))
    throw std::runtime_error(std::string("Failed to set variable ") + name);
  return ptr;
}

[[cpp11::register]] logicals validate_params(strings params) {
  std::string str;
  tesseract::TessBaseAPI *api = make_analyze_api();
  writable::logicals out(params.size());
  for (int i = 0; i < params.size(); i++)
    out[i] = api->GetVariableAsString(std::string(params.at(i)).c_str(), &str);
  api->End();
  delete api;
  return out;
}

[[cpp11::register]] list engine_info_internal(TessPtr ptr) {
  tesseract::TessBaseAPI *api = get_engine(ptr);
  std::vector<std::string> langs;
  api->GetAvailableLanguagesAsVector(&langs);
  writable::strings available;
  for (const auto &lang : langs) {
    available.push_back(lang);
  }
  langs.clear();
  api->GetLoadedLanguagesAsVector(&langs);
  writable::strings loaded;
  for (const auto &lang : loaded) {
    loaded.push_back(lang);
  }
  return writable::list({
    "datapath"_nm = api->GetDatapath(),
    "loaded"_nm = loaded,
    "available"_nm = available
  });
}

[[cpp11::register]] strings print_params(std::string filename) {
  tesseract::TessBaseAPI *api = make_analyze_api();
  FILE *fp = fopen(filename.c_str(), "w");
  api->PrintVariables(fp);
  fclose(fp);
  api->End();
  delete api;
  return writable::strings({filename});
}

[[cpp11::register]] cpp11::writable::strings get_param_values(
    TessPtr api, cpp11::strings params) {
  std::vector<std::string> values;
  for (int i = 0; i < params.size(); ++i) {
    std::string str;
    if (api->GetVariableAsString(std::string(params.at(i)).c_str(), &str)) {
      values.push_back(str);
    } else {
      values.push_back("");
    }
  }

  writable::strings result(values.size());
  for (size_t i = 0; i < values.size(); ++i) {
    result[i] = values[i];
  }

  return result;
}

strings ocr_pix(tesseract::TessBaseAPI *api, Pix *image, bool HOCR) {
  // Get OCR result
  api->ClearAdaptiveClassifier();
  api->SetImage(image);

  // Workaround for annoying warning, see
  // https://github.com/tesseract-ocr/tesseract/issues/756
  if (api->GetSourceYResolution() < 70) api->SetSourceResolution(300);
  char *outText = HOCR ? api->GetHOCRText(0) : api->GetUTF8Text();

  // cleanup
  pixDestroy(&image);
  api->Clear();

  // Destroy used object and release memory
  writable::strings y({outText});
  delete[] outText;
  return y;
}

[[cpp11::register]] strings ocr_raw(raws input, TessPtr ptr,
                                    bool HOCR = false) {
  tesseract::TessBaseAPI *api = get_engine(ptr);
  const l_uint8 *data = reinterpret_cast<const l_uint8 *>(RAW(input));
  Pix *image = pixReadMem(data, Rf_xlength(input));
  if (!image) throw std::runtime_error("Failed to read image");
  return ocr_pix(api, image, HOCR);
}

[[cpp11::register]] strings ocr_file(std::string file, TessPtr ptr,
                                     bool HOCR = false) {
  tesseract::TessBaseAPI *api = get_engine(ptr);
  Pix *image = pixRead(file.c_str());
  if (!image) throw std::runtime_error("Failed to read image");
  return ocr_pix(api, image, HOCR);
}

data_frame ocr_data_internal(tesseract::TessBaseAPI *api, Pix *image) {
  api->ClearAdaptiveClassifier();
  api->SetImage(image);
  if (api->GetSourceYResolution() < 70) api->SetSourceResolution(300);
  api->Recognize(0);
  tesseract::ResultIterator *ri = api->GetIterator();
  tesseract::PageIteratorLevel level = tesseract::RIL_WORD;
  size_t n = 0;
  std::list<std::string> words;
  std::list<std::string> bbox;
  std::list<float> conf;
  char buf[100];
  if (ri) {
    do {
      const char *word = ri->GetUTF8Text(level);
      if (!word) continue;
      words.push_back(word);
      conf.push_back(ri->Confidence(level));
      int x1, y1, x2, y2;
      ri->BoundingBox(level, &x1, &y1, &x2, &y2);
      snprintf(buf, 100, "%d,%d,%d,%d", x1, y1, x2, y2);
      bbox.push_back(buf);
      delete[] word;
      n++;
    } while (ri->Next(level));
  }
  writable::strings rwords(n);
  writable::strings rbbox(n);
  writable::doubles rconf(n);
  for (size_t i = 0; i < n; i++) {
    rwords[i] = words.front();
    words.pop_front();
    rbbox[i] = bbox.front();
    bbox.pop_front();
    rconf[i] = conf.front();
    conf.pop_front();
  }

  // cleanup
  pixDestroy(&image);
  api->Clear();
  delete ri;

  return writable::data_frame({
    "word"_nm = rwords,
    "confidence"_nm = rconf,
    "bbox"_nm = rbbox,
    "stringsAsFactors"_nm = false
  });
}

[[cpp11::register]] data_frame ocr_raw_data(raws input, TessPtr ptr) {
  tesseract::TessBaseAPI *api = get_engine(ptr);
  const l_uint8 *data = reinterpret_cast<const l_uint8 *>(RAW(input));
  Pix *image = pixReadMem(data, Rf_xlength(input));
  if (!image) throw std::runtime_error("Failed to read image");
  return ocr_data_internal(api, image);
}

[[cpp11::register]] data_frame ocr_file_data(const std::string& file, TessPtr ptr) {
  tesseract::TessBaseAPI *api = get_engine(ptr);
  Pix *image = pixRead(file.c_str());
  if (!image) throw std::runtime_error("Failed to read image");
  return ocr_data_internal(api, image);
}
