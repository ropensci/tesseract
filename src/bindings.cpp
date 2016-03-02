#include <baseapi.h>
#include <allheaders.h>

#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
String R_ocr(RawVector input, std::string format){
    tesseract::TessBaseAPI *api = new tesseract::TessBaseAPI();

    // Initialize tesseract-ocr with English, without specifying tessdata path
    if (api->Init(NULL, "eng"))
      throw std::runtime_error("Could not initialize tesseract.\n");

    // Open input image with leptonica library
    Pix *image;
    if(!format.compare("png")){
      image = pixReadMemPng(input.begin(), input.length());
    } else if(!format.compare("jpeg")){
      //args: https://github.com/peirick/leptonica/blob/master/leptonica/src/jpegio.c
      image = pixReadMemJpeg(input.begin(), input.length(), 0, 1, NULL, 0);
    } else if(!format.compare("tiff")){
      //0 means first page only
      image = pixReadMemTiff(input.begin(), input.length(), 0);
    } else if(!format.compare("gif")){
      image = pixReadMemGif(input.begin(), input.length());
    } else if(!format.compare("bmp")){
      image = pixReadMemBmp(input.begin(), input.length());
    } else {
      throw std::runtime_error("Invalid image format");
    }

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
